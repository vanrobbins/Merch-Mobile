import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/store_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('SAVE PRESET',
            style: TextStyle(
              fontWeight: DesignTokens.weightBold,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
            )),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Preset name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white),
            child: const Text('SAVE'),
          ),
        ],
      ),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          children: [
            const SizedBox(height: DesignTokens.spaceSm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
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
                      color: Colors.white,
                      fontWeight: DesignTokens.weightBold,
                      letterSpacing: DesignTokens.letterSpacingEyebrow,
                      fontSize: DesignTokens.typeMd,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Expanded(
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Colors.white54))
                  : (_presets == null || _presets!.isEmpty)
                      ? const Center(
                          child: Text('No presets saved yet.',
                              style: TextStyle(color: Colors.white54)))
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
                                color: Colors.red.shade700,
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
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
                                title: Text(preset.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(preset.settingsSummary,
                                    style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12)),
                                trailing: TextButton(
                                  onPressed: () async {
                                    await ref
                                        .read(autoBuildNotifierProvider
                                            .notifier)
                                        .loadPreset(preset, widget.zoneId);
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                      foregroundColor: AppTheme.accent),
                                  child: const Text('LOAD'),
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
                  child: ElevatedButton(
                    onPressed: _saveCurrentPreset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text('SAVE CURRENT'),
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
