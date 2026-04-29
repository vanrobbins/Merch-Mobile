import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/product.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/firestore_refs.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import 'catalog_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productId});
  final String? productId;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  int _step = 0; // 0=template, 1=color, 2=details
  bool _loading = false;
  Product? _existing;

  // Step 1: template
  String? _selectedTemplateId;
  String? _selectedSilhouette;

  // Step 2: color
  String? _selectedColorId;
  String? _selectedColorHex;
  String? _selectedColorName;

  // Step 3: details
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _colorNotesCtrl = TextEditingController();

  // Template definitions (built-in)
  static const _templates = [
    _TemplateDef('builtin_shirt_ss', 'Short Sleeve', 'Tops',        'shirt_ss'),
    _TemplateDef('builtin_shirt_ls', 'Long Sleeve',  'Tops',        'shirt_ls'),
    _TemplateDef('builtin_tank_top', 'Tank Top',     'Tops',        'tank_top'),
    _TemplateDef('builtin_pant',     'Pant',         'Bottoms',     'pant'),
    _TemplateDef('builtin_short',    'Short',        'Bottoms',     'short'),
    _TemplateDef('builtin_jacket',   'Jacket',       'Outerwear',   'jacket'),
    _TemplateDef('builtin_dress',    'Dress',        'Tops',        'dress'),
    _TemplateDef('builtin_skirt',    'Skirt',        'Bottoms',     'skirt'),
    _TemplateDef('builtin_bag',      'Bag',          'Accessories', 'bag'),
    _TemplateDef('builtin_hat',      'Hat',          'Accessories', 'hat'),
    _TemplateDef('builtin_bra',      'Bra',          'Tops',        'bra'),
    _TemplateDef('builtin_shoe',     'Shoe',         'Accessories', 'shoe'),
    _TemplateDef('builtin_other',    'Other',        'Other',       'other'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) _loadExisting();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _categoryCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _colorNotesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final storeId = ref.read(activeStoreIdProvider).value ?? '';
    final snap = await FirestoreRefs.products(storeId).doc(widget.productId!).get();
    if (!snap.exists || !mounted) return;
    final p = ProductFirestore.fromDoc(snap);
    setState(() {
      _existing = p;
      _selectedTemplateId = p.templateId;
      _selectedColorId = p.colorId;
      _nameCtrl.text = p.name;
      _skuCtrl.text = p.sku;
      _categoryCtrl.text = p.category;
      _priceCtrl.text = p.price?.toString() ?? '';
      _stockCtrl.text = p.stockQty.toString();
      _colorNotesCtrl.text = p.colorNotes ?? '';
      // Skip to details step if editing
      _step = 2;
      // Find silhouette for template
      final tmpl = _templates.where((t) => t.id == p.templateId).firstOrNull;
      _selectedSilhouette = tmpl?.silhouette;
    });
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final sku = _skuCtrl.text.trim();
    final category = _categoryCtrl.text.trim();
    if (name.isEmpty || sku.isEmpty || category.isEmpty) return;
    setState(() => _loading = true);
    try {
      final storeId = ref.read(activeStoreIdProvider).value ?? '';
      final product = Product(
        id: _existing?.id ?? const Uuid().v4(),
        sku: sku,
        name: name,
        category: category,
        stockQty: int.tryParse(_stockCtrl.text) ?? 0,
        updatedAt: DateTime.now(),
        templateId: _selectedTemplateId,
        colorId: _selectedColorId,
        colorNotes: _colorNotesCtrl.text.trim().isEmpty
            ? null
            : _colorNotesCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text),
      );
      await upsertProduct(storeId, product);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    if (_existing == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Remove "${_existing!.name}"?'),
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
      final storeId = ref.read(activeStoreIdProvider).value ?? '';
      await deleteProduct(storeId, _existing!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  String get _stepTitle {
    if (_existing != null) return 'EDIT PRODUCT';
    switch (_step) {
      case 0:
        return 'STEP 1 OF 3 — TEMPLATE';
      case 1:
        return 'STEP 2 OF 3 — COLOR';
      default:
        return 'STEP 3 OF 3 — DETAILS';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitle),
        leading: _step > 0 && _existing == null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _step--),
              )
            : null,
        actions: [
          if (_existing != null)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: AppTheme.errorColor.withValues(alpha: 0.9),
              ),
              onPressed: _delete,
            ),
        ],
      ),
      body: IndexedStack(
        index: _step,
        children: [
          _TemplateStep(
            selected: _selectedTemplateId,
            onSelect: (id, silhouette) => setState(() {
              _selectedTemplateId = id;
              _selectedSilhouette = silhouette;
              _step = 1;
            }),
          ),
          _ColorStep(
            selected: _selectedColorId,
            onSelect: (id, hex, name) => setState(() {
              _selectedColorId = id;
              _selectedColorHex = hex;
              _selectedColorName = name;
              _step = 2;
            }),
            onSkip: () => setState(() => _step = 2),
          ),
          _DetailsStep(
            nameCtrl: _nameCtrl,
            skuCtrl: _skuCtrl,
            categoryCtrl: _categoryCtrl,
            priceCtrl: _priceCtrl,
            stockCtrl: _stockCtrl,
            colorNotesCtrl: _colorNotesCtrl,
            selectedTemplateId: _selectedTemplateId,
            selectedSilhouette: _selectedSilhouette,
            selectedColorHex: _selectedColorHex,
            selectedColorName: _selectedColorName,
            loading: _loading,
            onSave: _save,
          ),
        ],
      ),
    );
  }
}

