import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import 'zone_edge_helper.dart';

class WallPlacementSheet extends StatefulWidget {
  const WallPlacementSheet({
    super.key,
    required this.edges,
    required this.pixelsPerFt,
    required this.onPlace,
  });
  final List<ZoneEdge> edges;
  final double pixelsPerFt;
  final void Function(ZoneEdge edge, double lengthFt) onPlace;

  @override
  State<WallPlacementSheet> createState() => _WallPlacementSheetState();
}

class _WallPlacementSheetState extends State<WallPlacementSheet> {
  ZoneEdge? _selectedEdge;
  final _lengthCtrl = TextEditingController();

  @override
  void dispose() {
    _lengthCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusLg)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
            padding: const EdgeInsets.all(DesignTokens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'PLACE WALL',
                  style: TextStyle(
                    fontSize: DesignTokens.typeLg,
                    fontWeight: DesignTokens.weightBold,
                    letterSpacing: DesignTokens.letterSpacingEyebrow,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceXs),
                Text(
                  _selectedEdge == null ? 'SELECT A ZONE EDGE' : 'ENTER WALL LENGTH',
                  style: const TextStyle(
                    fontSize: DesignTokens.typeXs,
                    color: AppTheme.textSecondary,
                    letterSpacing: DesignTokens.letterSpacingEyebrow,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceMd),
                if (_selectedEdge == null) ...[
                  ...widget.edges.asMap().entries.map((entry) {
                    final edge = entry.value;
                    final num = entry.key + 1;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: AppTheme.accent,
                        child: Text(
                          '$num',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: DesignTokens.typeXs,
                            fontWeight: DesignTokens.weightBold,
                          ),
                        ),
                      ),
                      title: Text(
                        'EDGE $num',
                        style: const TextStyle(
                          fontWeight: DesignTokens.weightBold,
                          fontSize: DesignTokens.typeSm,
                          letterSpacing: DesignTokens.letterSpacingEyebrow,
                        ),
                      ),
                      subtitle: Text(
                        '${edge.lengthFt.toStringAsFixed(1)} ft',
                        style: const TextStyle(
                          fontSize: DesignTokens.typeXs,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                      onTap: () => setState(() {
                        _selectedEdge = edge;
                        _lengthCtrl.text = edge.lengthFt.toStringAsFixed(1);
                      }),
                    );
                  }),
                ] else ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppTheme.accent,
                        child: Text(
                          '${_selectedEdge!.index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: DesignTokens.typeXs,
                            fontWeight: DesignTokens.weightBold,
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spaceSm),
                      Text(
                        'EDGE ${_selectedEdge!.index + 1}  •  ${_selectedEdge!.lengthFt.toStringAsFixed(1)} ft',
                        style: const TextStyle(
                          fontWeight: DesignTokens.weightBold,
                          fontSize: DesignTokens.typeSm,
                          letterSpacing: DesignTokens.letterSpacingEyebrow,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _selectedEdge = null),
                        child: const Text(
                          'CHANGE',
                          style: TextStyle(
                            fontSize: DesignTokens.typeXs,
                            color: AppTheme.accent,
                            fontWeight: DesignTokens.weightBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spaceMd),
                  TextField(
                    controller: _lengthCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Wall length',
                      border: UnderlineInputBorder(),
                      suffixText: 'ft',
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceLg),
                  ElevatedButton(
                    onPressed: () {
                      final parsed = double.tryParse(_lengthCtrl.text) ?? 4.0;
                      final lengthFt = parsed < 0.5 ? 0.5 : parsed;
                      widget.onPlace(_selectedEdge!, lengthFt);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(AppTheme.borderRadius)),
                      ),
                    ),
                    child: const Text('PLACE WALL'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
