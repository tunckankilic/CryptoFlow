import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/portfolio_bloc.dart';
import '../bloc/portfolio_event.dart';
import 'package:design_system/design_system.dart';

/// Page for adding or editing a transaction
class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _feeController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.buy;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _symbolController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _feeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.paddingLG,
          children: [
            // Symbol field
            TextFormField(
              controller: _symbolController,
              decoration: const InputDecoration(
                labelText: 'Symbol',
                hintText: 'e.g., BTCUSDT',
                prefixIcon: Icon(Icons.currency_bitcoin),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a symbol';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Transaction type
            DropdownButtonFormField<TransactionType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                prefixIcon: Icon(Icons.swap_horiz),
              ),
              items: TransactionType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Quantity
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                hintText: '0.00',
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                final quantity = double.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return 'Please enter a valid quantity';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Price
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                hintText: '0.00',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter price';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'Please enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Fee (optional)
            TextFormField(
              controller: _feeController,
              decoration: const InputDecoration(
                labelText: 'Fee (optional)',
                hintText: '0.00',
                prefixIcon: Icon(Icons.money_off),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            const SizedBox(height: 16),

            // Date/Time picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date & Time'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} '
                '${_selectedDate.hour}:${_selectedDate.minute.toString().padLeft(2, '0')}',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );

                if (date != null && mounted) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedDate),
                  );

                  if (time != null) {
                    setState(() {
                      _selectedDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 16),

            // Note (optional)
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'Add a note...',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Submit button
            ElevatedButton(
              onPressed: _submitTransaction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitTransaction() {
    if (_formKey.currentState!.validate()) {
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        symbol: _symbolController.text.toUpperCase(),
        type: _selectedType,
        quantity: double.parse(_quantityController.text),
        price: double.parse(_priceController.text),
        fee: _feeController.text.isNotEmpty
            ? double.parse(_feeController.text)
            : null,
        feeAsset: null,
        timestamp: _selectedDate,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      context.read<PortfolioBloc>().add(AddTransactionEvent(transaction));
      Navigator.pop(context);
    }
  }
}
