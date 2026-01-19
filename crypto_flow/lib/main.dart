import 'package:flutter/material.dart';
import 'package:crypto_flow/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Initialize dependency injection
  // await configureDependencies();

  // TODO: Initialize Hive for local storage
  // await Hive.initFlutter();

  runApp(const CryptoFlowApp());
}
