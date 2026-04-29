import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/role_guard.dart';
import 'auto_build_models.dart';
import 'auto_build_provider.dart';
import 'before_after_preview.dart';
import 'presets_sheet.dart';

// AutoBuild uses a deterministic in-app layout engine today.
// A future pass can wire this to a remote AI endpoint; the UI already
// accommodates an async compute/apply flow so the upgrade is additive.
// Staff see a read-only preview (compute / apply are RoleGuarded).

class AutoBuildScreen extends ConsumerStatefulWidget {
  const AutoBuildScreen({super.key, required this.zoneId});

  final String zoneId;

  @override
  ConsumerState<AutoBuildScreen> createState() => _AutoBuildScreenState();
}

class _AutoBuildScreenState extends ConsumerState<AutoBuildScreen> {
  String _season = 'Spring';

  Future<void> _compute() async {
    await ref
        .read(autoBuildNotifierProvider.notifier)
        .computeAutoLayout(widget.zoneId, _season);
  }

  Future<void> _apply() async {
    await ref
        .read(autoBuildNotifierProvider.notifier)
        .applyAutoLayout(widget.zoneId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Layout applied to zone.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(autoBuildNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AUTO BUILD'),
        actions: [
          TextButton(
            onPressed: () => PresetsSheet.show(context, widget.zoneId),
            child: const Text('PRESETS',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SEASON
                  const Text('SEASON',
                      style: TextStyle(
                        fontSize: DesignTokens.typeXs,
                        fontWeight: DesignTokens.weightBold,
                        letterSpacing: DesignTokens.letterSpacingEyebrow,
                        color: AppTheme.textSecondary,
                      )),
                  const SizedBox(height: DesignTokens.spaceSm),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Spring', label: Text('Spring')),
                      ButtonSegment(value: 'Summer', label: Text('Summer')),
                      ButtonSegment(value: 'Fall', label: Text('Fall')),
                      ButtonSegment(value: 'Winter', label: Text('Winter')),
                    ],
                    selected: {_season},
                    onSelectionChanged: (s) =>
                        setState(() => _season = s.first),
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(DesignTokens.radiusSm)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceMd),
                  // STYLE
                  const Text('STYLE',
                      style: TextStyle(
                        fontSize: DesignTokens.typeXs,
                        fontWeight: DesignTokens.weightBold,
                        letterSpacing: DesignTokens.letterSpacingEyebrow,
                        color: AppTheme.textSecondary,
                      )),
                  const SizedBox(height: DesignTokens.spaceSm),
                  SegmentedButton<LayoutStyle>(
                    segments: const [
                      ButtonSegment(
                          value: LayoutStyle.wallHeavy,
                          label: Text('Wall-Heavy')),
                      ButtonSegment(
                          value: LayoutStyle.mixed, label: Text('Mixed')),
                      ButtonSegment(
                          value: LayoutStyle.centerGrid,
                          label: Text('Center Grid')),
                    ],
                    selected: {state.layoutStyle},
                    onSelectionChanged: (s) => ref
                        .read(autoBuildNotifierProvider.notifier)
                        .setLayoutStyle(s.first),
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(DesignTokens.radiusSm)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceMd),
                  // DENSITY
                  const Text('DENSITY',
                      style: TextStyle(
                        fontSize: DesignTokens.typeXs,
                        fontWeight: DesignTokens.weightBold,
                        letterSpacing: DesignTokens.letterSpacingEyebrow,
                        color: AppTheme.textSecondary,
                      )),
                  const SizedBox(height: DesignTokens.spaceSm),
                  SegmentedButton<LayoutDensity>(
                    segments: const [
                      ButtonSegment(
                          value: LayoutDensity.low, label: Text('Low')),
                      ButtonSegment(
                          value: LayoutDensity.medium,
                          label: Text('Medium')),
                      ButtonSegment(
                          value: LayoutDensity.high, label: Text('High')),
                    ],
                    selected: {state.density},
                    onSelectionChanged: (s) => ref
                        .read(autoBuildNotifierProvider.notifier)
                        .setDensity(s.first),
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(DesignTokens.radiusSm)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceSm),
                  // INCLUDE MANNEQUINS
                  SwitchListTile(
                    title: const Text('INCLUDE MANNEQUINS',
                        style: TextStyle(
                          fontSize: DesignTokens.typeXs,
                          fontWeight: DesignTokens.weightBold,
                          letterSpacing: DesignTokens.letterSpacingEyebrow,
                        )),
                    value: state.includeMannequins,
                    onChanged: (v) => ref
                        .read(autoBuildNotifierProvider.notifier)
                        .setIncludeMannequins(v),
                    activeColor: AppTheme.accent,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: DesignTokens.spaceSm),
                  // COMPUTE
                  RoleGuard(
                    allowedRoles: const ['coordinator', 'manager'],
                    child: ElevatedButton.icon(
                      onPressed: state.isComputing ? null : _compute,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(DesignTokens.radiusSm)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: DesignTokens.spaceSm),
                      ),
                      icon: state.isComputing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white),
                            )
                          : const Icon(Icons.auto_fix_high),
                      label: Text(
                          state.isComputing ? 'COMPUTING…' : 'COMPUTE'),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 320,
              child: BeforeAfterPreview(
                currentFixtures: state.currentFixtures,
                suggestedFixtures: state.suggestedFixtures,
              ),
            ),
            RoleGuard(
              allowedRoles: const ['coordinator', 'manager'],
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spaceMd),
                child: ElevatedButton(
                  onPressed:
                      state.suggestedFixtures.isEmpty ? null : _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(DesignTokens.radiusSm)),
                    ),
                  ),
                  child: const Text('APPLY'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
