import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Widget for selecting trading strategy
class StrategySelectorWidget extends StatefulWidget {
  final String? selectedStrategy;
  final ValueChanged<String> onStrategyChanged;

  const StrategySelectorWidget({
    super.key,
    this.selectedStrategy,
    required this.onStrategyChanged,
  });

  @override
  State<StrategySelectorWidget> createState() => _StrategySelectorWidgetState();
}

class _StrategySelectorWidgetState extends State<StrategySelectorWidget> {
  static const String _label = 'Strategy';
  static const String _hint = 'Select strategy';
  static const String _customOption = 'Other';
  static const String _customHint = 'Enter custom strategy';

  static const List<String> _predefinedStrategies = [
    'Breakout',
    'Support/Resistance',
    'Trend Following',
    'Scalp',
    'News',
    _customOption,
  ];

  late TextEditingController _customController;
  bool _isCustom = false;

  @override
  void initState() {
    super.initState();
    _customController = TextEditingController();

    // Check if current selection is custom
    if (widget.selectedStrategy != null &&
        !_predefinedStrategies.contains(widget.selectedStrategy)) {
      _isCustom = true;
      _customController.text = widget.selectedStrategy!;
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _isCustom ? _customOption : widget.selectedStrategy,
          decoration: InputDecoration(
            labelText: _label,
            hintText: _hint,
            filled: true,
            fillColor: CryptoColors.surfaceBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              borderSide: const BorderSide(color: CryptoColors.borderDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              borderSide: const BorderSide(color: CryptoColors.borderDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              borderSide:
                  const BorderSide(color: CryptoColors.primary, width: 2),
            ),
          ),
          items: _predefinedStrategies.map((strategy) {
            return DropdownMenuItem<String>(
              value: strategy,
              child: Text(strategy),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              if (value == _customOption) {
                _isCustom = true;
              } else {
                _isCustom = false;
                if (value != null) {
                  widget.onStrategyChanged(value);
                }
              }
            });
          },
        ),
        if (_isCustom) ...[
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _customController,
            decoration: InputDecoration(
              hintText: _customHint,
              filled: true,
              fillColor: CryptoColors.surfaceBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                borderSide: const BorderSide(color: CryptoColors.borderDark),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                borderSide: const BorderSide(color: CryptoColors.borderDark),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                borderSide:
                    const BorderSide(color: CryptoColors.primary, width: 2),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                widget.onStrategyChanged(value);
              }
            },
          ),
        ],
      ],
    );
  }
}
