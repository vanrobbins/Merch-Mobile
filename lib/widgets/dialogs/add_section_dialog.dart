import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/display_section.dart';
import '../../theme/app_theme.dart';

/// Dialog to create or edit a DisplaySection.
class AddSectionDialog extends StatefulWidget {
  final DisplaySection? initial;

  const AddSectionDialog({super.key, this.initial});

  @override
  State<AddSectionDialog> createState() => _AddSectionDialogState();
}

class _AddSectionDialogState extends State<AddSectionDialog> {
  final _titleCtrl = TextEditingController();
  final _prevNoteCtrl = TextEditingController();
  final _nextNoteCtrl = TextEditingController();
  final _lfCtrl = TextEditingController();
  final _faceOutCtrl = TextEditingController();
  final _uBarCtrl = TextEditingController();

  SectionType _type = SectionType.perimeter;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      final s = widget.initial!;
      _titleCtrl.text = s.title;
      _type = s.type;
      _lfCtrl.text = s.linearFeet?.toString() ?? '';
      _faceOutCtrl.text = s.faceOutCount.toString();
      _uBarCtrl.text = s.uBarCount.toString();
      _prevNoteCtrl.text = s.previousSectionNote ?? '';
      _nextNoteCtrl.text = s.nextSectionNote ?? '';
    } else {
      _faceOutCtrl.text = '2';
      _uBarCtrl.text = '3';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _prevNoteCtrl.dispose();
    _nextNoteCtrl.dispose();
    _lfCtrl.dispose();
    _faceOutCtrl.dispose();
    _uBarCtrl.dispose();
    super.dispose();
  }

  void _onTypeChanged(SectionType t) {
    setState(() {
      _type = t;
      if (_titleCtrl.text.isEmpty || _isAutoTitle(_titleCtrl.text)) {
        _titleCtrl.text = _defaultTitle(t);
      }
    });
  }

  bool _isAutoTitle(String t) =>
      t.startsWith('Perimeter Wall') ||
      t == 'Primary Table' ||
      t == 'Secondary Table' ||
      t == 'Third Table' ||
      t == 'Floor Rack';

  String _defaultTitle(SectionType t) => switch (t) {
        SectionType.perimeter =>
          'Perimeter Wall: ${_lfCtrl.text.isEmpty ? '8' : _lfCtrl.text}LF',
        SectionType.table => 'Secondary Table',
        SectionType.floorRack => 'Floor Rack',
      };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add Section' : 'Edit Section'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section type
            const Text(
              'DISPLAY TYPE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<SectionType>(
              segments: SectionType.values.map((t) {
                return ButtonSegment<SectionType>(
                  value: t,
                  label: Text(t.displayName, style: const TextStyle(fontSize: 12)),
                  icon: Text(t.icon),
                );
              }).toList(),
              selected: {_type},
              onSelectionChanged: (s) => _onTypeChanged(s.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppTheme.primary,
                selectedForegroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Title
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Section Title',
                hintText: 'e.g. Perimeter Wall: 8LF',
              ),
              textCapitalization: TextCapitalization.words,
            ),

            // Wall-specific fields
            if (_type == SectionType.perimeter) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _lfCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Linear Footage',
                  hintText: '8',
                  suffixText: 'LF',
                ),
                onChanged: (_) {
                  if (_isAutoTitle(_titleCtrl.text)) {
                    _titleCtrl.text =
                        'Perimeter Wall: ${_lfCtrl.text.isEmpty ? '8' : _lfCtrl.text}LF';
                  }
                },
              ),
            ],

            // Face-out / U-bar counts (wall + rack)
            if (_type == SectionType.perimeter ||
                _type == SectionType.floorRack) ...[
              const SizedBox(height: 16),
              const Text(
                'CAPACITY SETTINGS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _faceOutCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Face-out',
                        hintText: '2',
                        helperText: 'items per face-out arm',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _uBarCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'U-Bar',
                        hintText: '3',
                        helperText: 'items per U-bar arm',
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Margin notes for wall sections
            if (_type == SectionType.perimeter) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _prevNoteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Previous Section Note (left margin)',
                  hintText: 'e.g. HOTWALL + PAGE BREAK →',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nextNoteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Next Section Note (right margin)',
                  hintText: 'e.g. ACCESSORIES + SOCIAL+ SHIRTING',
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.initial == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a section title')),
      );
      return;
    }
    final lf = int.tryParse(_lfCtrl.text);
    final faceOut = int.tryParse(_faceOutCtrl.text) ?? 2;
    final uBar = int.tryParse(_uBarCtrl.text) ?? 3;

    Navigator.pop(
      context,
      DisplaySection(
        id: widget.initial?.id,
        title: title,
        type: _type,
        garments: widget.initial?.garments ?? [],
        mannequinLook: widget.initial?.mannequinLook,
        linearFeet: _type == SectionType.perimeter ? (lf ?? 8) : null,
        faceOutCount: faceOut.clamp(1, 20),
        uBarCount: uBar.clamp(1, 20),
        previousSectionNote: _prevNoteCtrl.text.trim().isEmpty
            ? null
            : _prevNoteCtrl.text.trim(),
        nextSectionNote: _nextNoteCtrl.text.trim().isEmpty
            ? null
            : _nextNoteCtrl.text.trim(),
      ),
    );
  }
}
