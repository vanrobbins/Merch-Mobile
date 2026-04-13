import 'package:flutter/material.dart';
import '../../core/models/fixture.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

class BeforeAfterPreview extends StatefulWidget {
  const BeforeAfterPreview({
    super.key,
    required this.currentFixtures,
    required this.suggestedFixtures,
  });

  final List<Fixture> currentFixtures;
  final List<Fixture> suggestedFixtures;

  @override
  State<BeforeAfterPreview> createState() => _BeforeAfterPreviewState();
}

class _BeforeAfterPreviewState extends State<BeforeAfterPreview> {
  double _splitRatio = 0.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final leftWidth = totalWidth * _splitRatio;

        return Stack(
          children: [
            Row(
              children: [
                // Left panel — BEFORE
                SizedBox(
                  width: leftWidth,
                  child: _PanelContent(
                    eyebrow: 'BEFORE',
                    fixtures: widget.currentFixtures,
                  ),
                ),
                // Right panel — AFTER
                Expanded(
                  child: _PanelContent(
                    eyebrow: 'AFTER',
                    fixtures: widget.suggestedFixtures,
                    isRight: true,
                  ),
                ),
              ],
            ),
            // Draggable divider
            Positioned(
              left: leftWidth - 12,
              top: 0,
              bottom: 0,
              width: 24,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _splitRatio = ((_splitRatio * totalWidth +
                                details.delta.dx) /
                            totalWidth)
                        .clamp(0.15, 0.85);
                  });
                },
                child: Center(
                  child: Container(
                    width: 4,
                    color: AppTheme.accent,
                    child: Center(
                      child: Container(
                        width: 24,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius:
                              BorderRadius.circular(DesignTokens.radiusSm),
                        ),
                        child: const Icon(
                          Icons.drag_indicator,
                          color: Colors.white,
                          size: DesignTokens.iconSm,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PanelContent extends StatelessWidget {
  const _PanelContent({
    required this.eyebrow,
    required this.fixtures,
    this.isRight = false,
  });

  final String eyebrow;
  final List<Fixture> fixtures;
  final bool isRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isRight
            ? AppTheme.canvasBg
            : const Color(0xFFE8E5DE),
        border: isRight
            ? null
            : const Border(
                right: BorderSide(color: Color(0xFFD0CCC4), width: 1),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceMd,
              vertical: DesignTokens.spaceSm,
            ),
            child: Text(
              eyebrow,
              style: const TextStyle(
                fontSize: DesignTokens.typeXs,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(DesignTokens.spaceMd),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusSm),
              ),
              child: Center(
                child: Text(
                  '${fixtures.length} fixture${fixtures.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: DesignTokens.typeMd,
                    color: AppTheme.textSecondary,
                    fontWeight: DesignTokens.weightMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
