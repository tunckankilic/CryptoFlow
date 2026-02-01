import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:notifications/notifications.dart';

// Mocks
class MockInitializeNotifications extends Mock
    implements InitializeNotifications {}

class MockRequestPermission extends Mock implements RequestPermission {}

class MockGetFCMToken extends Mock implements GetFCMToken {}

class MockSubscribeToTopic extends Mock implements SubscribeToTopic {}

class MockUnsubscribeFromTopic extends Mock implements UnsubscribeFromTopic {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late NotificationBloc bloc;
  late MockInitializeNotifications mockInitialize;
  late MockRequestPermission mockRequestPermission;
  late MockGetFCMToken mockGetFCMToken;
  late MockSubscribeToTopic mockSubscribeToTopic;
  late MockUnsubscribeFromTopic mockUnsubscribeFromTopic;
  late MockNotificationRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(NotificationSettings.defaults());
  });

  setUp(() {
    mockInitialize = MockInitializeNotifications();
    mockRequestPermission = MockRequestPermission();
    mockGetFCMToken = MockGetFCMToken();
    mockSubscribeToTopic = MockSubscribeToTopic();
    mockUnsubscribeFromTopic = MockUnsubscribeFromTopic();
    mockRepository = MockNotificationRepository();

    // Setup default stream behaviors
    when(() => mockRepository.onTokenRefresh)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.onMessage)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockRepository.onMessageOpenedApp)
        .thenAnswer((_) => const Stream.empty());

    bloc = NotificationBloc(
      initializeNotifications: mockInitialize,
      requestPermission: mockRequestPermission,
      getFCMToken: mockGetFCMToken,
      subscribeToTopic: mockSubscribeToTopic,
      unsubscribeFromTopic: mockUnsubscribeFromTopic,
      repository: mockRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('NotificationBloc', () {
    test('initial state is NotificationInitial', () {
      expect(bloc.state, isA<NotificationInitial>());
    });

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationReady] when initialization succeeds',
      build: () {
        when(() => mockInitialize(any())).thenAnswer(
          (_) async => const Right(null),
        );
        when(() => mockRepository.getSettings()).thenAnswer(
          (_) async => Right(NotificationSettings.defaults()),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const InitializeNotificationsEvent()),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationReady>(),
      ],
      verify: (_) {
        verify(() => mockInitialize(any())).called(1);
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationError] when initialization fails',
      build: () {
        when(() => mockInitialize(any())).thenAnswer(
          (_) async => Left(CacheFailure(message: 'Failed to initialize')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const InitializeNotificationsEvent()),
      expect: () => [
        isA<NotificationLoading>(),
        isA<NotificationError>(),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'updates price alerts setting when TogglePriceAlerts is added',
      build: () {
        when(() => mockRepository.updateSettings(any())).thenAnswer(
          (_) async => const Right(null),
        );
        return bloc;
      },
      seed: () => NotificationReady(settings: NotificationSettings.defaults()),
      act: (bloc) => bloc.add(const TogglePriceAlerts(enabled: false)),
      expect: () => [
        isA<NotificationReady>().having(
          (s) => s.settings.priceAlerts,
          'priceAlerts',
          false,
        ),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'updates sound setting when ToggleSoundEnabled is added',
      build: () {
        when(() => mockRepository.updateSettings(any())).thenAnswer(
          (_) async => const Right(null),
        );
        return bloc;
      },
      seed: () => NotificationReady(settings: NotificationSettings.defaults()),
      act: (bloc) => bloc.add(const ToggleSoundEnabled(enabled: false)),
      expect: () => [
        isA<NotificationReady>().having(
          (s) => s.settings.soundEnabled,
          'soundEnabled',
          false,
        ),
      ],
    );
  });
}