// ─── Step 1: Template Picker ─────────────────────────────────────────────────

class _TemplateStep extends StatelessWidget {
  const _TemplateStep({required this.selected, required this.onSelect});
  final String? selected;
  final void Function(String id, String silhouette) onSelect;

  static const _templates = [
    _TemplateDef('builtin_shirt_ss', 'Short Sleeve', 'Tops',        'shirt_ss'),
    _TemplateDef('builtin_shirt_ls', 'Long Sleeve',  'Tops',        'shirt_ls'),
    _TemplateDef('builtin_tank_top', 'Tank Top',     'Tops',        'tank_top'),
    _TemplateDef('builtin_pant',     'Pant',         'Bottoms',     'pant'),
    _TemplateDef('builtin_short',    'Short',        'Bottoms',     'short'),
    _TemplateDef('builtin_jacket',   'Jacket',       'Outerwear',   'jacket'),
    _TemplateDef('builtin_dress',    'Dress',        'Tops',        'dress'),
    _TemplateDef('builtin_skirt',    'Skirt',        'Bottoms',     'skirt'),
    _TemplateDef('builtin_bag',      'Bag',          'Accessories', 'bag'),
    _TemplateDef('builtin_hat',      'Hat',          'Accessories', 'hat'),
    _TemplateDef('builtin_bra',      'Bra',          'Tops',        'bra'),
    _TemplateDef('builtin_shoe',     'Shoe',         'Accessories', 'shoe'),
    _TemplateDef('builtin_other',    'Other',        'Other',       'other'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: DesignTokens.spaceSm,
        mainAxisSpacing: DesignTokens.spaceSm,
        childAspectRatio: 0.85,
      ),
      itemCount: _templates.length,
      itemBuilder: (_, i) {
        final t = _templates[i];
        final isSelected = selected == t.id;
        return GestureDetector(
          onTap: () => onSelect(t.id, t.silhouette),
          child: AnimatedContainer(
            duration: DesignTokens.durationFast,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.accent.withValues(alpha: 0.08)
                  : AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              border: Border.all(
                color: isSelected ? AppTheme.accent : AppTheme.divider,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      'assets/silhouettes/${t.silhouette}.svg',
                      colorFilter: ColorFilter.mode(
                        isSelected ? AppTheme.accent : AppTheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceXs),
                Text(
                  t.name,
                  style: TextStyle(
                    fontSize: DesignTokens.typeSm,
                    fontWeight: DesignTokens.weightBold,
                    color: isSelected ? AppTheme.accent : AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  t.category,
                  style: const TextStyle(
                    fontSize: DesignTokens.typeXs,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Step 2: Color Picker ─────────────────────────────────────────────────────

class _ColorStep extends ConsumerWidget {
  const _ColorStep({
    required this.selected,
    required this.onSelect,
    required this.onSkip,
  });
  final String? selected;
  final void Function(String id, String hex, String name) onSelect;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorsAsync = ref.watch(brandColorsProvider);
    return colorsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (colors) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: colors.isEmpty
                ? const Center(
                    child: Text(
                      'No brand colors yet.\nAdd colors in Catalog → Colors.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(DesignTokens.spaceMd),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: DesignTokens.spaceSm,
                      mainAxisSpacing: DesignTokens.spaceSm,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: colors.length,
                    itemBuilder: (_, i) {
                      final c = colors[i];
                      final isSelected = selected == c.id;
                      final colorValue = _parseHex(c.hexValue);
                      return GestureDetector(
                        onTap: () => onSelect(c.id, c.hexValue, c.name),
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: DesignTokens.durationFast,
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: colorValue,
                                borderRadius: BorderRadius.circular(
                                    AppTheme.borderRadius),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.accent
                                      : AppTheme.divider,
                                  width: isSelected ? 2.5 : 1,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      size: 28,
                                      color: (colorValue?.computeLuminance() ??
                                                  1) >
                                              0.5
                                          ? AppTheme.primary
                                          : Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: DesignTokens.spaceXs),
                            Text(
                              c.name,
                              style: TextStyle(
                                fontSize: DesignTokens.typeXs,
                                fontWeight: isSelected
                                    ? DesignTokens.weightBold
                                    : DesignTokens.weightRegular,
                                color: isSelected
                                    ? AppTheme.accent
                                    : AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: DesignTokens.spaceMd,
              right: DesignTokens.spaceMd,
              bottom: DesignTokens.spaceMd,
              top: DesignTokens.spaceSm,
            ),
            child: OutlinedButton(
              onPressed: onSkip,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: const BorderSide(color: AppTheme.divider),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppTheme.borderRadius),
                  ),
                ),
              ),
              child: const Text('SKIP — NO COLOR'),
            ),
          ),
        ],
      ),
    );
  }

  Color? _parseHex(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
    } catch (_) {
      return null;
    }
  }
}

// ─── Step 3: Details ──────────────────────────────────────────────────────────

class _DetailsStep extends StatelessWidget {
  const _DetailsStep({
    required this.nameCtrl,
    required this.skuCtrl,
    required this.categoryCtrl,
    required this.priceCtrl,
    required this.stockCtrl,
    required this.colorNotesCtrl,
    required this.selectedTemplateId,
    required this.selectedSilhouette,
    required this.selectedColorHex,
    required this.selectedColorName,
    required this.loading,
    required this.onSave,
  });

  final TextEditingController nameCtrl;
  final TextEditingController skuCtrl;
  final TextEditingController categoryCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController stockCtrl;
  final TextEditingController colorNotesCtrl;
  final String? selectedTemplateId;
  final String? selectedSilhouette;
  final String? selectedColorHex;
  final String? selectedColorName;
  final bool loading;
  final VoidCallback onSave;

  Color? get _colorValue {
    if (selectedColorHex == null) return null;
    try {
      return Color(
          int.parse(selectedColorHex!.replaceFirst('#', 'FF'), radix: 16));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: DesignTokens.spaceLg,
        right: DesignTokens.spaceLg,
        top: DesignTokens.spaceLg,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + DesignTokens.spaceLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary row: silhouette + color
          if (selectedSilhouette != null || selectedColorHex != null)
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceMd),
              margin: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              child: Row(
                children: [
                  if (selectedSilhouette != null) ...[
                    SvgPicture.asset(
                      'assets/silhouettes/$selectedSilhouette.svg',
                      width: 32,
                      height: 32,
                      colorFilter: const ColorFilter.mode(
                          AppTheme.primary, BlendMode.srcIn),
                    ),
                    const SizedBox(width: DesignTokens.spaceMd),
                  ],
                  if (_colorValue != null) ...[
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _colorValue,
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadius),
                        border: Border.all(color: AppTheme.divider),
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spaceSm),
                    Text(
                      selectedColorName ?? '',
                      style: const TextStyle(
                        fontSize: DesignTokens.typeSm,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          TextFormField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Product Name *'),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          TextFormField(
            controller: skuCtrl,
            decoration: const InputDecoration(labelText: 'SKU *'),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          TextFormField(
            controller: categoryCtrl,
            decoration: const InputDecoration(labelText: 'Category *'),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    prefixText: '\$',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceMd),
              Expanded(
                child: TextFormField(
                  controller: stockCtrl,
                  decoration: const InputDecoration(labelText: 'Stock Qty'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          TextFormField(
            controller: colorNotesCtrl,
            decoration: const InputDecoration(
              labelText: 'Color notes',
              hintText: 'e.g. heathered, overdyed…',
            ),
          ),
          const SizedBox(height: DesignTokens.spaceLg),
          ElevatedButton(
            onPressed: loading ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(AppTheme.borderRadius)),
              ),
            ),
            child: loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('SAVE PRODUCT'),
          ),
        ],
      ),
    );
  }
}

class _TemplateDef {
  const _TemplateDef(this.id, this.name, this.category, this.silhouette);
  final String id;
  final String name;
  final String category;
  final String silhouette;
}
