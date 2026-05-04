import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_button.dart';
import '../../core/widgets/mm_eyebrow.dart';
import '../../core/widgets/role_guard.dart';
import 'auto_build_models.dart';
import 'auto_build_provider.dart';
import 'before_after_preview.dart';
import 'presets_sheet.dart';

// AutoBuild uses a deterministic in-app layout engine today.
// A future pass can wire this to a remote AI endpoint; the UI already
// accommodates an async compute/apply flow so the upgrade is additive.
// Staff see a read-only preview (compute / apply are RoleGuarded).

ButtonStyle _segmentedStyle() => ButtonStyle(
      shape: WidgetStateProperty.all(const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(DesignTokens.radiusSm)),
      )),
      backgroundColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? AppTheme.accent
              : AppTheme.surfaceVariant),
      foregroundColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? AppTheme.canvasBg
              : AppTheme.textPrimary),
    );

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
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.canvasBg,
        title: const Text('AUTO BUILD'),
        actions: [
          TextButton(
            onPressed: () => PresetsSheet.show(context, widget.zoneId),
            child: const Text(
              'PRESETS',
              style: TextStyle(
                color: AppTheme.canvasBg,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
              ),
            ),
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
                  const MmEyebrow('Season'),
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
                    style: _segmentedStyle(),
                  ),
                  const SizedBox(height: DesignTokens.spaceMd),
                  // STYLE
                  const MmEyebrow('Style'),
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
                    style: _segmentedStyle(),
                  ),
                  const SizedBox(height: DesignTokens.spaceMd),
                  // DENSITY
                  const MmEyebrow('Density'),
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
                    style: _segmentedStyle(),
                  ),
                  const SizedBox(height: DesignTokens.spaceSm),
                  // INCLUDE MANNEQUINS
                  SwitchListTile(
                    title: const Text(
                      'INCLUDE MANNEQUINS',
                      style: TextStyle(
                        fontSize: DesignTokens.typeXs,
                        fontWeight: DesignTokens.weightBold,
                        letterSpacing: DesignTokens.letterSpacingEyebrow,
                      ),
                    ),
                    value: state.includeMannequins,
                    onChanged: (v) => ref
                        .read(autoBuildNotifierProvider.notifier)
                        .setIncludeMannequins(v),
                    activeTrackColor: AppTheme.accent,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: DesignTokens.spaceSm),
                  // COMPUTE
                  RoleGuard(
                    allowedRoles: const ['coordinator', 'manager'],
                    child: MmButton(
                      label: state.isComputing ? 'Computing…' : 'Compute',
                      icon: Icons.auto_fix_high,
                      isLoading: state.isComputing,
                      onPressed: state.isComputing ? null : _compute,
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
                child: MmButton(
                  label: 'Apply Layout',
                  icon: Icons.check,
                  onPressed: state.suggestedFixtures.isEmpty ? null : _apply,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
