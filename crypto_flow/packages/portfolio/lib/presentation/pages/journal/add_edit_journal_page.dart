import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:design_system/design_system.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../bloc/journal/journal_bloc.dart';
import '../../bloc/journal/journal_event.dart';
import '../../widgets/journal/emotion_picker_widget.dart';
import '../../widgets/journal/strategy_selector_widget.dart';
import '../../../domain/entities/journal_entry.dart';
import '../../../domain/entities/trade_side.dart';
import '../../../domain/entities/trade_emotion.dart';

/// Page for adding or editing a journal entry
class AddEditJournalPage extends StatefulWidget {
  final JournalEntry? entry;

  const AddEditJournalPage({
    super.key,
    this.entry,
  });

  @override
  State<AddEditJournalPage> createState() => _AddEditJournalPageState();
}

class _AddEditJournalPageState extends State<AddEditJournalPage> {
  static const String _addTitle = 'Add Journal Entry';
  static const String _editTitle = 'Edit Journal Entry';
  static const String _symbolLabel = 'Symbol';
  static const String _symbolHint = 'e.g. BTCUSDT';
  static const String _entryPriceLabel = 'Entry Price';
  static const String _exitPriceLabel = 'Exit Price (Optional)';
  static const String _quantityLabel = 'Quantity';
  static const String _notesLabel = 'Notes';
  static const String _notesHint = 'What happened? What did you learn?';
  static const String _tagsLabel = 'Tags';
  static const String _screenshotLabel = 'Chart Screenshot (Optional)';
  static const String _entryDateLabel = 'Entry Date';
  static const String _exitDateLabel = 'Exit Date (Optional)';
  static const String _saveButton = 'Save';
  static const String _pickImageButton = 'Pick Image';
  static const String _removeImageButton = 'Remove';
  static const String _calculatedLabel = 'Calculated Values';
  static const String _requiredError = 'This field is required';
  static const String _invalidNumberError = 'Please enter a valid number';

  final _formKey = GlobalKey<FormState>();
  final _symbolController = TextEditingController();
  final _entryPriceController = TextEditingController();
  final _exitPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _imagePicker = ImagePicker();

  TradeSide _selectedSide = TradeSide.long;
  TradeEmotion _selectedEmotion = TradeEmotion.neutral;
  String? _selectedStrategy;
  List<String> _selectedTags = [];
  DateTime _entryDate = DateTime.now();
  DateTime? _exitDate;
  File? _selectedImage;
  String? _existingImagePath;

