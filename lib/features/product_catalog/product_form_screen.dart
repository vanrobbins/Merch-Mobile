import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/tables/products_table.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/store_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productId});
  final String? productId;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  bool _loading = false;
  ProductsTableData? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) _loadExisting();
  }

  Future<void> _loadExisting() async {
    final db = ref.read(appDatabaseProvider);
    final product = await db.productsDao.findById(widget.productId!);
    if (product != null && mounted) {
      setState(() {
        _existing = product;
        _nameCtrl.text = product.name;
        _skuCtrl.text = product.sku;
        _categoryCtrl.text = product.category;
        _stockCtrl.text = product.stockQty.toString();
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _categoryCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final storeId = ref.read(activeStoreIdProvider).value ?? '';
      await db.productsDao.upsert(ProductsTableCompanion.insert(
        id: _existing?.id ?? const Uuid().v4(),
        sku: _skuCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        category: _categoryCtrl.text.trim(),
        storeId: storeId,
        stockQty: Value(int.tryParse(_stockCtrl.text) ?? 0),
        updatedAt: DateTime.now(),
      ));
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
        content: Text('Remove ${_existing!.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final db = ref.read(appDatabaseProvider);
      await db.productsDao.deleteById(_existing!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_existing == null ? 'ADD PRODUCT' : 'EDIT PRODUCT'),
        actions: [
          if (_existing != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.redAccent,
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(DesignTokens.spaceLg),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Product Name *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            TextFormField(
              controller: _skuCtrl,
              decoration: const InputDecoration(labelText: 'SKU *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            TextFormField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(labelText: 'Category *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            TextFormField(
              controller: _stockCtrl,
              decoration: const InputDecoration(labelText: 'Stock Qty'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            ElevatedButton(
              onPressed: _loading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_existing == null ? 'ADD PRODUCT' : 'SAVE CHANGES'),
            ),
          ],
        ),
      ),
    );
  }
}
