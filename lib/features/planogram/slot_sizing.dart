import 'dart:math' as math;

// Empty shelf minimum: 1 quarter for item + 1 clearance quarter.
const int emptyShelfQuarters = 2;

/// Hang length in inches by product category (case-insensitive keyword match).
int hangLength(String category) {
  final c = category.toLowerCase();
  if (_any(c, ['pants', 'jeans', 'trousers', 'shorts'])) return 36;
  if (_any(c, ['dress', 'coat', 'gown'])) return 48;
  if (_any(c, ['jacket', 'blazer', 'hoodie', 'sweater'])) return 30;
  if (_any(c, ['shirt', 'blouse', 'top', 'tee', 'tank'])) return 30;
  if (_any(c, ['bra', 'bralette', 'underwear', 'lingerie'])) return 12;
  return 18;
}

/// Folded height in inches for shelf items (coat is hanging-only, not here).
int foldedHeight(String category) {
  final c = category.toLowerCase();
  if (_any(c, ['hoodie', 'sweater', 'gown'])) return 12;
  if (_any(c, ['jacket', 'blazer'])) return 10;
  if (_any(c, ['pants', 'jeans', 'trousers', 'dress'])) return 8;
  if (_any(c, ['shirt', 'blouse', 'top', 'tee', 'tank', 'shorts'])) return 6;
  if (_any(c, ['bra', 'bralette', 'underwear', 'lingerie'])) return 4;
  return 6;
}

bool _any(String c, List<String> kw) => kw.any(c.contains);

/// Quarter-slots needed for a hanging fixture (shoulder/faceout/ubar).
/// Minimum 1. rowHeightIn defaults to 24.0 if omitted.
int autoSpanQuarters(String category, [double rowHeightIn = 24.0]) {
  final needed = hangLength(category);
  final quarterIn = rowHeightIn / 4;
  return math.max(1, (needed / quarterIn).ceil());
}

/// Quarter-slots for a shelf with item (folded height + 1 clearance quarter).
/// Minimum 2 (even for the thinnest item).
int shelfSpanQuarters(String category, [double rowHeightIn = 24.0]) {
  final folded = foldedHeight(category);
  final quarterIn = rowHeightIn / 4;
  return math.max(2, (folded / quarterIn).ceil() + 1);
}
