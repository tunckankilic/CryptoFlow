import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:core/core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'di/injection_container.dart';
import 'firebase_messaging_background_handler.dart';

Future<void> _configureAmplify() async {
  if (Amplify.isConfigured) return;
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    final cfg = await loadAmplifyConfig();
    await Amplify.configure(cfg);
  } on AmplifyAlreadyConfiguredException {
    // ignore — hot restart
  } on AmplifyException catch (e) {
    debugPrint('Amplify configuration failed: ${e.message}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register background message handler (must be before Firebase init)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize dependencies (also initializes Firebase)
  await configureDependencies();

  if (FeatureFlags.useCognitoAuth) {
    await _configureAmplify();
  }

  runApp(const CryptoWaveApp());
}
