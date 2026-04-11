import 'package:flutter/services.dart' show rootBundle;

/// Loads the bundled `amplify_outputs.json` and returns its raw contents.
///
/// The file is environment-specific and copied into the project root by the
/// CI pipeline (or manually by developers via
/// `cp config/amplify_outputs.dev.json crypto_flow/amplify_outputs.json`).
/// It is registered as a Flutter asset in the top-level `pubspec.yaml`.
Future<String> loadAmplifyConfig() async {
  return rootBundle.loadString('amplify_outputs.json');
}
