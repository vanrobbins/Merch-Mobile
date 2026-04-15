import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/role_guard.dart';

class ZoneDetailScreen extends ConsumerWidget {
  const ZoneDetailScreen({super.key, required this.zoneId});
  final String zoneId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final storeId = ref.watch(activeStoreIdProvider).value ?? '';

    final zonesAsync = ref.watch(
      StreamProvider((r) => db.zonesDao.watchByStore(storeId)),
    );
    final fixturesAsync = ref.watch(
      StreamProvider((r) => db.fixturesDao.watchByParentId(zoneId)),
    );
    final planogramsAsync = ref.watch(
      StreamProvider((r) => db.planogramsDao.watchAll()),
    );

    final zone = zonesAsync.value?.where((z) => z.id == zoneId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(zone != null ? zone.name.toUpperCase() : 'ZONE DETAIL'),
        actions: [
          RoleGuard(
            allowedRoles: const ['coordinator', 'manager'],
            child: TextButton(
              onPressed: () => context.goNamed(
                AppRoutes.floorBuilder,
                pathParameters: {'zoneId': zoneId},
              ),
              child: const Text(
                'EDIT FLOOR',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Zone header info
          if (zone != null) _ZoneHeader(zone: zone),
          // Fixture list
          Expanded(
            child: fixturesAsync.when(
              data: (fixtures) {
                if (fixtures.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(DesignTokens.spaceLg),
                      child: Text(
                        'No fixtures yet.\nOpen Floor Builder to add fixtures.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  );
                }
                return planogramsAsync.when(
                  data: (planograms) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(DesignTokens.spaceMd),
                      itemCount: fixtures.length,
                      itemBuilder: (context, index) {
                        final fixture = fixtures[index];
                        final linked = planograms
                            .where((p) => p.fixtureId == fixture.id)
                            .firstOrNull;
                        return _FixturePlanogramCard(
                          fixture: fixture,
                          planogramTitle: linked?.title,
                          planogramId: linked?.id,
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Text(
                      'Error loading planograms: $e',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Error loading fixtures: $e',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneHeader extends StatelessWidget {
  const _ZoneHeader({required this.zone});
  final ZonesTableData zone;

  String _formatZoneType(String type) {
    switch (type) {
      case 'cash_wrap':
        return 'CASH WRAP';
      case 'fitting_room':
        return 'FITTING ROOM';
      default:
        return type.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(zone.colorValue);
    return Container(
      color: AppTheme.cardSurface,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceMd,
        vertical: DesignTokens.spaceMd,
      ),
      child: Row(
        children: [
          // Color swatch
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
          ),
          const SizedBox(width: DesignTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.name,
                  style: const TextStyle(
                    fontSize: DesignTokens.typeLg,
                    fontWeight: DesignTokens.weightBold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceXs),
                Text(
                  _formatZoneType(zone.zoneType),
                  style: const TextStyle(
                    fontSize: DesignTokens.typeXs,
                    fontWeight: DesignTokens.weightBold,
                    letterSpacing: DesignTokens.letterSpacingEyebrow,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FixturePlanogramCard extends ConsumerWidget {
  const _FixturePlanogramCard({
    required this.fixture,
    this.planogramTitle,
    this.planogramId,
  });

  final FixturesTableData fixture;
  final String? planogramTitle;
  final String? planogramId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = fixture.label.isNotEmpty
        ? fixture.label
        : fixture.fixtureType.toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceMd,
          vertical: DesignTokens.spaceSm,
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: DesignTokens.weightBold,
            fontSize: DesignTokens.typeMd,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          fixture.fixtureType.toUpperCase(),
          style: const TextStyle(
            fontSize: DesignTokens.typeXs,
            letterSpacing: DesignTokens.letterSpacingEyebrow,
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: planogramTitle != null
            ? GestureDetector(
                onTap: () => context.goNamed(
                  AppRoutes.planogramDetail,
                  pathParameters: {'planogramId': planogramId!},
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spaceSm,
                    vertical: DesignTokens.spaceXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadius),
                  ),
                  child: Text(
                    planogramTitle!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: DesignTokens.typeSm,
                      fontWeight: DesignTokens.weightBold,
                    ),
                  ),
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceSm,
                  vertical: DesignTokens.spaceXs,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
                child: const Text(
                  'UNASSIGNED',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: DesignTokens.typeSm,
                    fontWeight: DesignTokens.weightBold,
                    letterSpacing: DesignTokens.letterSpacingEyebrow,
                  ),
                ),
              ),
      ),
    );
  }
}
