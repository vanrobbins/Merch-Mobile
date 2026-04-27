import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';

class PlanogramPickerSheet extends StatefulWidget {
  const PlanogramPickerSheet({
    super.key,
    required this.planograms,
    required this.currentPlanogramId,
    required this.fixtureLabel,
    required this.onSelect,
  });

  final List<PlanogramsTableData> planograms;
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

  List<PlanogramsTableData> get _filtered {
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
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ASSIGN PLANOGRAM',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                    Text(widget.fixtureLabel,
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search planograms\u2026',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  children: [
                    if (widget.currentPlanogramId != null) ...[
                      ListTile(
                        leading: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        title: const Text('Remove assignment',
                            style: TextStyle(color: Colors.red)),
                        onTap: () {
                          widget.onSelect(null);
                          Navigator.of(context).pop();
                        },
                      ),
                      const Divider(height: 1),
                    ],
                    ..._filtered.map((p) {
                      final isSelected = p.id == widget.currentPlanogramId;
                      final slotCount = _countSlots(p.slotsJson);
                      return ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.accent
                                : AppTheme.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Icon(Icons.grid_view_rounded,
                              color: isSelected ? Colors.white : AppTheme.accent, size: 18),
                        ),
                        title: Text(p.title,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isSelected ? AppTheme.accent : null)),
                        subtitle: Text('${p.season} \u00b7 $slotCount slots',
                            style: const TextStyle(fontSize: 11)),
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
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('No planograms found',
                              style: TextStyle(color: Colors.grey)),
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

  int _countSlots(String slotsJson) {
    if (slotsJson == '[]') return 0;
    return '['.allMatches(slotsJson).length - 1;
  }
}
