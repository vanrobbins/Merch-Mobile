import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_theme.dart';
import 'planogram_slot.dart';

/// Renders a product silhouette SVG for a planogram slot.
///
/// Face-out mode uses existing `assets/silhouettes/<type>.svg`.
/// Shoulder-out and folded use `assets/silhouettes/<mode>/<type>.svg`
/// (added by Agent 5). Until those assets exist, falls back to a
/// color-filled rectangle with a label.
class SlotSilhouetteRenderer extends StatelessWidget {
  const SlotSilhouetteRenderer({
    super.key,
    required this.slot,
    required this.productType,
    this.width = 40.0,
    this.height = 52.0,
  });

  final PgSlot slot;
  final String? productType; // e.g. 'jacket', 'pant', 'shirt_ss'
  final double width;
  final double height;

  /// Resolve the SVG asset path for a given mode and product type.
  static String assetPath(String mode, String type) {
    switch (mode) {
      case 'shoulder_out':
        return 'assets/silhouettes/shoulder_out/$type.svg';
      case 'folded':
        return 'assets/silhouettes/folded/$type.svg';
      case 'face_out':
      default:
        return 'assets/silhouettes/$type.svg';
    }
  }

  Color? _parsedColor() {
    final hex = slot.colorHex;
    if (hex == null || hex.isEmpty) return null;
    try {
      return Color(
          int.parse('0xFF${hex.replaceAll('#', '').padLeft(6, '0')}'));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = productType ?? 'other';
    final path = assetPath(slot.presentationMode, type);
    final color = _parsedColor();

    // Rotation transform wraps the SVG
    Widget svg = SvgPicture.asset(
      path,
      width: width,
      height: height,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
      errorBuilder: (_, __, ___) => _FallbackBlock(
        width: width,
        height: height,
        color: color ?? AppTheme.canvasBg,
        label: type.replaceAll('_', ' ').toUpperCase(),
      ),
    );

    if (slot.rotation != 0) {
      svg = Transform.rotate(
        angle: slot.rotation * 3.14159265 / 180,
        child: svg,
      );
    }

    return svg;
  }
}

class _FallbackBlock extends StatelessWidget {
  const _FallbackBlock({
    required this.width,
    required this.height,
    required this.color,
    required this.label,
  });

  final double width;
  final double height;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.w600,
            color: color.computeLuminance() > 0.5
                ? Colors.black87
                : Colors.white,
          ),
        ),
      ),
    );
  }
}
