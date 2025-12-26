import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/consumer_types.dart';

class BillGeneratorScreen extends StatefulWidget {
  const BillGeneratorScreen({super.key});

  @override
  State<BillGeneratorScreen> createState() => _BillGeneratorScreenState();
}

class _BillGeneratorScreenState extends State<BillGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _unitsController = TextEditingController();

  // State variables
  String _selectedConsumerType = 'Residential';
  UtilityType _selectedUtility = UtilityType.electricity;
  double? _calculatedBill;
  Consumer? _generatedConsumer;

  final List<String> _consumerTypes = ['Residential', 'Commercial', 'Industrial'];

  void _generateBill() {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final double units = double.parse(_unitsController.text);

      // Polymorphic creation of consumer
      Consumer consumer;
      switch (_selectedConsumerType) {
        case 'Residential':
          consumer = ResidentialConsumer(name: name, unitsConsumed: units);
          break;
        case 'Commercial':
          consumer = CommercialConsumer(name: name, unitsConsumed: units);
          break;
        case 'Industrial':
          consumer = IndustrialConsumer(name: name, unitsConsumed: units);
          break;
        default:
          consumer = ResidentialConsumer(name: name, unitsConsumed: units);
      }

      setState(() {
        _generatedConsumer = consumer;
        // Polymorphic call: calculateBill() behaves differently based on the object type
        _calculatedBill = consumer.calculateBill(_selectedUtility);
      });
    }
  }

  void _reset() {
    _nameController.clear();
    _unitsController.clear();
    setState(() {
      _calculatedBill = null;
      _generatedConsumer = null;
      _selectedConsumerType = 'Residential';
      _selectedUtility = UtilityType.electricity;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utility Bill Generator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
            tooltip: 'Reset Form',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputCard(),
            const SizedBox(height: 20),
            if (_calculatedBill != null && _generatedConsumer != null)
              _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consumer Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(),
              const SizedBox(height: 10),
              
              // Name Input
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Consumer Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Consumer Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedConsumerType,
                decoration: const InputDecoration(
                  labelText: 'Consumer Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _consumerTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedConsumerType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Utility Type Segmented Button (or Row of Radio buttons)
              const Text('Utility Type:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<UtilityType>(
                      title: const Text('Electricity'),
                      value: UtilityType.electricity,
                      groupValue: _selectedUtility,
                      onChanged: (UtilityType? value) {
                        setState(() {
                          _selectedUtility = value!;
                        });
                      },
                      tileColor: _selectedUtility == UtilityType.electricity 
                          ? Colors.amber.withOpacity(0.1) 
                          : null,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RadioListTile<UtilityType>(
                      title: const Text('Water'),
                      value: UtilityType.water,
                      groupValue: _selectedUtility,
                      onChanged: (UtilityType? value) {
                        setState(() {
                          _selectedUtility = value!;
                        });
                      },
                      tileColor: _selectedUtility == UtilityType.water 
                          ? Colors.blue.withOpacity(0.1) 
                          : null,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Units Input
              TextFormField(
                controller: _unitsController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Units Consumed',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.speed),
                  suffixText: 'Units',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter units';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Generate Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _generateBill,
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('GENERATE BILL', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final isElectricity = _selectedUtility == UtilityType.electricity;
    final color = isElectricity ? Colors.amber : Colors.blue;
    final icon = isElectricity ? Icons.electric_bolt : Icons.water_drop;

    return Card(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(width: 10),
                Text(
                  'BILL SUMMARY',
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1.5, height: 30),
            
            _buildDetailRow('Customer Name:', _generatedConsumer!.name),
            _buildDetailRow('Consumer Type:', _generatedConsumer!.typeLabel),
            _buildDetailRow('Service:', isElectricity ? 'Electricity' : 'Water'),
            _buildDetailRow('Units Consumed:', '${_generatedConsumer!.unitsConsumed.toStringAsFixed(2)} Units'),
            
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rate Applied: ${_generatedConsumer!.getRateDescription(_selectedUtility)}',
                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL AMOUNT:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${_calculatedBill!.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        ],
      ),
    );
  }
}
