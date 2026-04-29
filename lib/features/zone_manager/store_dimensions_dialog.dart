import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StoreDimensionsDialog extends StatefulWidget {
  const StoreDimensionsDialog({super.key, required this.onSave});
  final void Function(double widthFt, double depthFt) onSave;

  @override
  State<StoreDimensionsDialog> createState() => _StoreDimensionsDialogState();
}

class _StoreDimensionsDialogState extends State<StoreDimensionsDialog> {
  final _widthCtrl = TextEditingController();
  final _depthCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _widthCtrl.dispose();
    _depthCtrl.dispose();
    super.dispose();
  }

  String? _validatePositive(String? v) {
    final n = double.tryParse(v ?? '');
    if (n == null || n <= 0) return 'Enter a positive number';
    return null;
  }

  void _onConfirm() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        double.parse(_widthCtrl.text),
        double.parse(_depthCtrl.text),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('STORE DIMENSIONS'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the floor dimensions of your store to enable the ft grid and boundary.',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _widthCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Width (ft)',
                border: OutlineInputBorder(),
              ),
              validator: _validatePositive,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _depthCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Depth (ft)',
                border: OutlineInputBorder(),
              ),
              validator: _validatePositive,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('SKIP'),
        ),
        ElevatedButton(
          onPressed: _onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accent,
            foregroundColor: Colors.white,
          ),
          child: const Text('CONFIRM'),
        ),
      ],
    );
  }
}
