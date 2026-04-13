import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../models/store_zone.dart';
import '../providers/connectivity_provider.dart';
import '../providers/database_provider.dart';
import 'api_client.dart';

class SyncService {
  final Ref _ref;
  SyncService(this._ref);

  Future<void> syncAll() async {
    // 1. Check connectivity
    final isOnline = _ref.read(connectivityProvider).value ?? false;
    if (!isOnline) return;

    final db = _ref.read(appDatabaseProvider);

    // 2. Sync zones
    try {
      final localRows = await db.zonesDao.watchAll().first;
      final localZones = localRows
          .map((r) => StoreZone(
                id: r.id,
                name: r.name,
                colorValue: r.colorValue,
                zoneType: r.zoneType,
                storeId: r.storeId,
                posX: r.posX,
                posY: r.posY,
                width: r.width,
                height: r.height,
                updatedAt: r.updatedAt,
              ))
          .toList();
      final client = ApiClient();
      final serverZones = await client.syncZones(localZones);
      for (final zone in serverZones) {
        await db.zonesDao.upsert(ZonesTableCompanion(
          id: Value(zone.id),
          name: Value(zone.name),
          colorValue: Value(zone.colorValue),
          zoneType: Value(zone.zoneType),
          storeId: Value(zone.storeId),
          posX: Value(zone.posX),
          posY: Value(zone.posY),
          width: Value(zone.width),
          height: Value(zone.height),
          updatedAt: Value(zone.updatedAt),
        ));
      }
    } catch (e) {
      debugPrint('SyncService: zone sync error: $e');
    }

    // 3. Sync products
    try {
      final client = ApiClient();
      final products = await client.getProducts();
      for (final p in products) {
        await db.productsDao.upsert(ProductsTableCompanion(
          id: Value(p.id),
          sku: Value(p.sku),
          name: Value(p.name),
          category: Value(p.category),
          imageUrl: Value(p.imageUrl),
          sizesJson: Value(jsonEncode(p.sizes)),
          stockQty: Value(p.stockQty),
          updatedAt: Value(p.updatedAt),
        ));
      }
    } catch (e) {
      debugPrint('SyncService: product sync error: $e');
    }
  }
}
