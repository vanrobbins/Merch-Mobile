import 'package:flutter_test/flutter_test.dart';
import 'package:merch_mobile/features/auto_build/auto_build_models.dart';

void main() {
  group('LayoutDensity.spacingFt', () {
    test('low returns 4.0', () => expect(LayoutDensity.low.spacingFt, 4.0));
    test('medium returns 2.0', () => expect(LayoutDensity.medium.spacingFt, 2.0));
    test('high returns 1.5', () => expect(LayoutDensity.high.spacingFt, 1.5));
  });

  group('AutoBuildPreset.settingsSummary', () {
    test('includes season, style, density, and mannequin flag', () {
      final preset = AutoBuildPreset(
        id: 'p1',
        name: 'Spring Layout',
        season: 'Spring',
        layoutStyle: LayoutStyle.wallHeavy,
        density: LayoutDensity.high,
        includeMannequins: true,
        createdByUid: 'uid1',
        createdAt: DateTime(2026, 4, 29),
      );
      final summary = preset.settingsSummary;
      expect(summary, contains('Spring'));
      expect(summary, contains('Wall-Heavy'));
      expect(summary, contains('High'));
      expect(summary, contains('Mannequin'));
    });

    test('omits mannequins label when false', () {
      final preset = AutoBuildPreset(
        id: 'p2',
        name: 'Fall Layout',
        season: 'Fall',
        layoutStyle: LayoutStyle.centerGrid,
        density: LayoutDensity.low,
        includeMannequins: false,
        createdByUid: 'uid1',
        createdAt: DateTime(2026, 4, 29),
      );
      expect(preset.settingsSummary, isNot(contains('Mannequin')));
    });
  });

  group('AutoBuildPreset.fromDoc / toFirestore round-trip', () {
    test('all enum values survive JSON round-trip via name field', () {
      for (final style in LayoutStyle.values) {
        for (final density in LayoutDensity.values) {
          expect(
            LayoutStyle.values.firstWhere((v) => v.name == style.name),
            style,
          );
          expect(
            LayoutDensity.values.firstWhere((v) => v.name == density.name),
            density,
          );
        }
      }
    });
  });
}
