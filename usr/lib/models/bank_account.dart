import 'banking_exceptions.dart';

class BankAccount {
  double _balance;

  BankAccount({double initialBalance = 0.0}) : _balance = initialBalance;

  double get balance => _balance;

  void deposit(double amount) {
    if (amount < 0) {
      throw InvalidAmountException("Cannot deposit a negative amount.");
    }
    _balance += amount;
  }

  void withdraw(double amount) {
    if (amount < 0) {
      throw InvalidAmountException("Cannot withdraw a negative amount.");
    }
    if (amount > _balance) {
      throw InsufficientFundsException("Insufficient balance: Available \$${_balance.toStringAsFixed(2)}");
    }
    _balance -= amount;
  }
}
