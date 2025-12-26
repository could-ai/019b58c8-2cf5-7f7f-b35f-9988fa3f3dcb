import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/bank_account.dart';
import '../models/banking_exceptions.dart';

class BankingScreen extends StatefulWidget {
  const BankingScreen({super.key});

  @override
  State<BankingScreen> createState() => _BankingScreenState();
}

class _BankingScreenState extends State<BankingScreen> {
  final BankAccount _account = BankAccount(initialBalance: 1000.0); // Start with some money
  final TextEditingController _amountController = TextEditingController();
  String _message = "Welcome! Enter an amount to transact.";
  Color _messageColor = Colors.black;

  void _handleTransaction(bool isDeposit) {
    // Clear previous message
    setState(() {
      _message = "";
    });

    final String input = _amountController.text;
    if (input.isEmpty) {
      _showMessage("Please enter an amount.", isError: true);
      return;
    }

    final double? amount = double.tryParse(input);
    if (amount == null) {
      _showMessage("Invalid number format.", isError: true);
      return;
    }

    try {
      setState(() {
        if (isDeposit) {
          _account.deposit(amount);
          _showMessage("Successfully deposited \$${amount.toStringAsFixed(2)}", isError: false);
        } else {
          _account.withdraw(amount);
          _showMessage("Successfully withdrew \$${amount.toStringAsFixed(2)}", isError: false);
        }
        _amountController.clear();
      });
    } on InsufficientFundsException catch (e) {
      _showMessage(e.toString(), isError: true);
    } on InvalidAmountException catch (e) {
      _showMessage(e.toString(), isError: true);
    } catch (e) {
      _showMessage("An unexpected error occurred: $e", isError: true);
    }
  }

  void _showMessage(String msg, {required bool isError}) {
    setState(() {
      _message = msg;
      _messageColor = isError ? Colors.red : Colors.green;
    });
    
    // Also show a SnackBar for better visibility
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banking Exception Handler'),
        backgroundColor: Colors.teal.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance Card
            Card(
              elevation: 4,
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'Current Balance',
                      style: TextStyle(fontSize: 18, color: Colors.teal),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '\$${_account.balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Input Field
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')), // Allow negative for testing exception
              ],
              decoration: const InputDecoration(
                labelText: 'Enter Amount',
                hintText: 'e.g. 100.00',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleTransaction(true),
                    icon: const Icon(Icons.arrow_downward),
                    label: const Text('DEPOSIT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleTransaction(false),
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text('WITHDRAW'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Status Message Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _messageColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _messageColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _messageColor == Colors.red ? Icons.error_outline : Icons.check_circle_outline,
                    color: _messageColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _message,
                      style: TextStyle(
                        color: _messageColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
