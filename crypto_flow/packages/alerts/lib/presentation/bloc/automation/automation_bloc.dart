import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/automation_remote_datasource.dart';
import '../../../domain/entities/automation_rule.dart';

// ── Events ──────────────────────────────────────────────────────────────────

abstract class AutomationEvent extends Equatable {
  const AutomationEvent();
  @override
  List<Object?> get props => [];
}

class AutomationLoadRequested extends AutomationEvent {
  const AutomationLoadRequested();
}

class AutomationRuleCreated extends AutomationEvent {
  final String name;
  final RuleTrigger trigger;
  final RuleAction action;

  const AutomationRuleCreated({
    required this.name,
    required this.trigger,
    required this.action,
  });

  @override
  List<Object?> get props => [name, trigger, action];
}

class AutomationRuleToggled extends AutomationEvent {
  final String ruleId;
  final bool enabled;
  const AutomationRuleToggled({required this.ruleId, required this.enabled});
  @override
  List<Object?> get props => [ruleId, enabled];
}

class AutomationRuleDeleted extends AutomationEvent {
  final String ruleId;
  const AutomationRuleDeleted(this.ruleId);
  @override
  List<Object?> get props => [ruleId];
}

// ── States ──────────────────────────────────────────────────────────────────

abstract class AutomationState extends Equatable {
  const AutomationState();
  @override
  List<Object?> get props => [];
}

class AutomationInitial extends AutomationState {
  const AutomationInitial();
}

class AutomationLoading extends AutomationState {
  const AutomationLoading();
}

class AutomationLoaded extends AutomationState {
  final List<AutomationRule> rules;
  const AutomationLoaded(this.rules);
  @override
  List<Object?> get props => [rules];
}

class AutomationError extends AutomationState {
  final String message;
  const AutomationError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ────────────────────────────────────────────────────────────────────

class AutomationBloc extends Bloc<AutomationEvent, AutomationState> {
  final AutomationRemoteDataSource _dataSource;

  AutomationBloc({required AutomationRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const AutomationInitial()) {
    on<AutomationLoadRequested>(_onLoad);
    on<AutomationRuleCreated>(_onCreate);
    on<AutomationRuleToggled>(_onToggle);
    on<AutomationRuleDeleted>(_onDelete);
  }

  Future<void> _onLoad(
      AutomationLoadRequested event, Emitter<AutomationState> emit) async {
    emit(const AutomationLoading());
    try {
      final models = await _dataSource.listRules();
      emit(AutomationLoaded(models.map((m) => m.toEntity()).toList()));
    } catch (e) {
      emit(AutomationError(e.toString()));
    }
  }

  Future<void> _onCreate(
      AutomationRuleCreated event, Emitter<AutomationState> emit) async {
    try {
      await _dataSource.createRule(
        name: event.name,
        trigger: event.trigger,
        action: event.action,
      );
      add(const AutomationLoadRequested()); // Refresh list
    } catch (e) {
      emit(AutomationError(e.toString()));
    }
  }

  Future<void> _onToggle(
      AutomationRuleToggled event, Emitter<AutomationState> emit) async {
    try {
      await _dataSource.toggleRule(event.ruleId, event.enabled);
      // Optimistic update
      if (state is AutomationLoaded) {
        final rules = (state as AutomationLoaded).rules.map((r) {
          return r.ruleId == event.ruleId
              ? r.copyWith(enabled: event.enabled)
              : r;
        }).toList();
        emit(AutomationLoaded(rules));
      }
    } catch (e) {
      emit(AutomationError(e.toString()));
    }
  }

  Future<void> _onDelete(
      AutomationRuleDeleted event, Emitter<AutomationState> emit) async {
    try {
      await _dataSource.deleteRule(event.ruleId);
      if (state is AutomationLoaded) {
        final rules = (state as AutomationLoaded)
            .rules
            .where((r) => r.ruleId != event.ruleId)
            .toList();
        emit(AutomationLoaded(rules));
      }
    } catch (e) {
      emit(AutomationError(e.toString()));
    }
  }
}
