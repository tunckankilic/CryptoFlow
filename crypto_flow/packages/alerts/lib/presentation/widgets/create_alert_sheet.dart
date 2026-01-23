import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/price_alert.dart';
import '../bloc/alert_bloc.dart';
import '../bloc/alert_event.dart';
import 'package:design_system/design_system.dart';

/// Bottom sheet for creating a new alert
class CreateAlertSheet extends StatefulWidget {
  const CreateAlertSheet({super.key});

  @override
  State<CreateAlertSheet> createState() => _CreateAlertSheetState();
}

class _CreateAlertSheetState extends State<CreateAlertSheet> {
  final _formKey = GlobalKey<FormState>();
  final _symbolController = TextEditingController();
  final _targetPriceController = TextEditingController();
  final _percentChangeController = TextEditingController();
  final _noteController = TextEditingController();

  AlertType _selectedType = AlertType.above;
  bool _repeatEnabled = false;

  @override
  void dispose() {
    _symbolController.dispose();
    _targetPriceController.dispose();
    _percentChangeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: AppSpacing.paddingLG,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Create Alert', style: AppTypography.h3),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Symbol
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

                // Alert type
                DropdownButtonFormField<AlertType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Alert Type',
                    prefixIcon: Icon(Icons.notifications),
                  ),
                  items: AlertType.values.map((type) {
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

                // Target price (for above/below) or percent (for percent alerts)
                if (_isPercentAlert) ...[
                  TextFormField(
                    controller: _percentChangeController,
                    decoration: const InputDecoration(
                      labelText: 'Percent Change',
                      hintText: '10',
                      prefixIcon: Icon(Icons.percent),
                      suffixText: '%',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter percent change';
                      }
                      final percent = double.tryParse(value);
                      if (percent == null || percent <= 0) {
                        return 'Please enter a valid percentage';
                      }
                      return null;
                    },
                  ),
                ] else ...[
                  TextFormField(
                    controller: _targetPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Target Price',
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
                        return 'Please enter target price';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),

                // Note
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    hintText: 'Add a note...',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Repeat toggle
                SwitchListTile(
                  title: const Text('Repeat alert'),
                  subtitle: const Text('Keep alert active after triggering'),
                  value: _repeatEnabled,
                  onChanged: (value) {
                    setState(() {
                      _repeatEnabled = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Submit button
                ElevatedButton(
                  onPressed: _submitAlert,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Create Alert'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _isPercentAlert =>
      _selectedType == AlertType.percentUp ||
      _selectedType == AlertType.percentDown;

  void _submitAlert() {
    if (_formKey.currentState!.validate()) {
      final alert = PriceAlert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        symbol: _symbolController.text.toUpperCase(),
        type: _selectedType,
        targetPrice: _isPercentAlert
            ? 0.0 // Will be calculated based on current price
            : double.parse(_targetPriceController.text),
        percentChange: _isPercentAlert
            ? double.parse(_percentChangeController.text)
            : null,
        basePrice: _isPercentAlert
            ? 0.0 // Should be set to current price when creating
            : null,
        isActive: true,
        isTriggered: false,
        createdAt: DateTime.now(),
        repeatEnabled: _repeatEnabled,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      context.read<AlertBloc>().add(CreateAlertEvent(alert));
      Navigator.pop(context);
    }
  }
}
