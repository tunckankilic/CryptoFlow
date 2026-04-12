import '../../domain/entities/automation_rule.dart';

class AutomationRuleModel {
  final Map<String, dynamic> _json;
  AutomationRuleModel.fromJson(this._json);

  AutomationRule toEntity() {
    final triggerJson = _json['trigger'] as Map<String, dynamic>? ?? {};
    final actionJson = _json['action'] as Map<String, dynamic>? ?? {};

    return AutomationRule(
      ruleId: _json['ruleId'] as String? ?? '',
      name: _json['name'] as String? ?? '',
      enabled: _json['enabled'] == true || _json['enabled'] == 'true',
      trigger: RuleTrigger(
        type: _parseTriggerType(triggerJson['type'] as String? ?? ''),
        symbol: triggerJson['symbol'] as String?,
        value: (triggerJson['value'] as num?)?.toDouble(),
        schedule: triggerJson['schedule'] as String?,
      ),
      action: RuleAction(
        type: _parseActionType(actionJson['type'] as String? ?? ''),
        payload: actionJson['payload'] as Map<String, dynamic>?,
      ),
      lastTriggeredAt: _json['lastTriggeredAt'] as String?,
      createdAt: _json['createdAt'] as String? ?? '',
    );
  }

  static TriggerType _parseTriggerType(String type) {
    switch (type) {
      case 'priceAbove':
        return TriggerType.priceAbove;
      case 'priceBelow':
        return TriggerType.priceBelow;
      case 'percentChange':
        return TriggerType.percentChange;
      case 'timeSchedule':
        return TriggerType.timeSchedule;
      default:
        return TriggerType.priceAbove;
    }
  }

  static ActionType _parseActionType(String type) {
    switch (type) {
      case 'sendNotification':
        return ActionType.sendNotification;
      case 'addToWatchlist':
        return ActionType.addToWatchlist;
      case 'removeAlert':
        return ActionType.removeAlert;
      default:
        return ActionType.sendNotification;
    }
  }

  static Map<String, dynamic> toCreateJson({
    required String name,
    required RuleTrigger trigger,
    required RuleAction action,
  }) {
    return {
      'name': name,
      'trigger': {
        'type': trigger.type.name,
        if (trigger.symbol != null) 'symbol': trigger.symbol,
        if (trigger.value != null) 'value': trigger.value,
        if (trigger.schedule != null) 'schedule': trigger.schedule,
      },
      'action': {
        'type': action.type.name,
        if (action.payload != null) 'payload': action.payload,
      },
    };
  }
}
