enum GarmentType {
  tshirt,
  hoodie,
  quarterZip,
  halfZip,
  jacket,
  jogger,
  pants,
  shorts,
  vest,
  hat,
  // ── Tops (extended) ──────────────────────────────────────────────────────
  tankTop,
  cropTop,
  longSleeveCropTop,
  // ── Footwear ─────────────────────────────────────────────────────────────
  sneaker,
  runningShoe,
  boot,
  sandal,
  // ── Intimates / Sports Apparel ────────────────────────────────────────────
  bra,
  // ── Other ─────────────────────────────────────────────────────────────────
  accessory,
}

extension GarmentTypeX on GarmentType {
  String get displayName => switch (this) {
        GarmentType.tshirt => 'T-Shirt',
        GarmentType.hoodie => 'Hoodie',
        GarmentType.quarterZip => 'Quarter Zip',
        GarmentType.halfZip => 'Half Zip',
        GarmentType.jacket => 'Jacket',
        GarmentType.jogger => 'Jogger',
        GarmentType.pants => 'Pants',
        GarmentType.shorts => 'Shorts',
        GarmentType.vest => 'Vest',
        GarmentType.hat => 'Hat',
        GarmentType.tankTop => 'Tank Top',
        GarmentType.cropTop => 'Crop Top',
        GarmentType.longSleeveCropTop => 'LS Crop Top',
        GarmentType.sneaker => 'Sneaker',
        GarmentType.runningShoe => 'Running Shoe',
        GarmentType.boot => 'Boot',
        GarmentType.sandal => 'Sandal / Slide',
        GarmentType.bra => 'Bra / Sports Bra',
        GarmentType.accessory => 'Accessory',
      };

  /// Grouping label for the Add Garment type picker.
  String get group => switch (this) {
        GarmentType.tshirt ||
        GarmentType.hoodie ||
        GarmentType.quarterZip ||
        GarmentType.halfZip ||
        GarmentType.jacket ||
        GarmentType.vest ||
        GarmentType.tankTop ||
        GarmentType.cropTop ||
        GarmentType.longSleeveCropTop ||
        GarmentType.bra =>
          'Tops',
        GarmentType.jogger ||
        GarmentType.pants ||
        GarmentType.shorts =>
          'Bottoms',
        GarmentType.sneaker ||
        GarmentType.runningShoe ||
        GarmentType.boot ||
        GarmentType.sandal =>
          'Footwear',
        GarmentType.hat || GarmentType.accessory => 'Accessories',
      };

  /// Whether this garment type hangs on a rack (vs. folded on a table).
  bool get isHanging => switch (this) {
        GarmentType.tshirt => true,
        GarmentType.hoodie => true,
        GarmentType.quarterZip => true,
        GarmentType.halfZip => true,
        GarmentType.jacket => true,
        GarmentType.jogger => true,
        GarmentType.pants => true,
        GarmentType.shorts => true,
        GarmentType.vest => true,
        GarmentType.tankTop => true,
        GarmentType.cropTop => true,
        GarmentType.longSleeveCropTop => true,
        GarmentType.bra => false,
        GarmentType.hat => false,
        GarmentType.sneaker => false,
        GarmentType.runningShoe => false,
        GarmentType.boot => false,
        GarmentType.sandal => false,
        GarmentType.accessory => false,
      };

  /// Suggested fixture position: shelf, upper_rod, mid_rod, or lower_rod.
  String get suggestedPosition => switch (this) {
        GarmentType.hat => 'shelf',
        GarmentType.sneaker => 'shelf',
        GarmentType.runningShoe => 'shelf',
        GarmentType.boot => 'shelf',
        GarmentType.sandal => 'shelf',
        GarmentType.bra => 'shelf',
        GarmentType.accessory => 'shelf',
        GarmentType.jacket => 'upper_rod',
        GarmentType.hoodie => 'upper_rod',
        GarmentType.vest => 'upper_rod',
        GarmentType.quarterZip => 'upper_rod',
        GarmentType.halfZip => 'upper_rod',
        GarmentType.tshirt => 'mid_rod',
        GarmentType.tankTop => 'mid_rod',
        GarmentType.cropTop => 'mid_rod',
        GarmentType.longSleeveCropTop => 'mid_rod',
        GarmentType.jogger => 'lower_rod',
        GarmentType.pants => 'lower_rod',
        GarmentType.shorts => 'lower_rod',
      };
}
