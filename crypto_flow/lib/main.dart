import 'package:flutter/material.dart';
import 'app.dart';
import 'di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await configureDependencies();

  runApp(const CryptoFlowApp());
}