  // Calculated values
  double? _calculatedPnl;
  double? _calculatedPnlPercentage;
  double? _calculatedRR;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _loadExistingEntry();
    }

    // Listen to price changes for auto-calculation
    _entryPriceController.addListener(_calculateValues);
    _exitPriceController.addListener(_calculateValues);
    _quantityController.addListener(_calculateValues);
  }

  void _loadExistingEntry() {
    final entry = widget.entry!;
    _symbolController.text = entry.symbol;
    _selectedSide = entry.side;
    _entryPriceController.text = entry.entryPrice.toString();
    _exitPriceController.text = entry.exitPrice?.toString() ?? '';
    _quantityController.text = entry.quantity.toString();
    _selectedEmotion = entry.emotion;
    _selectedStrategy = entry.strategy;
    _notesController.text = entry.notes ?? '';
    _selectedTags = List.from(entry.tags);
    _entryDate = entry.entryDate;
    _exitDate = entry.exitDate;
    _existingImagePath = entry.screenshotPath;

    _calculatedPnl = entry.pnl;
    _calculatedPnlPercentage = entry.pnlPercentage;
    _calculatedRR = entry.riskRewardRatio;
  }

  void _calculateValues() {
    final entryPrice = double.tryParse(_entryPriceController.text);
    final exitPrice = double.tryParse(_exitPriceController.text);
    final quantity = double.tryParse(_quantityController.text);

    if (entryPrice != null && exitPrice != null && quantity != null) {
      setState(() {
        final difference = exitPrice - entryPrice;
        if (_selectedSide == TradeSide.long) {
          _calculatedPnl = difference * quantity;
          _calculatedPnlPercentage = (difference / entryPrice) * 100;
        } else {
          _calculatedPnl = -difference * quantity;
          _calculatedPnlPercentage = -(difference / entryPrice) * 100;
        }
        // Simple R:R calculation (assuming 1% risk)
        _calculatedRR = _calculatedPnlPercentage?.abs();
      });
    } else {
      setState(() {
        _calculatedPnl = null;
        _calculatedPnlPercentage = null;
        _calculatedRR = null;
      });
    }
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _entryPriceController.dispose();
    _exitPriceController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.entry != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? _editTitle : _addTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.paddingMD,
          children: [
            // Symbol
            TextFormField(
              controller: _symbolController,
              decoration: InputDecoration(
                labelText: _symbolLabel,
                hintText: _symbolHint,
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return _requiredError;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Side toggle
            Text('Side', style: AppTypography.body1),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<TradeSide>(
              segments: const [
                ButtonSegment<TradeSide>(
                  value: TradeSide.long,
                  label: Text('Long'),
                  icon: Icon(Icons.trending_up),
                ),
                ButtonSegment<TradeSide>(
                  value: TradeSide.short,
                  label: Text('Short'),
                  icon: Icon(Icons.trending_down),
                ),
              ],
              selected: {_selectedSide},
              onSelectionChanged: (Set<TradeSide> newSelection) {
                setState(() {
                  _selectedSide = newSelection.first;
                  _calculateValues();
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Entry Price
            TextFormField(
              controller: _entryPriceController,
              decoration: const InputDecoration(
                labelText: _entryPriceLabel,
                prefixText: '\$ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return _requiredError;
                }
                if (double.tryParse(value) == null) {
                  return _invalidNumberError;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Exit Price
            TextFormField(
              controller: _exitPriceController,
              decoration: const InputDecoration(
                labelText: _exitPriceLabel,
                prefixText: '\$ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Quantity
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: _quantityLabel,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return _requiredError;
                }
                if (double.tryParse(value) == null) {
                  return _invalidNumberError;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Calculated values display
            if (_calculatedPnl != null) ...[
              Container(
                padding: AppSpacing.paddingMD,
                decoration: BoxDecoration(
                  color: CryptoColors.surfaceBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(color: CryptoColors.borderDark),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _calculatedLabel,
                      style: AppTypography.body2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('P&L:', style: AppTypography.body2),
                        Text(
                          '${_calculatedPnl! >= 0 ? '+' : ''}\$${_calculatedPnl!.toStringAsFixed(2)}',
                          style: AppTypography.body2.copyWith(
                            color: CryptoColors.getPriceColor(_calculatedPnl!),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (_calculatedPnlPercentage != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('P&L %:', style: AppTypography.body2),
                          Text(
                            '${_calculatedPnlPercentage! >= 0 ? '+' : ''}${_calculatedPnlPercentage!.toStringAsFixed(2)}%',
                            style: AppTypography.body2.copyWith(
                              color: CryptoColors.getPriceColor(
                                  _calculatedPnlPercentage!),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_calculatedRR != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('R:R:', style: AppTypography.body2),
                          Text(
                            _calculatedRR!.toStringAsFixed(2),
                            style: AppTypography.body2.copyWith(
                              color: CryptoColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Strategy
            StrategySelectorWidget(
              selectedStrategy: _selectedStrategy,
              onStrategyChanged: (strategy) {
                setState(() {
                  _selectedStrategy = strategy;
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Emotion
            EmotionPickerWidget(
              selectedEmotion: _selectedEmotion,
              onEmotionSelected: (emotion) {
                setState(() {
                  _selectedEmotion = emotion;
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Tags
            Text(_tagsLabel, style: AppTypography.body1),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ..._selectedTags.map((tag) => Chip(
                      label: Text(tag),
                      onDeleted: () {
                        setState(() {
                          _selectedTags.remove(tag);
                        });
                      },
                    )),
                ActionChip(
                  label: const Text('+ Add Tag'),
                  onPressed: _showAddTagDialog,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: _notesLabel,
                hintText: _notesHint,
                alignLabelWithHint: true,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: AppSpacing.md),

            // Screenshot
            Text(_screenshotLabel, style: AppTypography.body1),
            const SizedBox(height: AppSpacing.sm),
            if (_selectedImage != null || _existingImagePath != null) ...[
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: CryptoColors.surfaceBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(color: CryptoColors.borderDark),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: _selectedImage != null
                          ? Image.file(_selectedImage!, fit: BoxFit.cover)
                          : _existingImagePath != null
                              ? Image.file(
                                  File(_existingImagePath!),
                                  fit: BoxFit.cover,
                                )
                              : const SizedBox(),
                    ),
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                            _existingImagePath = null;
                          });
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: CryptoColors.error,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text(_pickImageButton),
            ),
            const SizedBox(height: AppSpacing.md),

            // Entry Date
            ListTile(
              title: const Text(_entryDateLabel),
              subtitle: Text(
                '${_entryDate.year}-${_entryDate.month.toString().padLeft(2, '0')}-${_entryDate.day.toString().padLeft(2, '0')} ${_entryDate.hour.toString().padLeft(2, '0')}:${_entryDate.minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDateTime(true),
              contentPadding: EdgeInsets.zero,
            ),

            // Exit Date
            ListTile(
              title: const Text(_exitDateLabel),
              subtitle: Text(
                _exitDate != null
                    ? '${_exitDate!.year}-${_exitDate!.month.toString().padLeft(2, '0')}-${_exitDate!.day.toString().padLeft(2, '0')} ${_exitDate!.hour.toString().padLeft(2, '0')}:${_exitDate!.minute.toString().padLeft(2, '0')}'
                    : 'Not set',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_exitDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _exitDate = null;
                        });
                      },
                    ),
                  const Icon(Icons.calendar_today),
                ],
              ),
              onTap: () => _selectDateTime(false),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Save button
            ElevatedButton(
              onPressed: _saveEntry,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(_saveButton),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _existingImagePath = null;
      });
    }
  }

  Future<void> _selectDateTime(bool isEntry) async {
    final initialDate = isEntry ? _entryDate : (_exitDate ?? DateTime.now());

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (time != null) {
        setState(() {
          final newDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          if (isEntry) {
            _entryDate = newDateTime;
          } else {
            _exitDate = newDateTime;
          }
        });
      }
    }
  }

  void _showAddTagDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Tag name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _selectedTags.add(controller.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _saveEntry() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final entryPrice = double.parse(_entryPriceController.text);
    final exitPrice = _exitPriceController.text.isNotEmpty
        ? double.parse(_exitPriceController.text)
        : null;
    final quantity = double.parse(_quantityController.text);

    final imagePath = _selectedImage?.path ?? _existingImagePath;

    final now = DateTime.now();
    final entry = JournalEntry(
      id: widget.entry?.id ?? 0,
      symbol: _symbolController.text.toUpperCase(),
      side: _selectedSide,
      entryPrice: entryPrice,
      exitPrice: exitPrice,
      quantity: quantity,
      pnl: _calculatedPnl,
      pnlPercentage: _calculatedPnlPercentage,
      riskRewardRatio: _calculatedRR,
      strategy: _selectedStrategy,
      emotion: _selectedEmotion,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      tags: _selectedTags,
      screenshotPath: imagePath,
      entryDate: _entryDate,
      exitDate: _exitDate,
      createdAt: widget.entry?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.entry == null) {
      context.read<JournalBloc>().add(JournalEntryAdded(entry));
    } else {
      context.read<JournalBloc>().add(JournalEntryUpdated(entry));
    }

    Navigator.pop(context);
  }
}
