import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/store_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_button.dart';
import '../../core/widgets/mm_dialog.dart';
import '../../core/widgets/mm_text_field.dart';
import '../../core/widgets/role_guard.dart';
import 'auto_build_models.dart';
import 'auto_build_provider.dart';

class PresetsSheet extends ConsumerStatefulWidget {
  const PresetsSheet({super.key, required this.zoneId});

  final String zoneId;

  static Future<void> show(BuildContext context, String zoneId) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => PresetsSheet(zoneId: zoneId),
      );

  @override
  ConsumerState<PresetsSheet> createState() => _PresetsSheetState();
}

class _PresetsSheetState extends ConsumerState<PresetsSheet> {
  List<AutoBuildPreset>? _presets;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final presets =
        await ref.read(autoBuildNotifierProvider.notifier).fetchPresets();
    if (mounted) setState(() { _presets = presets; _loading = false; });
  }

  Future<void> _saveCurrentPreset() async {
    final nameCtrl = TextEditingController();
    final confirmed = await MmDialog.show<bool>(
      context,
      title: 'Save Preset',
      content: MmTextField(
        controller: nameCtrl,
        label: 'Preset name',
        autofocus: true,
      ),
      actions: [
        MmButton.text(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context, false),
        ),
        MmButton(
          label: 'Save',
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
    if (confirmed == true && nameCtrl.text.isNotEmpty) {
      await ref
          .read(autoBuildNotifierProvider.notifier)
          .saveAsPreset(nameCtrl.text.trim());
      await _load();
    }
  }

  Future<bool> _confirmDelete() async {
    final membership = ref.read(currentMembershipProvider).value;
    final role = membership?.role ?? 'staff';
    if (role != 'coordinator' && role != 'manager') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Only coordinators / managers can delete presets.')),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusLg)),
        ),
        child: Column(
          children: [
            const SizedBox(height: DesignTokens.spaceSm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.canvasBg.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceMd,
                  vertical: DesignTokens.spaceXs),
              child: Row(
                children: [
                  const Text(
                    'PRESETS',
                    style: TextStyle(
                      color: AppTheme.canvasBg,
                      fontWeight: DesignTokens.weightBold,
                      letterSpacing: DesignTokens.letterSpacingEyebrow,
                      fontSize: DesignTokens.typeMd,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.canvasBg),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(
              color: AppTheme.canvasBg.withValues(alpha: 0.12),
              height: 1,
            ),
            Expanded(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.canvasBg.withValues(alpha: 0.54)))
                  : (_presets == null || _presets!.isEmpty)
                      ? Center(
                          child: Text(
                            'No presets saved yet.',
                            style: TextStyle(
                                color: AppTheme.canvasBg.withValues(alpha: 0.54)),
                          ),
                        )
                      : ListView.builder(
                          controller: controller,
                          itemCount: _presets!.length,
                          itemBuilder: (_, i) {
                            final preset = _presets![i];
                            return Dismissible(
                              key: Key(preset.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(
                                    right: DesignTokens.spaceMd),
                                color: AppTheme.errorColor,
                                child: const Icon(
                                  Icons.delete,
                                  color: AppTheme.canvasBg,
                                ),
                              ),
                              confirmDismiss: (_) => _confirmDelete(),
                              onDismissed: (_) async {
                                final id = preset.id;
                                setState(() => _presets!.removeWhere(
                                    (p) => p.id == id));
                                await ref
                                    .read(autoBuildNotifierProvider.notifier)
                                    .deletePreset(id);
                              },
                              child: ListTile(
                                title: Text(
                                  preset.name,
                                  style: const TextStyle(
                                    color: AppTheme.canvasBg,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  preset.settingsSummary,
                                  style: TextStyle(
                                    color: AppTheme.canvasBg.withValues(alpha: 0.54),
                                    fontSize: DesignTokens.typeXs,
                                  ),
                                ),
                                trailing: MmButton.text(
                                  label: 'Load',
                                  onPressed: () async {
                                    await ref
                                        .read(autoBuildNotifierProvider
                                            .notifier)
                                        .loadPreset(preset, widget.zoneId);
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ),
            RoleGuard(
              allowedRoles: const ['coordinator', 'manager'],
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.spaceMd),
                  child: MmButton(
                    label: 'Save Current',
                    icon: Icons.save_outlined,
                    onPressed: _saveCurrentPreset,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
