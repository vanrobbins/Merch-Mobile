import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Log all unhandled Flutter/Dart errors instead of crashing.
  // Remove or tighten once the crash source is identified.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('⛔ FLUTTER ERROR: ${details.exception}');
    debugPrint(details.stack.toString());
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('⛔ ASYNC ERROR: $error');
    debugPrint(stack.toString());
    return true; // handled — prevents process exit
  };

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  runApp(const ProviderScope(child: MerchMobileApp()));
}
