import 'dart:convert';
import 'dart:ui';

/// Converts between List<Offset> and the JSON stored in zones.shapePoints.
class ZoneShape {
  static String encode(List<Offset> points) =>
      jsonEncode(points.map((p) => {'x': p.dx, 'y': p.dy}).toList());

  static List<Offset> decode(String? json) {
    if (json == null || json.isEmpty) return [];
    final list = jsonDecode(json) as List;
    return list
        .map((e) => Offset((e['x'] as num).toDouble(), (e['y'] as num).toDouble()))
        .toList();
  }

  /// Default rectangle shape at given position, in canvas units (0.0–1.0 normalized).
  static List<Offset> defaultRect(Offset center, {double w = 0.2, double h = 0.15}) {
    final hw = w / 2;
    final hh = h / 2;
    return [
      Offset(center.dx - hw, center.dy - hh),
      Offset(center.dx + hw, center.dy - hh),
      Offset(center.dx + hw, center.dy + hh),
      Offset(center.dx - hw, center.dy + hh),
    ];
  }

  /// Predefined shapes — all normalized to fit in a 0.2x0.2 box centered at origin.
  static Map<String, List<Offset>> get presets => {
    'rectangle': [
      const Offset(-0.10, -0.07),
      const Offset( 0.10, -0.07),
      const Offset( 0.10,  0.07),
      const Offset(-0.10,  0.07),
    ],
    'l_shape': [
      const Offset(-0.10, -0.10),
      const Offset( 0.10, -0.10),
      const Offset( 0.10,  0.00),
      const Offset( 0.00,  0.00),
      const Offset( 0.00,  0.10),
      const Offset(-0.10,  0.10),
    ],
    't_shape': [
      const Offset(-0.10, -0.10),
      const Offset( 0.10, -0.10),
      const Offset( 0.10, -0.03),
      const Offset( 0.03, -0.03),
      const Offset( 0.03,  0.10),
      const Offset(-0.03,  0.10),
      const Offset(-0.03, -0.03),
      const Offset(-0.10, -0.03),
    ],
    'u_shape': [
      const Offset(-0.10, -0.10),
      const Offset(-0.03, -0.10),
      const Offset(-0.03,  0.03),
      const Offset( 0.03,  0.03),
      const Offset( 0.03, -0.10),
      const Offset( 0.10, -0.10),
      const Offset( 0.10,  0.10),
      const Offset(-0.10,  0.10),
    ],
  };

  /// Translate a preset shape to a center position.
  static List<Offset> presetAt(String name, Offset center) {
    final pts = presets[name] ?? presets['rectangle']!;
    return pts.map((p) => p + center).toList();
  }
}
