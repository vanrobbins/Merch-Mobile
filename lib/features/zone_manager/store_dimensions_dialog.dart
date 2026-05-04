import 'package:flutter/material.dart';
import '../../core/widgets/mm_button.dart';
import '../../core/widgets/mm_text_field.dart';

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
            MmTextField(
              label: 'Width (ft)',
              controller: _widthCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositive,
            ),
            const SizedBox(height: 12),
            MmTextField(
              label: 'Depth (ft)',
              controller: _depthCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: _validatePositive,
            ),
          ],
        ),
      ),
      actions: [
        MmButton.text(
          label: 'SKIP',
          onPressed: () => Navigator.of(context).pop(),
        ),
        MmButton(
          label: 'CONFIRM',
          onPressed: _onConfirm,
        ),
      ],
    );
  }
}
