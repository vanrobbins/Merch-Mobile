import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

class ElementLibraryPanel extends StatelessWidget {
  const ElementLibraryPanel({super.key, required this.onFixtureSelected, this.onDragStarted});
  final void Function(String fixtureType) onFixtureSelected;
  // Called when a drag begins so the parent can dismiss the sheet.
  final VoidCallback? onDragStarted;

  static const _types = [
    _FixtureTile('rack', Icons.view_column_outlined, 'RACK'),
    _FixtureTile('table', Icons.table_restaurant_outlined, 'TABLE'),
    _FixtureTile('shelf', Icons.horizontal_split_outlined, 'SHELF'),
    _FixtureTile('wall', Icons.crop_square_outlined, 'WALL'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radiusLg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: DesignTokens.spaceSm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadius),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(DesignTokens.spaceMd),
            child: Text('ELEMENT LIBRARY', style: TextStyle(
              fontSize: DesignTokens.typeLg,
              fontWeight: DesignTokens.weightBold,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
            )),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceMd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _types.map((t) => _DraggableTile(
                tile: t,
                onTap: () {
                  Navigator.pop(context);
                  onFixtureSelected(t.type);
                },
                onDragStarted: onDragStarted,
              )).toList(),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _DraggableTile extends StatelessWidget {
  const _DraggableTile({required this.tile, required this.onTap, this.onDragStarted});
  final _FixtureTile tile;
  final VoidCallback onTap;
  final VoidCallback? onDragStarted;

  Widget _tileBox({double opacity = 1.0}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.06 * opacity),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2 * opacity)),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: Icon(tile.icon, size: 32, color: AppTheme.primary.withValues(alpha: opacity)),
        ),
        const SizedBox(height: DesignTokens.spaceXs),
        Text(tile.label, style: TextStyle(
          fontSize: DesignTokens.typeXs,
          fontWeight: DesignTokens.weightBold,
          letterSpacing: DesignTokens.letterSpacingEyebrow,
          color: Colors.black.withValues(alpha: opacity),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _buildDraggable(),
    );
  }

  Widget _buildDraggable() {
    return Draggable<String>(
      data: tile.type,
      onDragStarted: onDragStarted,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.75,
          child: Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Icon(tile.icon, size: 32, color: AppTheme.primary),
          ),
        ),
      ),
      childWhenDragging: _tileBox(opacity: 0.35),
      child: _tileBox(),
    );
  }
}

class _FixtureTile {
  const _FixtureTile(this.type, this.icon, this.label);
  final String type;
  final IconData icon;
  final String label;
}
