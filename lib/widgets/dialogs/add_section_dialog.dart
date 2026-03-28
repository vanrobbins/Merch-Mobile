import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/display_section.dart';
import '../../theme/app_theme.dart';

// Valid LF values in 2 LF increments from 2 → 48.
const _lfValues = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 28, 32, 36, 40, 48];

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
  final _faceOutCtrl = TextEditingController(text: '2');
  final _uBarCtrl = TextEditingController(text: '3');

  SectionType _type = SectionType.perimeter;
  int _selectedLf = 8; // default 8 LF

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      final s = widget.initial!;
      _titleCtrl.text = s.title;
      _type = s.type;
      _faceOutCtrl.text = s.faceOutCount.toString();
      _uBarCtrl.text = s.uBarCount.toString();
      _prevNoteCtrl.text = s.previousSectionNote ?? '';
      _nextNoteCtrl.text = s.nextSectionNote ?? '';
      // Snap saved LF to nearest valid increment
      if (s.linearFeet != null) {
        final saved = s.linearFeet!;
        _selectedLf = _lfValues.reduce(
          (a, b) => (a - saved).abs() < (b - saved).abs() ? a : b,
        );
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _prevNoteCtrl.dispose();
    _nextNoteCtrl.dispose();
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
        SectionType.perimeter => 'Perimeter Wall: ${_selectedLf}LF',
        SectionType.table => 'Table',
        SectionType.floorRack => 'Floor Rack',
      };

  void _onLfChanged(int lf) {
    setState(() {
      _selectedLf = lf;
      if (_type == SectionType.perimeter && _isAutoTitle(_titleCtrl.text)) {
        _titleCtrl.text = 'Perimeter Wall: ${lf}LF';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add Section' : 'Edit Section'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section type ────────────────────────────────────────────────
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

            // ── Title ────────────────────────────────────────────────────────
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Section Title',
                hintText: 'e.g. Back Wall: 16LF',
              ),
              textCapitalization: TextCapitalization.words,
            ),

            // ── Wall-specific: LF stepper ────────────────────────────────────
            if (_type == SectionType.perimeter) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'LINEAR FOOTAGE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  // Manual +/- stepper
                  _LfStepper(
                    value: _selectedLf,
                    onDecrement: _selectedLf > _lfValues.first
                        ? () {
                            final idx = _lfValues.indexOf(_selectedLf);
                            if (idx > 0) _onLfChanged(_lfValues[idx - 1]);
                          }
                        : null,
                    onIncrement: _selectedLf < _lfValues.last
                        ? () {
                            final idx = _lfValues.indexOf(_selectedLf);
                            if (idx < _lfValues.length - 1) {
                              _onLfChanged(_lfValues[idx + 1]);
                            }
                          }
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Scrollable chip row of all LF options
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _lfValues.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final lf = _lfValues[i];
                    final selected = lf == _selectedLf;
                    return GestureDetector(
                      onTap: () => _onLfChanged(lf),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              selected ? AppTheme.primary : AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppTheme.primary
                                : AppTheme.outline,
                          ),
                        ),
                        child: Text(
                          '${lf}LF',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Visual bar showing relative wall length
              const SizedBox(height: 10),
              _LfVisualBar(lf: _selectedLf, maxLf: _lfValues.last),
            ],

            // ── Face-out / U-bar counts ──────────────────────────────────────
            if (_type == SectionType.perimeter ||
                _type == SectionType.floorRack) ...[
              const SizedBox(height: 20),
              const Text(
                'CAPACITY PER ARM',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _IntStepper(
                      label: 'Face-out',
                      sublabel: 'items per arm',
                      controller: _faceOutCtrl,
                      min: 1,
                      max: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _IntStepper(
                      label: 'U-bar',
                      sublabel: 'items per arm',
                      controller: _uBarCtrl,
                      min: 1,
                      max: 20,
                    ),
                  ),
                ],
              ),
            ],

            // ── Margin notes ─────────────────────────────────────────────────
            if (_type == SectionType.perimeter) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _prevNoteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Previous section note',
                  hintText: 'Left margin annotation',
                  prefixIcon: Icon(Icons.arrow_back, size: 16),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nextNoteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Next section note',
                  hintText: 'Right margin annotation',
                  prefixIcon: Icon(Icons.arrow_forward, size: 16),
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
        decorativeElements: widget.initial?.decorativeElements ?? [],
        linearFeet: _type == SectionType.perimeter ? _selectedLf : null,
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

// ── LF stepper with +/- buttons ───────────────────────────────────────────────

class _LfStepper extends StatelessWidget {
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const _LfStepper({
    required this.value,
    this.onDecrement,
    this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepBtn(icon: Icons.remove, onTap: onDecrement),
        const SizedBox(width: 6),
        Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            '${value}LF',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 6),
        _StepBtn(icon: Icons.add, onTap: onIncrement),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap != null ? AppTheme.surface : AppTheme.surface.withAlpha(128),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.outline),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? AppTheme.textPrimary : AppTheme.textTertiary,
        ),
      ),
    );
  }
}

// ── Visual LF bar ─────────────────────────────────────────────────────────────

class _LfVisualBar extends StatelessWidget {
  final int lf;
  final int maxLf;

  const _LfVisualBar({required this.lf, required this.maxLf});

  @override
  Widget build(BuildContext context) {
    final fraction = lf / maxLf;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.straighten, size: 14, color: AppTheme.textTertiary),
            const SizedBox(width: 4),
            Text(
              '${lf}LF  ≈  ${(lf * 0.3048).toStringAsFixed(1)}m',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(builder: (_, c) {
          return Stack(
            children: [
              Container(
                height: 8,
                width: c.maxWidth,
                decoration: BoxDecoration(
                  color: AppTheme.outline,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 8,
                width: c.maxWidth * fraction,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

// ── Integer stepper (face-out / u-bar) ───────────────────────────────────────

class _IntStepper extends StatefulWidget {
  final String label;
  final String sublabel;
  final TextEditingController controller;
  final int min;
  final int max;

  const _IntStepper({
    required this.label,
    required this.sublabel,
    required this.controller,
    required this.min,
    required this.max,
  });

  @override
  State<_IntStepper> createState() => _IntStepperState();
}

class _IntStepperState extends State<_IntStepper> {
  int get _value => int.tryParse(widget.controller.text) ?? widget.min;

  void _change(int delta) {
    final next = (_value + delta).clamp(widget.min, widget.max);
    widget.controller.text = next.toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
          Text(widget.sublabel,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textTertiary)),
          const SizedBox(height: 8),
          Row(
            children: [
              _StepBtn(
                icon: Icons.remove,
                onTap: _value > widget.min ? () => _change(-1) : null,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$_value',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              _StepBtn(
                icon: Icons.add,
                onTap: _value < widget.max ? () => _change(1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
