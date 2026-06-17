import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'di/injection_container.dart';

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

  await _configureAmplify();
  await configureDependencies();

  await getIt<WidgetDataService>().initialize();

  runApp(const CryptoWaveApp());
}
