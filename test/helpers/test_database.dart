import 'package:drift/native.dart';
import 'package:merch_mobile/core/database/app_database.dart';

/// Creates an in-memory [AppDatabase] for unit tests.
///
/// The returned database is completely isolated — each call produces a fresh
/// SQLite instance backed by memory, so tests cannot leak state to each other.
AppDatabase createTestDatabase() =>
    AppDatabase.forTesting(NativeDatabase.memory());
