import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// SyncService — no-op after Firestore migration.
///
/// Firestore handles real-time sync natively (including offline persistence).
/// This class is kept as a stub so existing call-sites compile without changes.
class SyncService {
  final Ref _ref;
  SyncService(this._ref);

  /// No-op: Firestore sync is automatic.
  Future<void> syncAll() async {
    debugPrint('SyncService[$_ref]: Firestore handles sync automatically.');
  }
}
