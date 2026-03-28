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
  shoes,
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
        GarmentType.shoes => 'Shoes',
        GarmentType.accessory => 'Accessory',
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
        GarmentType.hat => false,
        GarmentType.shoes => false,
        GarmentType.accessory => false,
      };

  /// Suggested fixture position: top shelf, mid shelf, or hanging rod.
  String get suggestedPosition => switch (this) {
        GarmentType.hat => 'shelf',
        GarmentType.shoes => 'shelf',
        GarmentType.accessory => 'shelf',
        GarmentType.jacket => 'upper_rod',
        GarmentType.hoodie => 'upper_rod',
        GarmentType.vest => 'upper_rod',
        GarmentType.quarterZip => 'upper_rod',
        GarmentType.halfZip => 'upper_rod',
        GarmentType.tshirt => 'mid_rod',
        GarmentType.jogger => 'lower_rod',
        GarmentType.pants => 'lower_rod',
        GarmentType.shorts => 'lower_rod',
      };
}
