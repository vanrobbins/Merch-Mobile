import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/brand_color.dart';
import '../../core/providers/store_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_empty_state.dart';
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (colors) => colors.isEmpty
            ? const MmEmptyState(
                icon: Icons.palette_outlined,
                headline: 'No Colors',
                body: 'Add brand colors to assign to products.',
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
          foregroundColor: Colors.white,
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete color?'),
        content: Text('Remove "${color.name}" from your palette?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
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
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Color name'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          TextField(
            controller: _hexCtrl,
            decoration: const InputDecoration(
              labelText: 'Hex value',
              hintText: '#FFFFFF',
            ),
          ),
          const SizedBox(height: DesignTokens.spaceLg),
          ElevatedButton(
            onPressed: _loading ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(AppTheme.borderRadius)),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(widget.existing == null ? 'ADD COLOR' : 'SAVE CHANGES'),
          ),
          const SizedBox(height: DesignTokens.spaceSm),
        ],
      ),
    );
  }
}
