import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:design_system/design_system.dart';
import '../../domain/entities/automation_rule.dart';
import '../bloc/automation/automation_bloc.dart';

/// IFTTT-style automation rule builder page
class AutomationBuilderPage extends StatefulWidget {
  const AutomationBuilderPage({super.key});

  @override
  State<AutomationBuilderPage> createState() => _AutomationBuilderPageState();
}

class _AutomationBuilderPageState extends State<AutomationBuilderPage> {
  @override
  void initState() {
    super.initState();
    context.read<AutomationBloc>().add(const AutomationLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Automation Rules')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<AutomationBloc, AutomationState>(
        builder: (context, state) {
          if (state is AutomationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AutomationError) {
            return Center(child: Text(state.message));
          }
          if (state is AutomationLoaded) {
            if (state.rules.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_fix_high, size: 64, color: CryptoColors.textTertiary),
                    SizedBox(height: AppSpacing.md),
                    Text('No automation rules yet',
                        style: TextStyle(color: CryptoColors.textTertiary)),
                    SizedBox(height: AppSpacing.sm),
                    Text('Tap + to create your first rule',
                        style: TextStyle(color: CryptoColors.textTertiary, fontSize: 13)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.rules.length,
              itemBuilder: (context, index) => _RuleTile(rule: state.rules[index]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<AutomationBloc>(),
        child: const _CreateRuleSheet(),
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  final AutomationRule rule;
  const _RuleTile({required this.rule});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          _triggerIcon(rule.trigger.type),
          color: rule.enabled ? CryptoColors.success : CryptoColors.textTertiary,
        ),
        title: Text(rule.name),
        subtitle: Text(
          'IF ${rule.trigger.type.displayName}'
          '${rule.trigger.symbol != null ? ' (${rule.trigger.symbol})' : ''}'
          ' → ${rule.action.type.displayName}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: rule.enabled,
              onChanged: (v) {
                context.read<AutomationBloc>().add(
                      AutomationRuleToggled(ruleId: rule.ruleId, enabled: v),
                    );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: CryptoColors.error),
              onPressed: () {
                context.read<AutomationBloc>().add(AutomationRuleDeleted(rule.ruleId));
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _triggerIcon(TriggerType type) {
    switch (type) {
      case TriggerType.priceAbove:
        return Icons.trending_up;
      case TriggerType.priceBelow:
        return Icons.trending_down;
      case TriggerType.percentChange:
        return Icons.percent;
      case TriggerType.timeSchedule:
        return Icons.schedule;
    }
  }
}

class _CreateRuleSheet extends StatefulWidget {
  const _CreateRuleSheet();

  @override
  State<_CreateRuleSheet> createState() => _CreateRuleSheetState();
}

class _CreateRuleSheetState extends State<_CreateRuleSheet> {
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _valueController = TextEditingController();
  TriggerType _triggerType = TriggerType.priceAbove;
  ActionType _actionType = ActionType.sendNotification;
  String _schedule = 'daily';

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  bool get _needsSymbol =>
      _triggerType == TriggerType.priceAbove ||
      _triggerType == TriggerType.priceBelow ||
      _triggerType == TriggerType.percentChange;

  bool get _needsValue =>
      _triggerType != TriggerType.timeSchedule;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Create Automation Rule', style: AppTypography.h5),
            const SizedBox(height: AppSpacing.md),

            // Rule name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Rule Name'),
            ),
            const SizedBox(height: AppSpacing.md),

            // IF section
            Text('IF (Trigger)', style: AppTypography.h6),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<TriggerType>(
              value: _triggerType,
              items: TriggerType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.displayName)))
                  .toList(),
              onChanged: (v) => setState(() => _triggerType = v!),
              decoration: const InputDecoration(labelText: 'Trigger Type'),
            ),
            if (_needsSymbol) ...[
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _symbolController,
                decoration: const InputDecoration(
                  labelText: 'Symbol',
                  hintText: 'BTCUSDT',
                ),
              ),
            ],
            if (_needsValue) ...[
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _triggerType == TriggerType.percentChange
                      ? 'Change %'
                      : 'Price (\$)',
                ),
              ),
            ],
            if (_triggerType == TriggerType.timeSchedule) ...[
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'hourly', label: Text('Hourly')),
                  ButtonSegment(value: 'daily', label: Text('Daily')),
                ],
                selected: {_schedule},
                onSelectionChanged: (s) => setState(() => _schedule = s.first),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),

            // THEN section
            Text('THEN (Action)', style: AppTypography.h6),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<ActionType>(
              value: _actionType,
              items: ActionType.values
                  .map((a) => DropdownMenuItem(value: a, child: Text(a.displayName)))
                  .toList(),
              onChanged: (v) => setState(() => _actionType = v!),
              decoration: const InputDecoration(labelText: 'Action Type'),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Create button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Create Rule'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_nameController.text.isEmpty) return;

    final trigger = RuleTrigger(
      type: _triggerType,
      symbol: _needsSymbol ? _symbolController.text : null,
      value: _needsValue ? double.tryParse(_valueController.text) : null,
      schedule: _triggerType == TriggerType.timeSchedule ? _schedule : null,
    );

    final action = RuleAction(type: _actionType);

    context.read<AutomationBloc>().add(AutomationRuleCreated(
          name: _nameController.text,
          trigger: trigger,
          action: action,
        ));

    Navigator.of(context).pop();
  }
}
