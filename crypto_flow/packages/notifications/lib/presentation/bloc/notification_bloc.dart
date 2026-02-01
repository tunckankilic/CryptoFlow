import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/initialize_notifications.dart';
import '../../domain/usecases/request_permission.dart';
import '../../domain/usecases/get_fcm_token.dart';
import '../../domain/usecases/subscribe_to_topic.dart';
import '../../domain/usecases/unsubscribe_from_topic.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// BLoC for managing notification state
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final InitializeNotifications initializeNotifications;
  final RequestPermission requestPermission;
  final GetFCMToken getFCMToken;
  final SubscribeToTopic subscribeToTopic;
  final UnsubscribeFromTopic unsubscribeFromTopic;
  final NotificationRepository repository;

  StreamSubscription? _tokenRefreshSubscription;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _messageOpenedAppSubscription;

  NotificationBloc({
    required this.initializeNotifications,
    required this.requestPermission,
    required this.getFCMToken,
    required this.subscribeToTopic,
    required this.unsubscribeFromTopic,
    required this.repository,
  }) : super(const NotificationInitial()) {
    on<InitializeNotificationsEvent>(_onInitialize);
    on<RequestPermissionEvent>(_onRequestPermission);
    on<TokenRefreshed>(_onTokenRefreshed);
    on<NotificationReceived>(_onNotificationReceived);
    on<TogglePriceAlerts>(_onTogglePriceAlerts);
    on<TogglePortfolioAlerts>(_onTogglePortfolioAlerts);
    on<ToggleNewsAlerts>(_onToggleNewsAlerts);
    on<ToggleMarketUpdates>(_onToggleMarketUpdates);
    on<ToggleSoundEnabled>(_onToggleSoundEnabled);
    on<ToggleVibrationEnabled>(_onToggleVibrationEnabled);
    on<SubscribeToSymbol>(_onSubscribeToSymbol);
    on<UnsubscribeFromSymbol>(_onUnsubscribeFromSymbol);
    on<LoadSettings>(_onLoadSettings);

    _setupStreamListeners();
  }

  /// Initialize notifications
  Future<void> _onInitialize(
    InitializeNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await initializeNotifications(NoParams());

    await result.fold(
      (failure) async {
        emit(NotificationError(message: failure.message));
      },
      (_) async {
        // After initialization, load settings
        add(const LoadSettings());
      },
    );
  }

  /// Request permission
  Future<void> _onRequestPermission(
    RequestPermissionEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await requestPermission(NoParams());

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (settings) {
        if (!settings.priceAlerts && !settings.portfolioAlerts) {
          emit(const NotificationPermissionDenied());
        } else {
          emit(NotificationReady(settings: settings));
        }
      },
    );
  }

  /// Load settings
  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await repository.getSettings();

    result.fold(
      (failure) => emit(NotificationError(message: failure.message)),
      (settings) => emit(NotificationReady(settings: settings)),
    );
  }

  /// Token refreshed
  Future<void> _onTokenRefreshed(
    TokenRefreshed event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationReady) {
      final currentState = state as NotificationReady;
      final updatedSettings = currentState.settings.copyWith(
        fcmToken: event.token,
      );
      await repository.updateSettings(updatedSettings);
      emit(currentState.copyWith(settings: updatedSettings));
    }
  }

  /// Notification received
  Future<void> _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationReady) {
      final currentState = state as NotificationReady;
      final updatedNotifications = [
        event.notification,
        ...currentState.recentNotifications,
      ].take(10).toList(); // Keep only last 10

      emit(currentState.copyWith(recentNotifications: updatedNotifications));
    }
  }

  /// Toggle price alerts
  Future<void> _onTogglePriceAlerts(
    TogglePriceAlerts event,
    Emitter<NotificationState> emit,
  ) async {
    await _updateSetting(
      emit,
      (settings) => settings.copyWith(priceAlerts: event.enabled),
    );
  }

  /// Toggle portfolio alerts
  Future<void> _onTogglePortfolioAlerts(
    TogglePortfolioAlerts event,
    Emitter<NotificationState> emit,
  ) async {
    await _updateSetting(
      emit,
      (settings) => settings.copyWith(portfolioAlerts: event.enabled),
    );
  }

  /// Toggle news alerts
  Future<void> _onToggleNewsAlerts(
    ToggleNewsAlerts event,
    Emitter<NotificationState> emit,
  ) async {
    await _updateSetting(
      emit,
      (settings) => settings.copyWith(newsAlerts: event.enabled),
    );
  }

  /// Toggle market updates
  Future<void> _onToggleMarketUpdates(
    ToggleMarketUpdates event,
    Emitter<NotificationState> emit,
  ) async {
    await _updateSetting(
      emit,
      (settings) => settings.copyWith(marketUpdates: event.enabled),
    );
  }

  /// Toggle sound
  Future<void> _onToggleSoundEnabled(
    ToggleSoundEnabled event,
    Emitter<NotificationState> emit,
  ) async {
    await _updateSetting(
      emit,
      (settings) => settings.copyWith(soundEnabled: event.enabled),
    );
  }

  /// Toggle vibration
  Future<void> _onToggleVibrationEnabled(
    ToggleVibrationEnabled event,
    Emitter<NotificationState> emit,
  ) async {
    await _updateSetting(
      emit,
      (settings) => settings.copyWith(vibrationEnabled: event.enabled),
    );
  }

  /// Subscribe to symbol
  Future<void> _onSubscribeToSymbol(
    SubscribeToSymbol event,
    Emitter<NotificationState> emit,
  ) async {
    await subscribeToTopic(SubscribeToTopicParams(topic: event.symbol));
  }

  /// Unsubscribe from symbol
  Future<void> _onUnsubscribeFromSymbol(
    UnsubscribeFromSymbol event,
    Emitter<NotificationState> emit,
  ) async {
    await unsubscribeFromTopic(UnsubscribeFromTopicParams(topic: event.symbol));
  }

  /// Helper to update settings
  Future<void> _updateSetting(
    Emitter<NotificationState> emit,
    Function(dynamic) updateFn,
  ) async {
    if (state is NotificationReady) {
      final currentState = state as NotificationReady;
      final updatedSettings = updateFn(currentState.settings);
      await repository.updateSettings(updatedSettings);
      emit(currentState.copyWith(settings: updatedSettings));
    }
  }

  /// Setup stream listeners
  void _setupStreamListeners() {
    // Listen to token refresh
    _tokenRefreshSubscription = repository.onTokenRefresh.listen((token) {
      add(TokenRefreshed(token: token));
    });

    // Listen to foreground messages
    _messageSubscription = repository.onMessage.listen((notification) {
      add(NotificationReceived(notification: notification));
    });

    // Listen to messages that opened app
    _messageOpenedAppSubscription =
        repository.onMessageOpenedApp.listen((notification) {
      add(NotificationReceived(notification: notification));
      // TODO: Handle navigation to relevant screen
    });
  }

  @override
  Future<void> close() {
    _tokenRefreshSubscription?.cancel();
    _messageSubscription?.cancel();
    _messageOpenedAppSubscription?.cancel();
    return super.close();
  }
}
