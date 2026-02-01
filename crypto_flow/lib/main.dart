import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app.dart';
import 'di/injection_container.dart';
import 'firebase_messaging_background_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register background message handler (must be before Firebase init)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize dependencies
  await configureDependencies();

  runApp(const CryptoFlowApp());
}
