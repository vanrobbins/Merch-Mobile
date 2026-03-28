import 'dart:ui';

class ColorVariant {
  final String name;
  final int colorValue; // stored as ARGB int

  const ColorVariant({required this.name, required this.colorValue});

  Color get color => Color(colorValue);

  ColorVariant copyWith({String? name, int? colorValue}) {
    return ColorVariant(
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'colorValue': colorValue,
      };

  factory ColorVariant.fromJson(Map<String, dynamic> json) => ColorVariant(
        name: json['name'] as String,
        colorValue: json['colorValue'] as int,
      );

  // ── Default color palettes ───────────────────────────────────────────────

  static const ColorVariant black = ColorVariant(
    name: 'BLK',
    colorValue: 0xFF1C1C1C,
  );
  static const ColorVariant white = ColorVariant(
    name: 'WHT',
    colorValue: 0xFFF5F5F0,
  );
  static const ColorVariant navy = ColorVariant(
    name: 'NVY',
    colorValue: 0xFF1B2A4A,
  );
  static const ColorVariant gray = ColorVariant(
    name: 'GRY',
    colorValue: 0xFF8A8A8A,
  );
  static const ColorVariant heatherGray = ColorVariant(
    name: 'HTR GRY',
    colorValue: 0xFFB0B0B0,
  );
  static const ColorVariant charcoal = ColorVariant(
    name: 'CHAR',
    colorValue: 0xFF3D3D3D,
  );
  static const ColorVariant olive = ColorVariant(
    name: 'OLV',
    colorValue: 0xFF6B7C3F,
  );
  static const ColorVariant forestGreen = ColorVariant(
    name: 'FRST GRN',
    colorValue: 0xFF2D5016,
  );
  static const ColorVariant burgundy = ColorVariant(
    name: 'BURG',
    colorValue: 0xFF6B1A2B,
  );
  static const ColorVariant red = ColorVariant(
    name: 'RED',
    colorValue: 0xFFCC2222,
  );
  static const ColorVariant blue = ColorVariant(
    name: 'BLU',
    colorValue: 0xFF3B6BC2,
  );
  static const ColorVariant lightBlue = ColorVariant(
    name: 'LT BLU',
    colorValue: 0xFF7EB8D4,
  );
  static const ColorVariant camel = ColorVariant(
    name: 'CML',
    colorValue: 0xFFC19A6B,
  );
  static const ColorVariant cream = ColorVariant(
    name: 'CRM',
    colorValue: 0xFFF5EDD8,
  );
  static const ColorVariant foam = ColorVariant(
    name: 'FOAM',
    colorValue: 0xFFD6EBE8,
  );
  static const ColorVariant khaki = ColorVariant(
    name: 'KHK',
    colorValue: 0xFFC4B98B,
  );

  static const List<ColorVariant> defaults = [
    black,
    white,
    navy,
    gray,
    heatherGray,
    charcoal,
    olive,
    forestGreen,
    burgundy,
    red,
    blue,
    lightBlue,
    camel,
    cream,
    foam,
    khaki,
  ];
}
