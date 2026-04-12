import 'package:equatable/equatable.dart';

enum TriggerType {
  priceAbove('Price Above'),
  priceBelow('Price Below'),
  percentChange('Percent Change'),
  timeSchedule('Time Schedule');

  final String displayName;
  const TriggerType(this.displayName);
}

enum ActionType {
  sendNotification('Send Notification'),
  addToWatchlist('Add to Watchlist'),
  removeAlert('Remove Alert');

  final String displayName;
  const ActionType(this.displayName);
}

class RuleTrigger extends Equatable {
  final TriggerType type;
  final String? symbol;
  final double? value;
  final String? schedule;

  const RuleTrigger({
    required this.type,
    this.symbol,
    this.value,
    this.schedule,
  });

  @override
  List<Object?> get props => [type, symbol, value, schedule];
}

class RuleAction extends Equatable {
  final ActionType type;
  final Map<String, dynamic>? payload;

  const RuleAction({required this.type, this.payload});

  @override
  List<Object?> get props => [type, payload];
}

class AutomationRule extends Equatable {
  final String ruleId;
  final String name;
  final bool enabled;
  final RuleTrigger trigger;
  final RuleAction action;
  final String? lastTriggeredAt;
  final String createdAt;

  const AutomationRule({
    required this.ruleId,
    required this.name,
    required this.enabled,
    required this.trigger,
    required this.action,
    this.lastTriggeredAt,
    required this.createdAt,
  });

  AutomationRule copyWith({bool? enabled}) => AutomationRule(
        ruleId: ruleId,
        name: name,
        enabled: enabled ?? this.enabled,
        trigger: trigger,
        action: action,
        lastTriggeredAt: lastTriggeredAt,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [ruleId, name, enabled, trigger, action, lastTriggeredAt, createdAt];
}
