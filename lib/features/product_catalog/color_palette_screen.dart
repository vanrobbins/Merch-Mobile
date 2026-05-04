import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/brand_color.dart';
import '../../core/providers/store_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_button.dart';
import '../../core/widgets/mm_dialog.dart';
import '../../core/widgets/mm_text_field.dart';
import '../../core/widgets/role_guard.dart';
import 'catalog_provider.dart';

class ColorPaletteScreen extends ConsumerWidget {
  const ColorPaletteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeId = ref.watch(activeStoreIdProvider).value ?? '';
    final colorsAsync = ref.watch(brandColorsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('COLOR PALETTE')),
      body: colorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (colors) => colors.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.palette_outlined, size: 48, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                    const SizedBox(height: DesignTokens.spaceMd),
                    const Text(
                      'NO COLORS YET',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: DesignTokens.typeMd,
                        fontWeight: DesignTokens.weightBold,
                        letterSpacing: DesignTokens.letterSpacingEyebrow,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceXs),
                    const Text(
                      'Tap + to add your first brand color.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: DesignTokens.typeSm),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(DesignTokens.spaceMd),
                itemCount: colors.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final color = colors[i];
                  return ListTile(
                    leading: _ColorDot(hexValue: color.hexValue),
                    title: Text(
                      color.name,
                      style: const TextStyle(
                        fontSize: DesignTokens.typeMd,
                        fontWeight: DesignTokens.weightBold,
                      ),
                    ),
                    subtitle: Text(
                      color.hexValue.toUpperCase(),
                      style: const TextStyle(
                        fontSize: DesignTokens.typeSm,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    trailing: RoleGuard(
                      allowedRoles: const ['coordinator', 'manager'],
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: DesignTokens.iconSm),
                            onPressed: () => _showEditSheet(context, ref, storeId, color),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: DesignTokens.iconSm, color: AppTheme.errorColor),
                            onPressed: () => _confirmDelete(context, ref, storeId, color),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: RoleGuard(
        allowedRoles: const ['coordinator', 'manager'],
        child: FloatingActionButton(
          onPressed: () => _showEditSheet(context, ref, storeId, null),
          backgroundColor: AppTheme.accent,
          foregroundColor: AppTheme.canvasBg,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, String storeId, BrandColor? existing) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ColorEditSheet(storeId: storeId, existing: existing),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, String storeId, BrandColor color) async {
    final confirm = await MmDialog.show<bool>(
      context,
      title: 'Delete color?',
      content: Text('Remove "${color.name}" from your palette?'),
      actions: [
        MmButton.text(
          label: 'CANCEL',
          onPressed: () => Navigator.pop(context, false),
        ),
        MmButton.destructive(
          label: 'DELETE',
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
    if (confirm == true) {
      await deleteBrandColor(storeId, color.id);
    }
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.hexValue});
  final String hexValue;

  Color get _color {
    try {
      return Color(int.parse(hexValue.replaceFirst('#', 'FF'), radix: 16));
    } catch (_) {
      return AppTheme.divider;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _color,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(color: AppTheme.divider),
        ),
      );
}

class _ColorEditSheet extends ConsumerStatefulWidget {
  const _ColorEditSheet({required this.storeId, this.existing});
  final String storeId;
  final BrandColor? existing;

  @override
  ConsumerState<_ColorEditSheet> createState() => _ColorEditSheetState();
}

class _ColorEditSheetState extends ConsumerState<_ColorEditSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _hexCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _hexCtrl = TextEditingController(text: widget.existing?.hexValue ?? '#');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _hexCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final hex = _hexCtrl.text.trim();
    if (name.isEmpty || !hex.startsWith('#') || hex.length < 4) return;
    setState(() => _loading = true);
    try {
      final color = BrandColor(
        id: widget.existing?.id ?? const Uuid().v4(),
        name: name,
        hexValue: hex.toUpperCase(),
        updatedAt: DateTime.now(),
      );
      await upsertBrandColor(widget.storeId, color);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
        left: DesignTokens.spaceMd,
        right: DesignTokens.spaceMd,
        top: DesignTokens.spaceMd,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusLg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            widget.existing == null ? 'ADD COLOR' : 'EDIT COLOR',
            style: const TextStyle(
              fontSize: DesignTokens.typeLg,
              fontWeight: DesignTokens.weightBold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          MmTextField(
            label: 'Color name',
            controller: _nameCtrl,
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          MmTextField(
            label: 'Hex value',
            hint: '#FFFFFF',
            controller: _hexCtrl,
          ),
          const SizedBox(height: DesignTokens.spaceLg),
          MmButton(
            label: widget.existing == null ? 'ADD COLOR' : 'SAVE CHANGES',
            onPressed: _loading ? null : _save,
            isLoading: _loading,
          ),
          const SizedBox(height: DesignTokens.spaceSm),
        ],
      ),
    );
  }
}
