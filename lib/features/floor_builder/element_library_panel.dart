import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

class ElementLibraryPanel extends StatelessWidget {
  const ElementLibraryPanel({
    super.key,
    required this.onFixtureSelected,
    required this.onWallSelected,
    this.onDragStarted,
    this.onMannequinSelected,
    this.onPlatformSelected,
    this.onPropSelected,
  });
  final void Function(String fixtureType) onFixtureSelected;
  final VoidCallback onWallSelected;
  final VoidCallback? onDragStarted;
  final VoidCallback? onMannequinSelected;
  final VoidCallback? onPlatformSelected;
  final VoidCallback? onPropSelected;

  static const _types = [
    _FixtureTile('rack', Icons.view_column_outlined, 'RACK'),
    _FixtureTile('table', Icons.table_restaurant_outlined, 'TABLE'),
    _FixtureTile('shelf', Icons.horizontal_split_outlined, 'SHELF'),
    _FixtureTile('partition', Icons.horizontal_rule, 'PARTITION'),
    _FixtureTile('wall', Icons.crop_square_outlined, 'WALL'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusLg)),
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
                color: AppTheme.divider,
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
                draggable: t.type != 'wall',
                onTap: () {
                  Navigator.pop(context);
                  if (t.type == 'wall') {
                    onWallSelected();
                  } else {
                    onFixtureSelected(t.type);
                  }
                },
                onDragStarted: (t.type == 'wall') ? null : onDragStarted,
              )).toList(),
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),
          const Padding(
            padding: EdgeInsets.fromLTRB(
                DesignTokens.spaceMd, DesignTokens.spaceSm, DesignTokens.spaceMd, DesignTokens.spaceSm),
            child: Text(
              'MANNEQUINS & PROPS',
              style: TextStyle(
                fontSize: DesignTokens.typeXs,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                DesignTokens.spaceMd, 0, DesignTokens.spaceMd, DesignTokens.spaceMd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (onMannequinSelected != null)
                  _SimpleTile(
                    icon: Icons.accessibility_new_outlined,
                    label: 'MANNEQUIN',
                    onTap: () {
                      Navigator.pop(context);
                      onMannequinSelected!();
                    },
                  ),
                if (onPlatformSelected != null)
                  _SimpleTile(
                    icon: Icons.crop_square_outlined,
                    label: 'PLATFORM',
                    onTap: () {
                      Navigator.pop(context);
                      onPlatformSelected!();
                    },
                  ),
                if (onPropSelected != null)
                  _SimpleTile(
                    icon: Icons.park_outlined,
                    label: 'PROP',
                    onTap: () {
                      Navigator.pop(context);
                      onPropSelected!();
                    },
                  ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _DraggableTile extends StatelessWidget {
  const _DraggableTile({
    required this.tile,
    required this.onTap,
    this.onDragStarted,
    this.draggable = true,
  });
  final _FixtureTile tile;
  final VoidCallback onTap;
  final VoidCallback? onDragStarted;
  final bool draggable;

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
      child: draggable ? _buildDraggable() : _tileBox(),
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

class _SimpleTile extends StatelessWidget {
  const _SimpleTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.08),
              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Icon(icon, size: 32, color: AppTheme.accent),
          ),
          const SizedBox(height: DesignTokens.spaceXs),
          Text(
            label,
            style: const TextStyle(
              fontSize: DesignTokens.typeXs,
              fontWeight: DesignTokens.weightBold,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
              color: AppTheme.accent,
            ),
          ),
        ],
      ),
    );
  }
}
