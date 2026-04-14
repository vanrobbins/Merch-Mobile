import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/role_guard.dart';
import 'auto_build_provider.dart';
import 'before_after_preview.dart';

// TODO(Agent6): AutoBuild screen needs real AI integration
// For now staff see a read-only placeholder

class AutoBuildScreen extends ConsumerStatefulWidget {
  const AutoBuildScreen({super.key, required this.zoneId});

  final String zoneId;

  @override
  ConsumerState<AutoBuildScreen> createState() => _AutoBuildScreenState();
}

class _AutoBuildScreenState extends ConsumerState<AutoBuildScreen> {
  String _season = 'Spring';
  final _presetNameController = TextEditingController();

  @override
  void dispose() {
    _presetNameController.dispose();
    super.dispose();
  }

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

  Future<void> _savePresetDialog() async {
    _presetNameController.clear();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('SAVE PRESET',
            style: TextStyle(
              fontWeight: DesignTokens.weightBold,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
              fontSize: DesignTokens.typeMd,
            )),
        content: TextField(
          controller: _presetNameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Preset name',
            hintText: 'e.g. Spring Wall Layout',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );

    if (confirmed == true && _presetNameController.text.isNotEmpty) {
      await ref.read(autoBuildNotifierProvider.notifier).saveAsPreset(
            _presetNameController.text.trim(),
            widget.zoneId,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Preset "${_presetNameController.text.trim()}" saved.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(autoBuildNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AUTO BUILD'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Season selector + compute
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Eyebrow
                const Text(
                  'SEASON',
                  style: TextStyle(
                    fontSize: DesignTokens.typeXs,
                    fontWeight: DesignTokens.weightBold,
                    letterSpacing: DesignTokens.letterSpacingEyebrow,
                    color: AppTheme.textSecondary,
                  ),
                ),
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
                        borderRadius:
                            BorderRadius.all(Radius.circular(DesignTokens.radiusSm)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceMd),
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
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.auto_fix_high),
                    label: Text(state.isComputing ? 'COMPUTING…' : 'COMPUTE'),
                  ),
                ),
              ],
            ),
          ),
          // Preview
          Expanded(
            child: BeforeAfterPreview(
              currentFixtures: state.currentFixtures,
              suggestedFixtures: state.suggestedFixtures,
            ),
          ),
          // Action buttons — coordinator/manager only
          RoleGuard(
            allowedRoles: const ['coordinator', 'manager'],
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spaceMd),
              child: Row(
                children: [
                  Expanded(
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
                  const SizedBox(width: DesignTokens.spaceSm),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: state.suggestedFixtures.isEmpty
                          ? null
                          : _savePresetDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(DesignTokens.radiusSm)),
                        ),
                      ),
                      child: const Text('SAVE PRESET'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
