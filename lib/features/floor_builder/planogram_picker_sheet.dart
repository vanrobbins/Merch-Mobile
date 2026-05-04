import 'package:flutter/material.dart';
import '../../core/models/planogram.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_text_field.dart';
import 'planogram_slot_count.dart';

class PlanogramPickerSheet extends StatefulWidget {
  const PlanogramPickerSheet({
    super.key,
    required this.planograms,
    required this.currentPlanogramId,
    required this.fixtureLabel,
    required this.onSelect,
  });

  final List<Planogram> planograms;
  final String? currentPlanogramId;
  final String fixtureLabel;
  final void Function(String? planogramId) onSelect;

  @override
  State<PlanogramPickerSheet> createState() => _PlanogramPickerSheetState();
}

class _PlanogramPickerSheetState extends State<PlanogramPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Planogram> get _filtered {
    if (_query.isEmpty) return widget.planograms;
    final q = _query.toLowerCase();
    return widget.planograms.where((p) => p.title.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusLg)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: DesignTokens.spaceSm),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    DesignTokens.spaceMd, DesignTokens.spaceSm, DesignTokens.spaceMd, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ASSIGN PLANOGRAM',
                      style: TextStyle(
                        fontSize: DesignTokens.typeLg,
                        fontWeight: DesignTokens.weightBold,
                        letterSpacing: DesignTokens.letterSpacingEyebrow,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.fixtureLabel,
                      style: const TextStyle(
                        fontSize: DesignTokens.typeXs,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceSm),
                    MmTextField(
                      controller: _searchCtrl,
                      hint: 'Search planograms…',
                      prefix: const Icon(Icons.search, size: 20),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.spaceXs),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  children: [
                    if (widget.currentPlanogramId != null) ...[
                      ListTile(
                        leading: const Icon(Icons.remove_circle_outline,
                            color: AppTheme.errorColor),
                        title: const Text(
                          'Remove assignment',
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                        onTap: () {
                          widget.onSelect(null);
                          Navigator.of(context).pop();
                        },
                      ),
                      const Divider(height: 1, color: AppTheme.divider),
                    ],
                    ..._filtered.map((p) {
                      final isSelected = p.id == widget.currentPlanogramId;
                      final slotCount = countPlanogramSlots(p.slotsJson);
                      return ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.accent
                                : AppTheme.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                          ),
                          child: Icon(
                            Icons.grid_view_rounded,
                            color: isSelected ? AppTheme.canvasBg : AppTheme.accent,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          p.title,
                          style: TextStyle(
                            fontWeight: DesignTokens.weightBold,
                            color: isSelected ? AppTheme.accent : AppTheme.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${p.season} · $slotCount slots',
                          style: const TextStyle(
                            fontSize: DesignTokens.typeXs,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: AppTheme.accent)
                            : null,
                        onTap: () {
                          widget.onSelect(p.id);
                          Navigator.of(context).pop();
                        },
                      );
                    }),
                    if (_filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(DesignTokens.spaceLg),
                        child: Center(
                          child: Text(
                            'No planograms found',
                            style: TextStyle(color: AppTheme.textHint),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
