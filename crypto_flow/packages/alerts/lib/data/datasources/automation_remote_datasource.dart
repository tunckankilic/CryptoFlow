import 'package:core/core.dart';
import '../models/automation_rule_model.dart';
import '../../domain/entities/automation_rule.dart';

abstract class AutomationRemoteDataSource {
  Future<List<AutomationRuleModel>> listRules();
  Future<AutomationRuleModel> createRule({
    required String name,
    required RuleTrigger trigger,
    required RuleAction action,
  });
  Future<void> toggleRule(String ruleId, bool enabled);
  Future<void> deleteRule(String ruleId);
}

class AutomationRemoteDataSourceImpl implements AutomationRemoteDataSource {
  final AwsApiClient _client;

  AutomationRemoteDataSourceImpl({required AwsApiClient client})
      : _client = client;

  static const _basePath = '/api/v1/automation/rules';

  @override
  Future<List<AutomationRuleModel>> listRules() async {
    final response = await _client.get(_basePath);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => AutomationRuleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AutomationRuleModel> createRule({
    required String name,
    required RuleTrigger trigger,
    required RuleAction action,
  }) async {
    final body = AutomationRuleModel.toCreateJson(
      name: name,
      trigger: trigger,
      action: action,
    );
    final response = await _client.post(_basePath, data: body);
    return AutomationRuleModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> toggleRule(String ruleId, bool enabled) async {
    await _client.put('$_basePath/$ruleId', data: {'enabled': enabled});
  }

  @override
  Future<void> deleteRule(String ruleId) async {
    await _client.delete('$_basePath/$ruleId');
  }
}
