// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ZonesTableTable extends ZonesTable
    with TableInfo<$ZonesTableTable, ZonesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZonesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _zoneTypeMeta =
      const VerificationMeta('zoneType');
  @override
  late final GeneratedColumn<String> zoneType = GeneratedColumn<String>(
      'zone_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _storeIdMeta =
      const VerificationMeta('storeId');
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
      'store_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _posXMeta = const VerificationMeta('posX');
  @override
  late final GeneratedColumn<double> posX = GeneratedColumn<double>(
      'pos_x', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _posYMeta = const VerificationMeta('posY');
  @override
  late final GeneratedColumn<double> posY = GeneratedColumn<double>(
      'pos_y', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<double> width = GeneratedColumn<double>(
      'width', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.2));
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
      'height', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.2));
  static const VerificationMeta _shapePointsMeta =
      const VerificationMeta('shapePoints');
  @override
  late final GeneratedColumn<String> shapePoints = GeneratedColumn<String>(
      'shape_points', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        colorValue,
        zoneType,
        storeId,
        posX,
        posY,
        width,
        height,
        shapePoints,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'zones_table';
  @override
  VerificationContext validateIntegrity(Insertable<ZonesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('zone_type')) {
      context.handle(_zoneTypeMeta,
          zoneType.isAcceptableOrUnknown(data['zone_type']!, _zoneTypeMeta));
    } else if (isInserting) {
      context.missing(_zoneTypeMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(_storeIdMeta,
          storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta));
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('pos_x')) {
      context.handle(
          _posXMeta, posX.isAcceptableOrUnknown(data['pos_x']!, _posXMeta));
    }
    if (data.containsKey('pos_y')) {
      context.handle(
          _posYMeta, posY.isAcceptableOrUnknown(data['pos_y']!, _posYMeta));
    }
    if (data.containsKey('width')) {
      context.handle(
          _widthMeta, width.isAcceptableOrUnknown(data['width']!, _widthMeta));
    }
    if (data.containsKey('height')) {
      context.handle(_heightMeta,
          height.isAcceptableOrUnknown(data['height']!, _heightMeta));
    }
    if (data.containsKey('shape_points')) {
      context.handle(
          _shapePointsMeta,
          shapePoints.isAcceptableOrUnknown(
              data['shape_points']!, _shapePointsMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ZonesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ZonesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value'])!,
      zoneType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}zone_type'])!,
      storeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store_id'])!,
      posX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pos_x'])!,
      posY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pos_y'])!,
      width: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}width'])!,
      height: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}height'])!,
      shapePoints: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shape_points']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ZonesTableTable createAlias(String alias) {
    return $ZonesTableTable(attachedDatabase, alias);
  }
}

class ZonesTableData extends DataClass implements Insertable<ZonesTableData> {
  final String id;
  final String name;
  final int colorValue;
  final String zoneType;
  final String storeId;
  final double posX;
  final double posY;
  final double width;
  final double height;
  final String? shapePoints;
  final DateTime updatedAt;
  const ZonesTableData(
      {required this.id,
      required this.name,
      required this.colorValue,
      required this.zoneType,
      required this.storeId,
      required this.posX,
      required this.posY,
      required this.width,
      required this.height,
      this.shapePoints,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color_value'] = Variable<int>(colorValue);
    map['zone_type'] = Variable<String>(zoneType);
    map['store_id'] = Variable<String>(storeId);
    map['pos_x'] = Variable<double>(posX);
    map['pos_y'] = Variable<double>(posY);
    map['width'] = Variable<double>(width);
    map['height'] = Variable<double>(height);
    if (!nullToAbsent || shapePoints != null) {
      map['shape_points'] = Variable<String>(shapePoints);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ZonesTableCompanion toCompanion(bool nullToAbsent) {
    return ZonesTableCompanion(
      id: Value(id),
      name: Value(name),
      colorValue: Value(colorValue),
      zoneType: Value(zoneType),
      storeId: Value(storeId),
      posX: Value(posX),
      posY: Value(posY),
      width: Value(width),
      height: Value(height),
      shapePoints: shapePoints == null && nullToAbsent
          ? const Value.absent()
          : Value(shapePoints),
      updatedAt: Value(updatedAt),
    );
  }

  factory ZonesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ZonesTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      zoneType: serializer.fromJson<String>(json['zoneType']),
      storeId: serializer.fromJson<String>(json['storeId']),
      posX: serializer.fromJson<double>(json['posX']),
      posY: serializer.fromJson<double>(json['posY']),
      width: serializer.fromJson<double>(json['width']),
      height: serializer.fromJson<double>(json['height']),
      shapePoints: serializer.fromJson<String?>(json['shapePoints']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorValue': serializer.toJson<int>(colorValue),
      'zoneType': serializer.toJson<String>(zoneType),
      'storeId': serializer.toJson<String>(storeId),
      'posX': serializer.toJson<double>(posX),
      'posY': serializer.toJson<double>(posY),
      'width': serializer.toJson<double>(width),
      'height': serializer.toJson<double>(height),
      'shapePoints': serializer.toJson<String?>(shapePoints),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ZonesTableData copyWith(
          {String? id,
          String? name,
          int? colorValue,
          String? zoneType,
          String? storeId,
          double? posX,
          double? posY,
          double? width,
          double? height,
          Value<String?> shapePoints = const Value.absent(),
          DateTime? updatedAt}) =>
      ZonesTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        colorValue: colorValue ?? this.colorValue,
        zoneType: zoneType ?? this.zoneType,
        storeId: storeId ?? this.storeId,
        posX: posX ?? this.posX,
        posY: posY ?? this.posY,
        width: width ?? this.width,
        height: height ?? this.height,
        shapePoints: shapePoints.present ? shapePoints.value : this.shapePoints,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ZonesTableData copyWithCompanion(ZonesTableCompanion data) {
    return ZonesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorValue:
          data.colorValue.present ? data.colorValue.value : this.colorValue,
      zoneType: data.zoneType.present ? data.zoneType.value : this.zoneType,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      posX: data.posX.present ? data.posX.value : this.posX,
      posY: data.posY.present ? data.posY.value : this.posY,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      shapePoints:
          data.shapePoints.present ? data.shapePoints.value : this.shapePoints,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ZonesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('zoneType: $zoneType, ')
          ..write('storeId: $storeId, ')
          ..write('posX: $posX, ')
          ..write('posY: $posY, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('shapePoints: $shapePoints, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, colorValue, zoneType, storeId, posX,
      posY, width, height, shapePoints, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ZonesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorValue == this.colorValue &&
          other.zoneType == this.zoneType &&
          other.storeId == this.storeId &&
          other.posX == this.posX &&
          other.posY == this.posY &&
          other.width == this.width &&
          other.height == this.height &&
          other.shapePoints == this.shapePoints &&
          other.updatedAt == this.updatedAt);
}

class ZonesTableCompanion extends UpdateCompanion<ZonesTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> colorValue;
  final Value<String> zoneType;
  final Value<String> storeId;
  final Value<double> posX;
  final Value<double> posY;
  final Value<double> width;
  final Value<double> height;
  final Value<String?> shapePoints;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ZonesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.zoneType = const Value.absent(),
    this.storeId = const Value.absent(),
    this.posX = const Value.absent(),
    this.posY = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.shapePoints = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ZonesTableCompanion.insert({
    required String id,
    required String name,
    required int colorValue,
    required String zoneType,
    required String storeId,
    this.posX = const Value.absent(),
    this.posY = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.shapePoints = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        colorValue = Value(colorValue),
        zoneType = Value(zoneType),
        storeId = Value(storeId),
        updatedAt = Value(updatedAt);
  static Insertable<ZonesTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? colorValue,
    Expression<String>? zoneType,
    Expression<String>? storeId,
    Expression<double>? posX,
    Expression<double>? posY,
    Expression<double>? width,
    Expression<double>? height,
    Expression<String>? shapePoints,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorValue != null) 'color_value': colorValue,
      if (zoneType != null) 'zone_type': zoneType,
      if (storeId != null) 'store_id': storeId,
      if (posX != null) 'pos_x': posX,
      if (posY != null) 'pos_y': posY,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (shapePoints != null) 'shape_points': shapePoints,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ZonesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? colorValue,
      Value<String>? zoneType,
      Value<String>? storeId,
      Value<double>? posX,
      Value<double>? posY,
      Value<double>? width,
      Value<double>? height,
      Value<String?>? shapePoints,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ZonesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      zoneType: zoneType ?? this.zoneType,
      storeId: storeId ?? this.storeId,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      width: width ?? this.width,
      height: height ?? this.height,
      shapePoints: shapePoints ?? this.shapePoints,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (zoneType.present) {
      map['zone_type'] = Variable<String>(zoneType.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (posX.present) {
      map['pos_x'] = Variable<double>(posX.value);
    }
    if (posY.present) {
      map['pos_y'] = Variable<double>(posY.value);
    }
    if (width.present) {
      map['width'] = Variable<double>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (shapePoints.present) {
      map['shape_points'] = Variable<String>(shapePoints.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ZonesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('zoneType: $zoneType, ')
          ..write('storeId: $storeId, ')
          ..write('posX: $posX, ')
          ..write('posY: $posY, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('shapePoints: $shapePoints, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FixturesTableTable extends FixturesTable
    with TableInfo<$FixturesTableTable, FixturesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FixturesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _zoneIdMeta = const VerificationMeta('zoneId');
  @override
  late final GeneratedColumn<String> zoneId = GeneratedColumn<String>(
      'zone_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fixtureTypeMeta =
      const VerificationMeta('fixtureType');
  @override
  late final GeneratedColumn<String> fixtureType = GeneratedColumn<String>(
      'fixture_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _posXMeta = const VerificationMeta('posX');
  @override
  late final GeneratedColumn<double> posX = GeneratedColumn<double>(
      'pos_x', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _posYMeta = const VerificationMeta('posY');
  @override
  late final GeneratedColumn<double> posY = GeneratedColumn<double>(
      'pos_y', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _rotationMeta =
      const VerificationMeta('rotation');
  @override
  late final GeneratedColumn<double> rotation = GeneratedColumn<double>(
      'rotation', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _widthFtMeta =
      const VerificationMeta('widthFt');
  @override
  late final GeneratedColumn<double> widthFt = GeneratedColumn<double>(
      'width_ft', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(4.0));
  static const VerificationMeta _depthFtMeta =
      const VerificationMeta('depthFt');
  @override
  late final GeneratedColumn<double> depthFt = GeneratedColumn<double>(
      'depth_ft', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(2.0));
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _storeIdMeta =
      const VerificationMeta('storeId');
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
      'store_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        zoneId,
        fixtureType,
        posX,
        posY,
        rotation,
        widthFt,
        depthFt,
        label,
        storeId,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fixtures_table';
  @override
  VerificationContext validateIntegrity(Insertable<FixturesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('zone_id')) {
      context.handle(_zoneIdMeta,
          zoneId.isAcceptableOrUnknown(data['zone_id']!, _zoneIdMeta));
    } else if (isInserting) {
      context.missing(_zoneIdMeta);
    }
    if (data.containsKey('fixture_type')) {
      context.handle(
          _fixtureTypeMeta,
          fixtureType.isAcceptableOrUnknown(
              data['fixture_type']!, _fixtureTypeMeta));
    } else if (isInserting) {
      context.missing(_fixtureTypeMeta);
    }
    if (data.containsKey('pos_x')) {
      context.handle(
          _posXMeta, posX.isAcceptableOrUnknown(data['pos_x']!, _posXMeta));
    }
    if (data.containsKey('pos_y')) {
      context.handle(
          _posYMeta, posY.isAcceptableOrUnknown(data['pos_y']!, _posYMeta));
    }
    if (data.containsKey('rotation')) {
      context.handle(_rotationMeta,
          rotation.isAcceptableOrUnknown(data['rotation']!, _rotationMeta));
    }
    if (data.containsKey('width_ft')) {
      context.handle(_widthFtMeta,
          widthFt.isAcceptableOrUnknown(data['width_ft']!, _widthFtMeta));
    }
    if (data.containsKey('depth_ft')) {
      context.handle(_depthFtMeta,
          depthFt.isAcceptableOrUnknown(data['depth_ft']!, _depthFtMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('store_id')) {
      context.handle(_storeIdMeta,
          storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FixturesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FixturesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      zoneId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}zone_id'])!,
      fixtureType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fixture_type'])!,
      posX: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pos_x'])!,
      posY: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pos_y'])!,
      rotation: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rotation'])!,
      widthFt: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}width_ft'])!,
      depthFt: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}depth_ft'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      storeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store_id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $FixturesTableTable createAlias(String alias) {
    return $FixturesTableTable(attachedDatabase, alias);
  }
}

class FixturesTableData extends DataClass
    implements Insertable<FixturesTableData> {
  final String id;
  final String zoneId;
  final String fixtureType;
  final double posX;
  final double posY;
  final double rotation;
  final double widthFt;
  final double depthFt;
  final String label;
  final String storeId;
  final DateTime updatedAt;
  const FixturesTableData(
      {required this.id,
      required this.zoneId,
      required this.fixtureType,
      required this.posX,
      required this.posY,
      required this.rotation,
      required this.widthFt,
      required this.depthFt,
      required this.label,
      required this.storeId,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['zone_id'] = Variable<String>(zoneId);
    map['fixture_type'] = Variable<String>(fixtureType);
    map['pos_x'] = Variable<double>(posX);
    map['pos_y'] = Variable<double>(posY);
    map['rotation'] = Variable<double>(rotation);
    map['width_ft'] = Variable<double>(widthFt);
    map['depth_ft'] = Variable<double>(depthFt);
    map['label'] = Variable<String>(label);
    map['store_id'] = Variable<String>(storeId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FixturesTableCompanion toCompanion(bool nullToAbsent) {
    return FixturesTableCompanion(
      id: Value(id),
      zoneId: Value(zoneId),
      fixtureType: Value(fixtureType),
      posX: Value(posX),
      posY: Value(posY),
      rotation: Value(rotation),
      widthFt: Value(widthFt),
      depthFt: Value(depthFt),
      label: Value(label),
      storeId: Value(storeId),
      updatedAt: Value(updatedAt),
    );
  }

  factory FixturesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FixturesTableData(
      id: serializer.fromJson<String>(json['id']),
      zoneId: serializer.fromJson<String>(json['zoneId']),
      fixtureType: serializer.fromJson<String>(json['fixtureType']),
      posX: serializer.fromJson<double>(json['posX']),
      posY: serializer.fromJson<double>(json['posY']),
      rotation: serializer.fromJson<double>(json['rotation']),
      widthFt: serializer.fromJson<double>(json['widthFt']),
      depthFt: serializer.fromJson<double>(json['depthFt']),
      label: serializer.fromJson<String>(json['label']),
      storeId: serializer.fromJson<String>(json['storeId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'zoneId': serializer.toJson<String>(zoneId),
      'fixtureType': serializer.toJson<String>(fixtureType),
      'posX': serializer.toJson<double>(posX),
      'posY': serializer.toJson<double>(posY),
      'rotation': serializer.toJson<double>(rotation),
      'widthFt': serializer.toJson<double>(widthFt),
      'depthFt': serializer.toJson<double>(depthFt),
      'label': serializer.toJson<String>(label),
      'storeId': serializer.toJson<String>(storeId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FixturesTableData copyWith(
          {String? id,
          String? zoneId,
          String? fixtureType,
          double? posX,
          double? posY,
          double? rotation,
          double? widthFt,
          double? depthFt,
          String? label,
          String? storeId,
          DateTime? updatedAt}) =>
      FixturesTableData(
        id: id ?? this.id,
        zoneId: zoneId ?? this.zoneId,
        fixtureType: fixtureType ?? this.fixtureType,
        posX: posX ?? this.posX,
        posY: posY ?? this.posY,
        rotation: rotation ?? this.rotation,
        widthFt: widthFt ?? this.widthFt,
        depthFt: depthFt ?? this.depthFt,
        label: label ?? this.label,
        storeId: storeId ?? this.storeId,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  FixturesTableData copyWithCompanion(FixturesTableCompanion data) {
    return FixturesTableData(
      id: data.id.present ? data.id.value : this.id,
      zoneId: data.zoneId.present ? data.zoneId.value : this.zoneId,
      fixtureType:
          data.fixtureType.present ? data.fixtureType.value : this.fixtureType,
      posX: data.posX.present ? data.posX.value : this.posX,
      posY: data.posY.present ? data.posY.value : this.posY,
      rotation: data.rotation.present ? data.rotation.value : this.rotation,
      widthFt: data.widthFt.present ? data.widthFt.value : this.widthFt,
      depthFt: data.depthFt.present ? data.depthFt.value : this.depthFt,
      label: data.label.present ? data.label.value : this.label,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FixturesTableData(')
          ..write('id: $id, ')
          ..write('zoneId: $zoneId, ')
          ..write('fixtureType: $fixtureType, ')
          ..write('posX: $posX, ')
          ..write('posY: $posY, ')
          ..write('rotation: $rotation, ')
          ..write('widthFt: $widthFt, ')
          ..write('depthFt: $depthFt, ')
          ..write('label: $label, ')
          ..write('storeId: $storeId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, zoneId, fixtureType, posX, posY, rotation,
      widthFt, depthFt, label, storeId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FixturesTableData &&
          other.id == this.id &&
          other.zoneId == this.zoneId &&
          other.fixtureType == this.fixtureType &&
          other.posX == this.posX &&
          other.posY == this.posY &&
          other.rotation == this.rotation &&
          other.widthFt == this.widthFt &&
          other.depthFt == this.depthFt &&
          other.label == this.label &&
          other.storeId == this.storeId &&
          other.updatedAt == this.updatedAt);
}

class FixturesTableCompanion extends UpdateCompanion<FixturesTableData> {
  final Value<String> id;
  final Value<String> zoneId;
  final Value<String> fixtureType;
  final Value<double> posX;
  final Value<double> posY;
  final Value<double> rotation;
  final Value<double> widthFt;
  final Value<double> depthFt;
  final Value<String> label;
  final Value<String> storeId;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FixturesTableCompanion({
    this.id = const Value.absent(),
    this.zoneId = const Value.absent(),
    this.fixtureType = const Value.absent(),
    this.posX = const Value.absent(),
    this.posY = const Value.absent(),
    this.rotation = const Value.absent(),
    this.widthFt = const Value.absent(),
    this.depthFt = const Value.absent(),
    this.label = const Value.absent(),
    this.storeId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FixturesTableCompanion.insert({
    required String id,
    required String zoneId,
    required String fixtureType,
    this.posX = const Value.absent(),
    this.posY = const Value.absent(),
    this.rotation = const Value.absent(),
    this.widthFt = const Value.absent(),
    this.depthFt = const Value.absent(),
    this.label = const Value.absent(),
    this.storeId = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        zoneId = Value(zoneId),
        fixtureType = Value(fixtureType),
        updatedAt = Value(updatedAt);
  static Insertable<FixturesTableData> custom({
    Expression<String>? id,
    Expression<String>? zoneId,
    Expression<String>? fixtureType,
    Expression<double>? posX,
    Expression<double>? posY,
    Expression<double>? rotation,
    Expression<double>? widthFt,
    Expression<double>? depthFt,
    Expression<String>? label,
    Expression<String>? storeId,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (zoneId != null) 'zone_id': zoneId,
      if (fixtureType != null) 'fixture_type': fixtureType,
      if (posX != null) 'pos_x': posX,
      if (posY != null) 'pos_y': posY,
      if (rotation != null) 'rotation': rotation,
      if (widthFt != null) 'width_ft': widthFt,
      if (depthFt != null) 'depth_ft': depthFt,
      if (label != null) 'label': label,
      if (storeId != null) 'store_id': storeId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FixturesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? zoneId,
      Value<String>? fixtureType,
      Value<double>? posX,
      Value<double>? posY,
      Value<double>? rotation,
      Value<double>? widthFt,
      Value<double>? depthFt,
      Value<String>? label,
      Value<String>? storeId,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return FixturesTableCompanion(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      fixtureType: fixtureType ?? this.fixtureType,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      rotation: rotation ?? this.rotation,
      widthFt: widthFt ?? this.widthFt,
      depthFt: depthFt ?? this.depthFt,
      label: label ?? this.label,
      storeId: storeId ?? this.storeId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (zoneId.present) {
      map['zone_id'] = Variable<String>(zoneId.value);
    }
    if (fixtureType.present) {
      map['fixture_type'] = Variable<String>(fixtureType.value);
    }
    if (posX.present) {
      map['pos_x'] = Variable<double>(posX.value);
    }
    if (posY.present) {
      map['pos_y'] = Variable<double>(posY.value);
    }
    if (rotation.present) {
      map['rotation'] = Variable<double>(rotation.value);
    }
    if (widthFt.present) {
      map['width_ft'] = Variable<double>(widthFt.value);
    }
    if (depthFt.present) {
      map['depth_ft'] = Variable<double>(depthFt.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FixturesTableCompanion(')
          ..write('id: $id, ')
          ..write('zoneId: $zoneId, ')
          ..write('fixtureType: $fixtureType, ')
          ..write('posX: $posX, ')
          ..write('posY: $posY, ')
          ..write('rotation: $rotation, ')
          ..write('widthFt: $widthFt, ')
          ..write('depthFt: $depthFt, ')
          ..write('label: $label, ')
          ..write('storeId: $storeId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTableTable extends ProductsTable
    with TableInfo<$ProductsTableTable, ProductsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _sizesJsonMeta =
      const VerificationMeta('sizesJson');
  @override
  late final GeneratedColumn<String> sizesJson = GeneratedColumn<String>(
      'sizes_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _stockQtyMeta =
      const VerificationMeta('stockQty');
  @override
  late final GeneratedColumn<int> stockQty = GeneratedColumn<int>(
      'stock_qty', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _storeIdMeta =
      const VerificationMeta('storeId');
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
      'store_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sku,
        name,
        category,
        imageUrl,
        sizesJson,
        stockQty,
        storeId,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products_table';
  @override
  VerificationContext validateIntegrity(Insertable<ProductsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('sizes_json')) {
      context.handle(_sizesJsonMeta,
          sizesJson.isAcceptableOrUnknown(data['sizes_json']!, _sizesJsonMeta));
    }
    if (data.containsKey('stock_qty')) {
      context.handle(_stockQtyMeta,
          stockQty.isAcceptableOrUnknown(data['stock_qty']!, _stockQtyMeta));
    }
    if (data.containsKey('store_id')) {
      context.handle(_storeIdMeta,
          storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url'])!,
      sizesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sizes_json'])!,
      stockQty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock_qty'])!,
      storeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store_id'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ProductsTableTable createAlias(String alias) {
    return $ProductsTableTable(attachedDatabase, alias);
  }
}

class ProductsTableData extends DataClass
    implements Insertable<ProductsTableData> {
  final String id;
  final String sku;
  final String name;
  final String category;
  final String imageUrl;
  final String sizesJson;
  final int stockQty;
  final String storeId;
  final DateTime updatedAt;
  const ProductsTableData(
      {required this.id,
      required this.sku,
      required this.name,
      required this.category,
      required this.imageUrl,
      required this.sizesJson,
      required this.stockQty,
      required this.storeId,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sku'] = Variable<String>(sku);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['image_url'] = Variable<String>(imageUrl);
    map['sizes_json'] = Variable<String>(sizesJson);
    map['stock_qty'] = Variable<int>(stockQty);
    map['store_id'] = Variable<String>(storeId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProductsTableCompanion toCompanion(bool nullToAbsent) {
    return ProductsTableCompanion(
      id: Value(id),
      sku: Value(sku),
      name: Value(name),
      category: Value(category),
      imageUrl: Value(imageUrl),
      sizesJson: Value(sizesJson),
      stockQty: Value(stockQty),
      storeId: Value(storeId),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProductsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductsTableData(
      id: serializer.fromJson<String>(json['id']),
      sku: serializer.fromJson<String>(json['sku']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      sizesJson: serializer.fromJson<String>(json['sizesJson']),
      stockQty: serializer.fromJson<int>(json['stockQty']),
      storeId: serializer.fromJson<String>(json['storeId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sku': serializer.toJson<String>(sku),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'sizesJson': serializer.toJson<String>(sizesJson),
      'stockQty': serializer.toJson<int>(stockQty),
      'storeId': serializer.toJson<String>(storeId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProductsTableData copyWith(
          {String? id,
          String? sku,
          String? name,
          String? category,
          String? imageUrl,
          String? sizesJson,
          int? stockQty,
          String? storeId,
          DateTime? updatedAt}) =>
      ProductsTableData(
        id: id ?? this.id,
        sku: sku ?? this.sku,
        name: name ?? this.name,
        category: category ?? this.category,
        imageUrl: imageUrl ?? this.imageUrl,
        sizesJson: sizesJson ?? this.sizesJson,
        stockQty: stockQty ?? this.stockQty,
        storeId: storeId ?? this.storeId,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ProductsTableData copyWithCompanion(ProductsTableCompanion data) {
    return ProductsTableData(
      id: data.id.present ? data.id.value : this.id,
      sku: data.sku.present ? data.sku.value : this.sku,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      sizesJson: data.sizesJson.present ? data.sizesJson.value : this.sizesJson,
      stockQty: data.stockQty.present ? data.stockQty.value : this.stockQty,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductsTableData(')
          ..write('id: $id, ')
          ..write('sku: $sku, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('sizesJson: $sizesJson, ')
          ..write('stockQty: $stockQty, ')
          ..write('storeId: $storeId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sku, name, category, imageUrl, sizesJson,
      stockQty, storeId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductsTableData &&
          other.id == this.id &&
          other.sku == this.sku &&
          other.name == this.name &&
          other.category == this.category &&
          other.imageUrl == this.imageUrl &&
          other.sizesJson == this.sizesJson &&
          other.stockQty == this.stockQty &&
          other.storeId == this.storeId &&
          other.updatedAt == this.updatedAt);
}

class ProductsTableCompanion extends UpdateCompanion<ProductsTableData> {
  final Value<String> id;
  final Value<String> sku;
  final Value<String> name;
  final Value<String> category;
  final Value<String> imageUrl;
  final Value<String> sizesJson;
  final Value<int> stockQty;
  final Value<String> storeId;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProductsTableCompanion({
    this.id = const Value.absent(),
    this.sku = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.sizesJson = const Value.absent(),
    this.stockQty = const Value.absent(),
    this.storeId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsTableCompanion.insert({
    required String id,
    required String sku,
    required String name,
    required String category,
    this.imageUrl = const Value.absent(),
    this.sizesJson = const Value.absent(),
    this.stockQty = const Value.absent(),
    this.storeId = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sku = Value(sku),
        name = Value(name),
        category = Value(category),
        updatedAt = Value(updatedAt);
  static Insertable<ProductsTableData> custom({
    Expression<String>? id,
    Expression<String>? sku,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? imageUrl,
    Expression<String>? sizesJson,
    Expression<int>? stockQty,
    Expression<String>? storeId,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sku != null) 'sku': sku,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (imageUrl != null) 'image_url': imageUrl,
      if (sizesJson != null) 'sizes_json': sizesJson,
      if (stockQty != null) 'stock_qty': stockQty,
      if (storeId != null) 'store_id': storeId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? sku,
      Value<String>? name,
      Value<String>? category,
      Value<String>? imageUrl,
      Value<String>? sizesJson,
      Value<int>? stockQty,
      Value<String>? storeId,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ProductsTableCompanion(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      sizesJson: sizesJson ?? this.sizesJson,
      stockQty: stockQty ?? this.stockQty,
      storeId: storeId ?? this.storeId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (sizesJson.present) {
      map['sizes_json'] = Variable<String>(sizesJson.value);
    }
    if (stockQty.present) {
      map['stock_qty'] = Variable<int>(stockQty.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsTableCompanion(')
          ..write('id: $id, ')
          ..write('sku: $sku, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('sizesJson: $sizesJson, ')
          ..write('stockQty: $stockQty, ')
          ..write('storeId: $storeId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanogramsTableTable extends PlanogramsTable
    with TableInfo<$PlanogramsTableTable, PlanogramsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanogramsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fixtureIdMeta =
      const VerificationMeta('fixtureId');
  @override
  late final GeneratedColumn<String> fixtureId = GeneratedColumn<String>(
      'fixture_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<String> season = GeneratedColumn<String>(
      'season', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('draft'));
  static const VerificationMeta _slotsJsonMeta =
      const VerificationMeta('slotsJson');
  @override
  late final GeneratedColumn<String> slotsJson = GeneratedColumn<String>(
      'slots_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _publishedAtMeta =
      const VerificationMeta('publishedAt');
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
      'published_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _storeIdMeta =
      const VerificationMeta('storeId');
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
      'store_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        fixtureId,
        title,
        season,
        status,
        slotsJson,
        publishedAt,
        updatedAt,
        storeId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'planograms_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<PlanogramsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('fixture_id')) {
      context.handle(_fixtureIdMeta,
          fixtureId.isAcceptableOrUnknown(data['fixture_id']!, _fixtureIdMeta));
    } else if (isInserting) {
      context.missing(_fixtureIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('season')) {
      context.handle(_seasonMeta,
          season.isAcceptableOrUnknown(data['season']!, _seasonMeta));
    } else if (isInserting) {
      context.missing(_seasonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('slots_json')) {
      context.handle(_slotsJsonMeta,
          slotsJson.isAcceptableOrUnknown(data['slots_json']!, _slotsJsonMeta));
    }
    if (data.containsKey('published_at')) {
      context.handle(
          _publishedAtMeta,
          publishedAt.isAcceptableOrUnknown(
              data['published_at']!, _publishedAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(_storeIdMeta,
          storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanogramsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanogramsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fixtureId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fixture_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      season: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}season'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      slotsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}slots_json'])!,
      publishedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}published_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      storeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store_id'])!,
    );
  }

  @override
  $PlanogramsTableTable createAlias(String alias) {
    return $PlanogramsTableTable(attachedDatabase, alias);
  }
}

class PlanogramsTableData extends DataClass
    implements Insertable<PlanogramsTableData> {
  final String id;
  final String fixtureId;
  final String title;
  final String season;
  final String status;
  final String slotsJson;
  final DateTime? publishedAt;
  final DateTime updatedAt;
  final String storeId;
  const PlanogramsTableData(
      {required this.id,
      required this.fixtureId,
      required this.title,
      required this.season,
      required this.status,
      required this.slotsJson,
      this.publishedAt,
      required this.updatedAt,
      required this.storeId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['fixture_id'] = Variable<String>(fixtureId);
    map['title'] = Variable<String>(title);
    map['season'] = Variable<String>(season);
    map['status'] = Variable<String>(status);
    map['slots_json'] = Variable<String>(slotsJson);
    if (!nullToAbsent || publishedAt != null) {
      map['published_at'] = Variable<DateTime>(publishedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['store_id'] = Variable<String>(storeId);
    return map;
  }

  PlanogramsTableCompanion toCompanion(bool nullToAbsent) {
    return PlanogramsTableCompanion(
      id: Value(id),
      fixtureId: Value(fixtureId),
      title: Value(title),
      season: Value(season),
      status: Value(status),
      slotsJson: Value(slotsJson),
      publishedAt: publishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedAt),
      updatedAt: Value(updatedAt),
      storeId: Value(storeId),
    );
  }

  factory PlanogramsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanogramsTableData(
      id: serializer.fromJson<String>(json['id']),
      fixtureId: serializer.fromJson<String>(json['fixtureId']),
      title: serializer.fromJson<String>(json['title']),
      season: serializer.fromJson<String>(json['season']),
      status: serializer.fromJson<String>(json['status']),
      slotsJson: serializer.fromJson<String>(json['slotsJson']),
      publishedAt: serializer.fromJson<DateTime?>(json['publishedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      storeId: serializer.fromJson<String>(json['storeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fixtureId': serializer.toJson<String>(fixtureId),
      'title': serializer.toJson<String>(title),
      'season': serializer.toJson<String>(season),
      'status': serializer.toJson<String>(status),
      'slotsJson': serializer.toJson<String>(slotsJson),
      'publishedAt': serializer.toJson<DateTime?>(publishedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'storeId': serializer.toJson<String>(storeId),
    };
  }

  PlanogramsTableData copyWith(
          {String? id,
          String? fixtureId,
          String? title,
          String? season,
          String? status,
          String? slotsJson,
          Value<DateTime?> publishedAt = const Value.absent(),
          DateTime? updatedAt,
          String? storeId}) =>
      PlanogramsTableData(
        id: id ?? this.id,
        fixtureId: fixtureId ?? this.fixtureId,
        title: title ?? this.title,
        season: season ?? this.season,
        status: status ?? this.status,
        slotsJson: slotsJson ?? this.slotsJson,
        publishedAt: publishedAt.present ? publishedAt.value : this.publishedAt,
        updatedAt: updatedAt ?? this.updatedAt,
        storeId: storeId ?? this.storeId,
      );
  PlanogramsTableData copyWithCompanion(PlanogramsTableCompanion data) {
    return PlanogramsTableData(
      id: data.id.present ? data.id.value : this.id,
      fixtureId: data.fixtureId.present ? data.fixtureId.value : this.fixtureId,
      title: data.title.present ? data.title.value : this.title,
      season: data.season.present ? data.season.value : this.season,
      status: data.status.present ? data.status.value : this.status,
      slotsJson: data.slotsJson.present ? data.slotsJson.value : this.slotsJson,
      publishedAt:
          data.publishedAt.present ? data.publishedAt.value : this.publishedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanogramsTableData(')
          ..write('id: $id, ')
          ..write('fixtureId: $fixtureId, ')
          ..write('title: $title, ')
          ..write('season: $season, ')
          ..write('status: $status, ')
          ..write('slotsJson: $slotsJson, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('storeId: $storeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fixtureId, title, season, status,
      slotsJson, publishedAt, updatedAt, storeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanogramsTableData &&
          other.id == this.id &&
          other.fixtureId == this.fixtureId &&
          other.title == this.title &&
          other.season == this.season &&
          other.status == this.status &&
          other.slotsJson == this.slotsJson &&
          other.publishedAt == this.publishedAt &&
          other.updatedAt == this.updatedAt &&
          other.storeId == this.storeId);
}

class PlanogramsTableCompanion extends UpdateCompanion<PlanogramsTableData> {
  final Value<String> id;
  final Value<String> fixtureId;
  final Value<String> title;
  final Value<String> season;
  final Value<String> status;
  final Value<String> slotsJson;
  final Value<DateTime?> publishedAt;
  final Value<DateTime> updatedAt;
  final Value<String> storeId;
  final Value<int> rowid;
  const PlanogramsTableCompanion({
    this.id = const Value.absent(),
    this.fixtureId = const Value.absent(),
    this.title = const Value.absent(),
    this.season = const Value.absent(),
    this.status = const Value.absent(),
    this.slotsJson = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.storeId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanogramsTableCompanion.insert({
    required String id,
    required String fixtureId,
    required String title,
    required String season,
    this.status = const Value.absent(),
    this.slotsJson = const Value.absent(),
    this.publishedAt = const Value.absent(),
    required DateTime updatedAt,
    this.storeId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fixtureId = Value(fixtureId),
        title = Value(title),
        season = Value(season),
        updatedAt = Value(updatedAt);
  static Insertable<PlanogramsTableData> custom({
    Expression<String>? id,
    Expression<String>? fixtureId,
    Expression<String>? title,
    Expression<String>? season,
    Expression<String>? status,
    Expression<String>? slotsJson,
    Expression<DateTime>? publishedAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? storeId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fixtureId != null) 'fixture_id': fixtureId,
      if (title != null) 'title': title,
      if (season != null) 'season': season,
      if (status != null) 'status': status,
      if (slotsJson != null) 'slots_json': slotsJson,
      if (publishedAt != null) 'published_at': publishedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (storeId != null) 'store_id': storeId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanogramsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? fixtureId,
      Value<String>? title,
      Value<String>? season,
      Value<String>? status,
      Value<String>? slotsJson,
      Value<DateTime?>? publishedAt,
      Value<DateTime>? updatedAt,
      Value<String>? storeId,
      Value<int>? rowid}) {
    return PlanogramsTableCompanion(
      id: id ?? this.id,
      fixtureId: fixtureId ?? this.fixtureId,
      title: title ?? this.title,
      season: season ?? this.season,
      status: status ?? this.status,
      slotsJson: slotsJson ?? this.slotsJson,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      storeId: storeId ?? this.storeId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fixtureId.present) {
      map['fixture_id'] = Variable<String>(fixtureId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (season.present) {
      map['season'] = Variable<String>(season.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (slotsJson.present) {
      map['slots_json'] = Variable<String>(slotsJson.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanogramsTableCompanion(')
          ..write('id: $id, ')
          ..write('fixtureId: $fixtureId, ')
          ..write('title: $title, ')
          ..write('season: $season, ')
          ..write('status: $status, ')
          ..write('slotsJson: $slotsJson, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('storeId: $storeId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotoDocsTableTable extends PhotoDocsTable
    with TableInfo<$PhotoDocsTableTable, PhotoDocsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotoDocsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fixtureIdMeta =
      const VerificationMeta('fixtureId');
  @override
  late final GeneratedColumn<String> fixtureId = GeneratedColumn<String>(
      'fixture_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<String> phase = GeneratedColumn<String>(
      'phase', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteUrlMeta =
      const VerificationMeta('remoteUrl');
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
      'remote_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _uploadStatusMeta =
      const VerificationMeta('uploadStatus');
  @override
  late final GeneratedColumn<String> uploadStatus = GeneratedColumn<String>(
      'upload_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _approvalStatusMeta =
      const VerificationMeta('approvalStatus');
  @override
  late final GeneratedColumn<String> approvalStatus = GeneratedColumn<String>(
      'approval_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _planogramIdMeta =
      const VerificationMeta('planogramId');
  @override
  late final GeneratedColumn<String> planogramId = GeneratedColumn<String>(
      'planogram_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _capturedAtMeta =
      const VerificationMeta('capturedAt');
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
      'captured_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _storeIdMeta =
      const VerificationMeta('storeId');
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
      'store_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        fixtureId,
        phase,
        localPath,
        remoteUrl,
        uploadStatus,
        approvalStatus,
        planogramId,
        capturedAt,
        updatedAt,
        storeId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photo_docs_table';
  @override
  VerificationContext validateIntegrity(Insertable<PhotoDocsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('fixture_id')) {
      context.handle(_fixtureIdMeta,
          fixtureId.isAcceptableOrUnknown(data['fixture_id']!, _fixtureIdMeta));
    } else if (isInserting) {
      context.missing(_fixtureIdMeta);
    }
    if (data.containsKey('phase')) {
      context.handle(
          _phaseMeta, phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta));
    } else if (isInserting) {
      context.missing(_phaseMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('remote_url')) {
      context.handle(_remoteUrlMeta,
          remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta));
    }
    if (data.containsKey('upload_status')) {
      context.handle(
          _uploadStatusMeta,
          uploadStatus.isAcceptableOrUnknown(
              data['upload_status']!, _uploadStatusMeta));
    }
    if (data.containsKey('approval_status')) {
      context.handle(
          _approvalStatusMeta,
          approvalStatus.isAcceptableOrUnknown(
              data['approval_status']!, _approvalStatusMeta));
    }
    if (data.containsKey('planogram_id')) {
      context.handle(
          _planogramIdMeta,
          planogramId.isAcceptableOrUnknown(
              data['planogram_id']!, _planogramIdMeta));
    }
    if (data.containsKey('captured_at')) {
      context.handle(
          _capturedAtMeta,
          capturedAt.isAcceptableOrUnknown(
              data['captured_at']!, _capturedAtMeta));
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(_storeIdMeta,
          storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhotoDocsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhotoDocsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fixtureId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fixture_id'])!,
      phase: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phase'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path'])!,
      remoteUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_url'])!,
      uploadStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}upload_status'])!,
      approvalStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}approval_status'])!,
      planogramId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}planogram_id']),
      capturedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}captured_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      storeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store_id'])!,
    );
  }

  @override
  $PhotoDocsTableTable createAlias(String alias) {
    return $PhotoDocsTableTable(attachedDatabase, alias);
  }
}

class PhotoDocsTableData extends DataClass
    implements Insertable<PhotoDocsTableData> {
  final String id;
  final String fixtureId;
  final String phase;
  final String localPath;
  final String remoteUrl;
  final String uploadStatus;
  final String approvalStatus;
  final String? planogramId;
  final DateTime capturedAt;
  final DateTime updatedAt;
  final String storeId;
  const PhotoDocsTableData(
      {required this.id,
      required this.fixtureId,
      required this.phase,
      required this.localPath,
      required this.remoteUrl,
      required this.uploadStatus,
      required this.approvalStatus,
      this.planogramId,
      required this.capturedAt,
      required this.updatedAt,
      required this.storeId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['fixture_id'] = Variable<String>(fixtureId);
    map['phase'] = Variable<String>(phase);
    map['local_path'] = Variable<String>(localPath);
    map['remote_url'] = Variable<String>(remoteUrl);
    map['upload_status'] = Variable<String>(uploadStatus);
    map['approval_status'] = Variable<String>(approvalStatus);
    if (!nullToAbsent || planogramId != null) {
      map['planogram_id'] = Variable<String>(planogramId);
    }
    map['captured_at'] = Variable<DateTime>(capturedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['store_id'] = Variable<String>(storeId);
    return map;
  }

  PhotoDocsTableCompanion toCompanion(bool nullToAbsent) {
    return PhotoDocsTableCompanion(
      id: Value(id),
      fixtureId: Value(fixtureId),
      phase: Value(phase),
      localPath: Value(localPath),
      remoteUrl: Value(remoteUrl),
      uploadStatus: Value(uploadStatus),
      approvalStatus: Value(approvalStatus),
      planogramId: planogramId == null && nullToAbsent
          ? const Value.absent()
          : Value(planogramId),
      capturedAt: Value(capturedAt),
      updatedAt: Value(updatedAt),
      storeId: Value(storeId),
    );
  }

  factory PhotoDocsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhotoDocsTableData(
      id: serializer.fromJson<String>(json['id']),
      fixtureId: serializer.fromJson<String>(json['fixtureId']),
      phase: serializer.fromJson<String>(json['phase']),
      localPath: serializer.fromJson<String>(json['localPath']),
      remoteUrl: serializer.fromJson<String>(json['remoteUrl']),
      uploadStatus: serializer.fromJson<String>(json['uploadStatus']),
      approvalStatus: serializer.fromJson<String>(json['approvalStatus']),
      planogramId: serializer.fromJson<String?>(json['planogramId']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      storeId: serializer.fromJson<String>(json['storeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fixtureId': serializer.toJson<String>(fixtureId),
      'phase': serializer.toJson<String>(phase),
      'localPath': serializer.toJson<String>(localPath),
      'remoteUrl': serializer.toJson<String>(remoteUrl),
      'uploadStatus': serializer.toJson<String>(uploadStatus),
      'approvalStatus': serializer.toJson<String>(approvalStatus),
      'planogramId': serializer.toJson<String?>(planogramId),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'storeId': serializer.toJson<String>(storeId),
    };
  }

  PhotoDocsTableData copyWith(
          {String? id,
          String? fixtureId,
          String? phase,
          String? localPath,
          String? remoteUrl,
          String? uploadStatus,
          String? approvalStatus,
          Value<String?> planogramId = const Value.absent(),
          DateTime? capturedAt,
          DateTime? updatedAt,
          String? storeId}) =>
      PhotoDocsTableData(
        id: id ?? this.id,
        fixtureId: fixtureId ?? this.fixtureId,
        phase: phase ?? this.phase,
        localPath: localPath ?? this.localPath,
        remoteUrl: remoteUrl ?? this.remoteUrl,
        uploadStatus: uploadStatus ?? this.uploadStatus,
        approvalStatus: approvalStatus ?? this.approvalStatus,
        planogramId: planogramId.present ? planogramId.value : this.planogramId,
        capturedAt: capturedAt ?? this.capturedAt,
        updatedAt: updatedAt ?? this.updatedAt,
        storeId: storeId ?? this.storeId,
      );
  PhotoDocsTableData copyWithCompanion(PhotoDocsTableCompanion data) {
    return PhotoDocsTableData(
      id: data.id.present ? data.id.value : this.id,
      fixtureId: data.fixtureId.present ? data.fixtureId.value : this.fixtureId,
      phase: data.phase.present ? data.phase.value : this.phase,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      remoteUrl: data.remoteUrl.present ? data.remoteUrl.value : this.remoteUrl,
      uploadStatus: data.uploadStatus.present
          ? data.uploadStatus.value
          : this.uploadStatus,
      approvalStatus: data.approvalStatus.present
          ? data.approvalStatus.value
          : this.approvalStatus,
      planogramId:
          data.planogramId.present ? data.planogramId.value : this.planogramId,
      capturedAt:
          data.capturedAt.present ? data.capturedAt.value : this.capturedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhotoDocsTableData(')
          ..write('id: $id, ')
          ..write('fixtureId: $fixtureId, ')
          ..write('phase: $phase, ')
          ..write('localPath: $localPath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('uploadStatus: $uploadStatus, ')
          ..write('approvalStatus: $approvalStatus, ')
          ..write('planogramId: $planogramId, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('storeId: $storeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      fixtureId,
      phase,
      localPath,
      remoteUrl,
      uploadStatus,
      approvalStatus,
      planogramId,
      capturedAt,
      updatedAt,
      storeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhotoDocsTableData &&
          other.id == this.id &&
          other.fixtureId == this.fixtureId &&
          other.phase == this.phase &&
          other.localPath == this.localPath &&
          other.remoteUrl == this.remoteUrl &&
          other.uploadStatus == this.uploadStatus &&
          other.approvalStatus == this.approvalStatus &&
          other.planogramId == this.planogramId &&
          other.capturedAt == this.capturedAt &&
          other.updatedAt == this.updatedAt &&
          other.storeId == this.storeId);
}

class PhotoDocsTableCompanion extends UpdateCompanion<PhotoDocsTableData> {
  final Value<String> id;
  final Value<String> fixtureId;
  final Value<String> phase;
  final Value<String> localPath;
  final Value<String> remoteUrl;
  final Value<String> uploadStatus;
  final Value<String> approvalStatus;
  final Value<String?> planogramId;
  final Value<DateTime> capturedAt;
  final Value<DateTime> updatedAt;
  final Value<String> storeId;
  final Value<int> rowid;
  const PhotoDocsTableCompanion({
    this.id = const Value.absent(),
    this.fixtureId = const Value.absent(),
    this.phase = const Value.absent(),
    this.localPath = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.uploadStatus = const Value.absent(),
    this.approvalStatus = const Value.absent(),
    this.planogramId = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.storeId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotoDocsTableCompanion.insert({
    required String id,
    required String fixtureId,
    required String phase,
    required String localPath,
    this.remoteUrl = const Value.absent(),
    this.uploadStatus = const Value.absent(),
    this.approvalStatus = const Value.absent(),
    this.planogramId = const Value.absent(),
    required DateTime capturedAt,
    required DateTime updatedAt,
    this.storeId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fixtureId = Value(fixtureId),
        phase = Value(phase),
        localPath = Value(localPath),
        capturedAt = Value(capturedAt),
        updatedAt = Value(updatedAt);
  static Insertable<PhotoDocsTableData> custom({
    Expression<String>? id,
    Expression<String>? fixtureId,
    Expression<String>? phase,
    Expression<String>? localPath,
    Expression<String>? remoteUrl,
    Expression<String>? uploadStatus,
    Expression<String>? approvalStatus,
    Expression<String>? planogramId,
    Expression<DateTime>? capturedAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? storeId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fixtureId != null) 'fixture_id': fixtureId,
      if (phase != null) 'phase': phase,
      if (localPath != null) 'local_path': localPath,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (uploadStatus != null) 'upload_status': uploadStatus,
      if (approvalStatus != null) 'approval_status': approvalStatus,
      if (planogramId != null) 'planogram_id': planogramId,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (storeId != null) 'store_id': storeId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotoDocsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? fixtureId,
      Value<String>? phase,
      Value<String>? localPath,
      Value<String>? remoteUrl,
      Value<String>? uploadStatus,
      Value<String>? approvalStatus,
      Value<String?>? planogramId,
      Value<DateTime>? capturedAt,
      Value<DateTime>? updatedAt,
      Value<String>? storeId,
      Value<int>? rowid}) {
    return PhotoDocsTableCompanion(
      id: id ?? this.id,
      fixtureId: fixtureId ?? this.fixtureId,
      phase: phase ?? this.phase,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      planogramId: planogramId ?? this.planogramId,
      capturedAt: capturedAt ?? this.capturedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      storeId: storeId ?? this.storeId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fixtureId.present) {
      map['fixture_id'] = Variable<String>(fixtureId.value);
    }
    if (phase.present) {
      map['phase'] = Variable<String>(phase.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (uploadStatus.present) {
      map['upload_status'] = Variable<String>(uploadStatus.value);
    }
    if (approvalStatus.present) {
      map['approval_status'] = Variable<String>(approvalStatus.value);
    }
    if (planogramId.present) {
      map['planogram_id'] = Variable<String>(planogramId.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotoDocsTableCompanion(')
          ..write('id: $id, ')
          ..write('fixtureId: $fixtureId, ')
          ..write('phase: $phase, ')
          ..write('localPath: $localPath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('uploadStatus: $uploadStatus, ')
          ..write('approvalStatus: $approvalStatus, ')
          ..write('planogramId: $planogramId, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('storeId: $storeId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoresTableTable extends StoresTable
    with TableInfo<$StoresTableTable, StoresTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoresTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _inviteCodeMeta =
      const VerificationMeta('inviteCode');
  @override
  late final GeneratedColumn<String> inviteCode = GeneratedColumn<String>(
      'invite_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ownerUidMeta =
      const VerificationMeta('ownerUid');
  @override
  late final GeneratedColumn<String> ownerUid = GeneratedColumn<String>(
      'owner_uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, inviteCode, createdAt, ownerUid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stores';
  @override
  VerificationContext validateIntegrity(Insertable<StoresTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('invite_code')) {
      context.handle(
          _inviteCodeMeta,
          inviteCode.isAcceptableOrUnknown(
              data['invite_code']!, _inviteCodeMeta));
    } else if (isInserting) {
      context.missing(_inviteCodeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('owner_uid')) {
      context.handle(_ownerUidMeta,
          ownerUid.isAcceptableOrUnknown(data['owner_uid']!, _ownerUidMeta));
    } else if (isInserting) {
      context.missing(_ownerUidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoresTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoresTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      inviteCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invite_code'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      ownerUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_uid'])!,
    );
  }

  @override
  $StoresTableTable createAlias(String alias) {
    return $StoresTableTable(attachedDatabase, alias);
  }
}

class StoresTableData extends DataClass implements Insertable<StoresTableData> {
  final String id;
  final String name;
  final String inviteCode;
  final int createdAt;
  final String ownerUid;
  const StoresTableData(
      {required this.id,
      required this.name,
      required this.inviteCode,
      required this.createdAt,
      required this.ownerUid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['invite_code'] = Variable<String>(inviteCode);
    map['created_at'] = Variable<int>(createdAt);
    map['owner_uid'] = Variable<String>(ownerUid);
    return map;
  }

  StoresTableCompanion toCompanion(bool nullToAbsent) {
    return StoresTableCompanion(
      id: Value(id),
      name: Value(name),
      inviteCode: Value(inviteCode),
      createdAt: Value(createdAt),
      ownerUid: Value(ownerUid),
    );
  }

  factory StoresTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoresTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      inviteCode: serializer.fromJson<String>(json['inviteCode']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      ownerUid: serializer.fromJson<String>(json['ownerUid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'inviteCode': serializer.toJson<String>(inviteCode),
      'createdAt': serializer.toJson<int>(createdAt),
      'ownerUid': serializer.toJson<String>(ownerUid),
    };
  }

  StoresTableData copyWith(
          {String? id,
          String? name,
          String? inviteCode,
          int? createdAt,
          String? ownerUid}) =>
      StoresTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        inviteCode: inviteCode ?? this.inviteCode,
        createdAt: createdAt ?? this.createdAt,
        ownerUid: ownerUid ?? this.ownerUid,
      );
  StoresTableData copyWithCompanion(StoresTableCompanion data) {
    return StoresTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      inviteCode:
          data.inviteCode.present ? data.inviteCode.value : this.inviteCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      ownerUid: data.ownerUid.present ? data.ownerUid.value : this.ownerUid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoresTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('inviteCode: $inviteCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('ownerUid: $ownerUid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, inviteCode, createdAt, ownerUid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoresTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.inviteCode == this.inviteCode &&
          other.createdAt == this.createdAt &&
          other.ownerUid == this.ownerUid);
}

class StoresTableCompanion extends UpdateCompanion<StoresTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> inviteCode;
  final Value<int> createdAt;
  final Value<String> ownerUid;
  final Value<int> rowid;
  const StoresTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.inviteCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.ownerUid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoresTableCompanion.insert({
    required String id,
    required String name,
    required String inviteCode,
    required int createdAt,
    required String ownerUid,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        inviteCode = Value(inviteCode),
        createdAt = Value(createdAt),
        ownerUid = Value(ownerUid);
  static Insertable<StoresTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? inviteCode,
    Expression<int>? createdAt,
    Expression<String>? ownerUid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (inviteCode != null) 'invite_code': inviteCode,
      if (createdAt != null) 'created_at': createdAt,
      if (ownerUid != null) 'owner_uid': ownerUid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoresTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? inviteCode,
      Value<int>? createdAt,
      Value<String>? ownerUid,
      Value<int>? rowid}) {
    return StoresTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
      ownerUid: ownerUid ?? this.ownerUid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (inviteCode.present) {
      map['invite_code'] = Variable<String>(inviteCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (ownerUid.present) {
      map['owner_uid'] = Variable<String>(ownerUid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoresTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('inviteCode: $inviteCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoreMembershipsTableTable extends StoreMembershipsTable
    with TableInfo<$StoreMembershipsTableTable, StoreMembershipsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoreMembershipsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _storeIdMeta =
      const VerificationMeta('storeId');
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
      'store_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userUidMeta =
      const VerificationMeta('userUid');
  @override
  late final GeneratedColumn<String> userUid = GeneratedColumn<String>(
      'user_uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _joinedAtMeta =
      const VerificationMeta('joinedAt');
  @override
  late final GeneratedColumn<int> joinedAt = GeneratedColumn<int>(
      'joined_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, storeId, userUid, role, displayName, status, joinedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'store_memberships';
  @override
  VerificationContext validateIntegrity(
      Insertable<StoreMembershipsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(_storeIdMeta,
          storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta));
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('user_uid')) {
      context.handle(_userUidMeta,
          userUid.isAcceptableOrUnknown(data['user_uid']!, _userUidMeta));
    } else if (isInserting) {
      context.missing(_userUidMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('joined_at')) {
      context.handle(_joinedAtMeta,
          joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta));
    } else if (isInserting) {
      context.missing(_joinedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoreMembershipsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoreMembershipsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      storeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store_id'])!,
      userUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_uid'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      joinedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}joined_at'])!,
    );
  }

  @override
  $StoreMembershipsTableTable createAlias(String alias) {
    return $StoreMembershipsTableTable(attachedDatabase, alias);
  }
}

class StoreMembershipsTableData extends DataClass
    implements Insertable<StoreMembershipsTableData> {
  final String id;
  final String storeId;
  final String userUid;
  final String role;
  final String displayName;
  final String status;
  final int joinedAt;
  const StoreMembershipsTableData(
      {required this.id,
      required this.storeId,
      required this.userUid,
      required this.role,
      required this.displayName,
      required this.status,
      required this.joinedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['store_id'] = Variable<String>(storeId);
    map['user_uid'] = Variable<String>(userUid);
    map['role'] = Variable<String>(role);
    map['display_name'] = Variable<String>(displayName);
    map['status'] = Variable<String>(status);
    map['joined_at'] = Variable<int>(joinedAt);
    return map;
  }

  StoreMembershipsTableCompanion toCompanion(bool nullToAbsent) {
    return StoreMembershipsTableCompanion(
      id: Value(id),
      storeId: Value(storeId),
      userUid: Value(userUid),
      role: Value(role),
      displayName: Value(displayName),
      status: Value(status),
      joinedAt: Value(joinedAt),
    );
  }

  factory StoreMembershipsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoreMembershipsTableData(
      id: serializer.fromJson<String>(json['id']),
      storeId: serializer.fromJson<String>(json['storeId']),
      userUid: serializer.fromJson<String>(json['userUid']),
      role: serializer.fromJson<String>(json['role']),
      displayName: serializer.fromJson<String>(json['displayName']),
      status: serializer.fromJson<String>(json['status']),
      joinedAt: serializer.fromJson<int>(json['joinedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'storeId': serializer.toJson<String>(storeId),
      'userUid': serializer.toJson<String>(userUid),
      'role': serializer.toJson<String>(role),
      'displayName': serializer.toJson<String>(displayName),
      'status': serializer.toJson<String>(status),
      'joinedAt': serializer.toJson<int>(joinedAt),
    };
  }

  StoreMembershipsTableData copyWith(
          {String? id,
          String? storeId,
          String? userUid,
          String? role,
          String? displayName,
          String? status,
          int? joinedAt}) =>
      StoreMembershipsTableData(
        id: id ?? this.id,
        storeId: storeId ?? this.storeId,
        userUid: userUid ?? this.userUid,
        role: role ?? this.role,
        displayName: displayName ?? this.displayName,
        status: status ?? this.status,
        joinedAt: joinedAt ?? this.joinedAt,
      );
  StoreMembershipsTableData copyWithCompanion(
      StoreMembershipsTableCompanion data) {
    return StoreMembershipsTableData(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      userUid: data.userUid.present ? data.userUid.value : this.userUid,
      role: data.role.present ? data.role.value : this.role,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      status: data.status.present ? data.status.value : this.status,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoreMembershipsTableData(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('userUid: $userUid, ')
          ..write('role: $role, ')
          ..write('displayName: $displayName, ')
          ..write('status: $status, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, storeId, userUid, role, displayName, status, joinedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoreMembershipsTableData &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.userUid == this.userUid &&
          other.role == this.role &&
          other.displayName == this.displayName &&
          other.status == this.status &&
          other.joinedAt == this.joinedAt);
}

class StoreMembershipsTableCompanion
    extends UpdateCompanion<StoreMembershipsTableData> {
  final Value<String> id;
  final Value<String> storeId;
  final Value<String> userUid;
  final Value<String> role;
  final Value<String> displayName;
  final Value<String> status;
  final Value<int> joinedAt;
  final Value<int> rowid;
  const StoreMembershipsTableCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.userUid = const Value.absent(),
    this.role = const Value.absent(),
    this.displayName = const Value.absent(),
    this.status = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoreMembershipsTableCompanion.insert({
    required String id,
    required String storeId,
    required String userUid,
    required String role,
    required String displayName,
    required String status,
    required int joinedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        storeId = Value(storeId),
        userUid = Value(userUid),
        role = Value(role),
        displayName = Value(displayName),
        status = Value(status),
        joinedAt = Value(joinedAt);
  static Insertable<StoreMembershipsTableData> custom({
    Expression<String>? id,
    Expression<String>? storeId,
    Expression<String>? userUid,
    Expression<String>? role,
    Expression<String>? displayName,
    Expression<String>? status,
    Expression<int>? joinedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (userUid != null) 'user_uid': userUid,
      if (role != null) 'role': role,
      if (displayName != null) 'display_name': displayName,
      if (status != null) 'status': status,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoreMembershipsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? storeId,
      Value<String>? userUid,
      Value<String>? role,
      Value<String>? displayName,
      Value<String>? status,
      Value<int>? joinedAt,
      Value<int>? rowid}) {
    return StoreMembershipsTableCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      userUid: userUid ?? this.userUid,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (userUid.present) {
      map['user_uid'] = Variable<String>(userUid.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<int>(joinedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoreMembershipsTableCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('userUid: $userUid, ')
          ..write('role: $role, ')
          ..write('displayName: $displayName, ')
          ..write('status: $status, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoreGroupsTableTable extends StoreGroupsTable
    with TableInfo<$StoreGroupsTableTable, StoreGroupsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoreGroupsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByUidMeta =
      const VerificationMeta('createdByUid');
  @override
  late final GeneratedColumn<String> createdByUid = GeneratedColumn<String>(
      'created_by_uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, createdByUid, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'store_groups';
  @override
  VerificationContext validateIntegrity(
      Insertable<StoreGroupsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('created_by_uid')) {
      context.handle(
          _createdByUidMeta,
          createdByUid.isAcceptableOrUnknown(
              data['created_by_uid']!, _createdByUidMeta));
    } else if (isInserting) {
      context.missing(_createdByUidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoreGroupsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoreGroupsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      createdByUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by_uid'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $StoreGroupsTableTable createAlias(String alias) {
    return $StoreGroupsTableTable(attachedDatabase, alias);
  }
}

class StoreGroupsTableData extends DataClass
    implements Insertable<StoreGroupsTableData> {
  final String id;
  final String name;
  final String? description;
  final String createdByUid;
  final int createdAt;
  const StoreGroupsTableData(
      {required this.id,
      required this.name,
      this.description,
      required this.createdByUid,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_by_uid'] = Variable<String>(createdByUid);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  StoreGroupsTableCompanion toCompanion(bool nullToAbsent) {
    return StoreGroupsTableCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdByUid: Value(createdByUid),
      createdAt: Value(createdAt),
    );
  }

  factory StoreGroupsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoreGroupsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      createdByUid: serializer.fromJson<String>(json['createdByUid']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'createdByUid': serializer.toJson<String>(createdByUid),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  StoreGroupsTableData copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          String? createdByUid,
          int? createdAt}) =>
      StoreGroupsTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        createdByUid: createdByUid ?? this.createdByUid,
        createdAt: createdAt ?? this.createdAt,
      );
  StoreGroupsTableData copyWithCompanion(StoreGroupsTableCompanion data) {
    return StoreGroupsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      createdByUid: data.createdByUid.present
          ? data.createdByUid.value
          : this.createdByUid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoreGroupsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdByUid: $createdByUid, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, createdByUid, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoreGroupsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdByUid == this.createdByUid &&
          other.createdAt == this.createdAt);
}

class StoreGroupsTableCompanion extends UpdateCompanion<StoreGroupsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> createdByUid;
  final Value<int> createdAt;
  final Value<int> rowid;
  const StoreGroupsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdByUid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoreGroupsTableCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String createdByUid,
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdByUid = Value(createdByUid),
        createdAt = Value(createdAt);
  static Insertable<StoreGroupsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? createdByUid,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdByUid != null) 'created_by_uid': createdByUid,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoreGroupsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? createdByUid,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return StoreGroupsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdByUid: createdByUid ?? this.createdByUid,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdByUid.present) {
      map['created_by_uid'] = Variable<String>(createdByUid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoreGroupsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdByUid: $createdByUid, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoreGroupMembersTableTable extends StoreGroupMembersTable
    with TableInfo<$StoreGroupMembersTableTable, StoreGroupMembersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoreGroupMembersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _storeIdMeta =
      const VerificationMeta('storeId');
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
      'store_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<int> addedAt = GeneratedColumn<int>(
      'added_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _addedByUidMeta =
      const VerificationMeta('addedByUid');
  @override
  late final GeneratedColumn<String> addedByUid = GeneratedColumn<String>(
      'added_by_uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, groupId, storeId, addedAt, addedByUid];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'store_group_members';
  @override
  VerificationContext validateIntegrity(
      Insertable<StoreGroupMembersTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(_storeIdMeta,
          storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta));
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('added_by_uid')) {
      context.handle(
          _addedByUidMeta,
          addedByUid.isAcceptableOrUnknown(
              data['added_by_uid']!, _addedByUidMeta));
    } else if (isInserting) {
      context.missing(_addedByUidMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoreGroupMembersTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoreGroupMembersTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      storeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store_id'])!,
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}added_at'])!,
      addedByUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}added_by_uid'])!,
    );
  }

  @override
  $StoreGroupMembersTableTable createAlias(String alias) {
    return $StoreGroupMembersTableTable(attachedDatabase, alias);
  }
}

class StoreGroupMembersTableData extends DataClass
    implements Insertable<StoreGroupMembersTableData> {
  final String id;
  final String groupId;
  final String storeId;
  final int addedAt;
  final String addedByUid;
  const StoreGroupMembersTableData(
      {required this.id,
      required this.groupId,
      required this.storeId,
      required this.addedAt,
      required this.addedByUid});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['store_id'] = Variable<String>(storeId);
    map['added_at'] = Variable<int>(addedAt);
    map['added_by_uid'] = Variable<String>(addedByUid);
    return map;
  }

  StoreGroupMembersTableCompanion toCompanion(bool nullToAbsent) {
    return StoreGroupMembersTableCompanion(
      id: Value(id),
      groupId: Value(groupId),
      storeId: Value(storeId),
      addedAt: Value(addedAt),
      addedByUid: Value(addedByUid),
    );
  }

  factory StoreGroupMembersTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoreGroupMembersTableData(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      storeId: serializer.fromJson<String>(json['storeId']),
      addedAt: serializer.fromJson<int>(json['addedAt']),
      addedByUid: serializer.fromJson<String>(json['addedByUid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'storeId': serializer.toJson<String>(storeId),
      'addedAt': serializer.toJson<int>(addedAt),
      'addedByUid': serializer.toJson<String>(addedByUid),
    };
  }

  StoreGroupMembersTableData copyWith(
          {String? id,
          String? groupId,
          String? storeId,
          int? addedAt,
          String? addedByUid}) =>
      StoreGroupMembersTableData(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        storeId: storeId ?? this.storeId,
        addedAt: addedAt ?? this.addedAt,
        addedByUid: addedByUid ?? this.addedByUid,
      );
  StoreGroupMembersTableData copyWithCompanion(
      StoreGroupMembersTableCompanion data) {
    return StoreGroupMembersTableData(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      addedByUid:
          data.addedByUid.present ? data.addedByUid.value : this.addedByUid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoreGroupMembersTableData(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('storeId: $storeId, ')
          ..write('addedAt: $addedAt, ')
          ..write('addedByUid: $addedByUid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, groupId, storeId, addedAt, addedByUid);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoreGroupMembersTableData &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.storeId == this.storeId &&
          other.addedAt == this.addedAt &&
          other.addedByUid == this.addedByUid);
}

class StoreGroupMembersTableCompanion
    extends UpdateCompanion<StoreGroupMembersTableData> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> storeId;
  final Value<int> addedAt;
  final Value<String> addedByUid;
  final Value<int> rowid;
  const StoreGroupMembersTableCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.storeId = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.addedByUid = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoreGroupMembersTableCompanion.insert({
    required String id,
    required String groupId,
    required String storeId,
    required int addedAt,
    required String addedByUid,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        groupId = Value(groupId),
        storeId = Value(storeId),
        addedAt = Value(addedAt),
        addedByUid = Value(addedByUid);
  static Insertable<StoreGroupMembersTableData> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? storeId,
    Expression<int>? addedAt,
    Expression<String>? addedByUid,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (storeId != null) 'store_id': storeId,
      if (addedAt != null) 'added_at': addedAt,
      if (addedByUid != null) 'added_by_uid': addedByUid,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoreGroupMembersTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? groupId,
      Value<String>? storeId,
      Value<int>? addedAt,
      Value<String>? addedByUid,
      Value<int>? rowid}) {
    return StoreGroupMembersTableCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      storeId: storeId ?? this.storeId,
      addedAt: addedAt ?? this.addedAt,
      addedByUid: addedByUid ?? this.addedByUid,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<int>(addedAt.value);
    }
    if (addedByUid.present) {
      map['added_by_uid'] = Variable<String>(addedByUid.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoreGroupMembersTableCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('storeId: $storeId, ')
          ..write('addedAt: $addedAt, ')
          ..write('addedByUid: $addedByUid, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanogramProposalsTableTable extends PlanogramProposalsTable
    with TableInfo<$PlanogramProposalsTableTable, PlanogramProposalsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanogramProposalsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _planogramIdMeta =
      const VerificationMeta('planogramId');
  @override
  late final GeneratedColumn<String> planogramId = GeneratedColumn<String>(
      'planogram_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _storeIdMeta =
      const VerificationMeta('storeId');
  @override
  late final GeneratedColumn<String> storeId = GeneratedColumn<String>(
      'store_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _proposedByUidMeta =
      const VerificationMeta('proposedByUid');
  @override
  late final GeneratedColumn<String> proposedByUid = GeneratedColumn<String>(
      'proposed_by_uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _proposedAtMeta =
      const VerificationMeta('proposedAt');
  @override
  late final GeneratedColumn<int> proposedAt = GeneratedColumn<int>(
      'proposed_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _slotChangesMeta =
      const VerificationMeta('slotChanges');
  @override
  late final GeneratedColumn<String> slotChanges = GeneratedColumn<String>(
      'slot_changes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reviewedByUidMeta =
      const VerificationMeta('reviewedByUid');
  @override
  late final GeneratedColumn<String> reviewedByUid = GeneratedColumn<String>(
      'reviewed_by_uid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reviewedAtMeta =
      const VerificationMeta('reviewedAt');
  @override
  late final GeneratedColumn<int> reviewedAt = GeneratedColumn<int>(
      'reviewed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        planogramId,
        storeId,
        proposedByUid,
        proposedAt,
        status,
        notes,
        slotChanges,
        reviewedByUid,
        reviewedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'planogram_proposals';
  @override
  VerificationContext validateIntegrity(
      Insertable<PlanogramProposalsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('planogram_id')) {
      context.handle(
          _planogramIdMeta,
          planogramId.isAcceptableOrUnknown(
              data['planogram_id']!, _planogramIdMeta));
    } else if (isInserting) {
      context.missing(_planogramIdMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(_storeIdMeta,
          storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta));
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('proposed_by_uid')) {
      context.handle(
          _proposedByUidMeta,
          proposedByUid.isAcceptableOrUnknown(
              data['proposed_by_uid']!, _proposedByUidMeta));
    } else if (isInserting) {
      context.missing(_proposedByUidMeta);
    }
    if (data.containsKey('proposed_at')) {
      context.handle(
          _proposedAtMeta,
          proposedAt.isAcceptableOrUnknown(
              data['proposed_at']!, _proposedAtMeta));
    } else if (isInserting) {
      context.missing(_proposedAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('slot_changes')) {
      context.handle(
          _slotChangesMeta,
          slotChanges.isAcceptableOrUnknown(
              data['slot_changes']!, _slotChangesMeta));
    }
    if (data.containsKey('reviewed_by_uid')) {
      context.handle(
          _reviewedByUidMeta,
          reviewedByUid.isAcceptableOrUnknown(
              data['reviewed_by_uid']!, _reviewedByUidMeta));
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
          _reviewedAtMeta,
          reviewedAt.isAcceptableOrUnknown(
              data['reviewed_at']!, _reviewedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanogramProposalsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanogramProposalsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      planogramId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}planogram_id'])!,
      storeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}store_id'])!,
      proposedByUid: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}proposed_by_uid'])!,
      proposedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}proposed_at'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      slotChanges: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}slot_changes']),
      reviewedByUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reviewed_by_uid']),
      reviewedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reviewed_at']),
    );
  }

  @override
  $PlanogramProposalsTableTable createAlias(String alias) {
    return $PlanogramProposalsTableTable(attachedDatabase, alias);
  }
}

class PlanogramProposalsTableData extends DataClass
    implements Insertable<PlanogramProposalsTableData> {
  final String id;
  final String planogramId;
  final String storeId;
  final String proposedByUid;
  final int proposedAt;
  final String status;
  final String? notes;
  final String? slotChanges;
  final String? reviewedByUid;
  final int? reviewedAt;
  const PlanogramProposalsTableData(
      {required this.id,
      required this.planogramId,
      required this.storeId,
      required this.proposedByUid,
      required this.proposedAt,
      required this.status,
      this.notes,
      this.slotChanges,
      this.reviewedByUid,
      this.reviewedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['planogram_id'] = Variable<String>(planogramId);
    map['store_id'] = Variable<String>(storeId);
    map['proposed_by_uid'] = Variable<String>(proposedByUid);
    map['proposed_at'] = Variable<int>(proposedAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || slotChanges != null) {
      map['slot_changes'] = Variable<String>(slotChanges);
    }
    if (!nullToAbsent || reviewedByUid != null) {
      map['reviewed_by_uid'] = Variable<String>(reviewedByUid);
    }
    if (!nullToAbsent || reviewedAt != null) {
      map['reviewed_at'] = Variable<int>(reviewedAt);
    }
    return map;
  }

  PlanogramProposalsTableCompanion toCompanion(bool nullToAbsent) {
    return PlanogramProposalsTableCompanion(
      id: Value(id),
      planogramId: Value(planogramId),
      storeId: Value(storeId),
      proposedByUid: Value(proposedByUid),
      proposedAt: Value(proposedAt),
      status: Value(status),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      slotChanges: slotChanges == null && nullToAbsent
          ? const Value.absent()
          : Value(slotChanges),
      reviewedByUid: reviewedByUid == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedByUid),
      reviewedAt: reviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedAt),
    );
  }

  factory PlanogramProposalsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanogramProposalsTableData(
      id: serializer.fromJson<String>(json['id']),
      planogramId: serializer.fromJson<String>(json['planogramId']),
      storeId: serializer.fromJson<String>(json['storeId']),
      proposedByUid: serializer.fromJson<String>(json['proposedByUid']),
      proposedAt: serializer.fromJson<int>(json['proposedAt']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      slotChanges: serializer.fromJson<String?>(json['slotChanges']),
      reviewedByUid: serializer.fromJson<String?>(json['reviewedByUid']),
      reviewedAt: serializer.fromJson<int?>(json['reviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planogramId': serializer.toJson<String>(planogramId),
      'storeId': serializer.toJson<String>(storeId),
      'proposedByUid': serializer.toJson<String>(proposedByUid),
      'proposedAt': serializer.toJson<int>(proposedAt),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'slotChanges': serializer.toJson<String?>(slotChanges),
      'reviewedByUid': serializer.toJson<String?>(reviewedByUid),
      'reviewedAt': serializer.toJson<int?>(reviewedAt),
    };
  }

  PlanogramProposalsTableData copyWith(
          {String? id,
          String? planogramId,
          String? storeId,
          String? proposedByUid,
          int? proposedAt,
          String? status,
          Value<String?> notes = const Value.absent(),
          Value<String?> slotChanges = const Value.absent(),
          Value<String?> reviewedByUid = const Value.absent(),
          Value<int?> reviewedAt = const Value.absent()}) =>
      PlanogramProposalsTableData(
        id: id ?? this.id,
        planogramId: planogramId ?? this.planogramId,
        storeId: storeId ?? this.storeId,
        proposedByUid: proposedByUid ?? this.proposedByUid,
        proposedAt: proposedAt ?? this.proposedAt,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
        slotChanges: slotChanges.present ? slotChanges.value : this.slotChanges,
        reviewedByUid:
            reviewedByUid.present ? reviewedByUid.value : this.reviewedByUid,
        reviewedAt: reviewedAt.present ? reviewedAt.value : this.reviewedAt,
      );
  PlanogramProposalsTableData copyWithCompanion(
      PlanogramProposalsTableCompanion data) {
    return PlanogramProposalsTableData(
      id: data.id.present ? data.id.value : this.id,
      planogramId:
          data.planogramId.present ? data.planogramId.value : this.planogramId,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      proposedByUid: data.proposedByUid.present
          ? data.proposedByUid.value
          : this.proposedByUid,
      proposedAt:
          data.proposedAt.present ? data.proposedAt.value : this.proposedAt,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      slotChanges:
          data.slotChanges.present ? data.slotChanges.value : this.slotChanges,
      reviewedByUid: data.reviewedByUid.present
          ? data.reviewedByUid.value
          : this.reviewedByUid,
      reviewedAt:
          data.reviewedAt.present ? data.reviewedAt.value : this.reviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanogramProposalsTableData(')
          ..write('id: $id, ')
          ..write('planogramId: $planogramId, ')
          ..write('storeId: $storeId, ')
          ..write('proposedByUid: $proposedByUid, ')
          ..write('proposedAt: $proposedAt, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('slotChanges: $slotChanges, ')
          ..write('reviewedByUid: $reviewedByUid, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, planogramId, storeId, proposedByUid,
      proposedAt, status, notes, slotChanges, reviewedByUid, reviewedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanogramProposalsTableData &&
          other.id == this.id &&
          other.planogramId == this.planogramId &&
          other.storeId == this.storeId &&
          other.proposedByUid == this.proposedByUid &&
          other.proposedAt == this.proposedAt &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.slotChanges == this.slotChanges &&
          other.reviewedByUid == this.reviewedByUid &&
          other.reviewedAt == this.reviewedAt);
}

class PlanogramProposalsTableCompanion
    extends UpdateCompanion<PlanogramProposalsTableData> {
  final Value<String> id;
  final Value<String> planogramId;
  final Value<String> storeId;
  final Value<String> proposedByUid;
  final Value<int> proposedAt;
  final Value<String> status;
  final Value<String?> notes;
  final Value<String?> slotChanges;
  final Value<String?> reviewedByUid;
  final Value<int?> reviewedAt;
  final Value<int> rowid;
  const PlanogramProposalsTableCompanion({
    this.id = const Value.absent(),
    this.planogramId = const Value.absent(),
    this.storeId = const Value.absent(),
    this.proposedByUid = const Value.absent(),
    this.proposedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.slotChanges = const Value.absent(),
    this.reviewedByUid = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanogramProposalsTableCompanion.insert({
    required String id,
    required String planogramId,
    required String storeId,
    required String proposedByUid,
    required int proposedAt,
    required String status,
    this.notes = const Value.absent(),
    this.slotChanges = const Value.absent(),
    this.reviewedByUid = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        planogramId = Value(planogramId),
        storeId = Value(storeId),
        proposedByUid = Value(proposedByUid),
        proposedAt = Value(proposedAt),
        status = Value(status);
  static Insertable<PlanogramProposalsTableData> custom({
    Expression<String>? id,
    Expression<String>? planogramId,
    Expression<String>? storeId,
    Expression<String>? proposedByUid,
    Expression<int>? proposedAt,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? slotChanges,
    Expression<String>? reviewedByUid,
    Expression<int>? reviewedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planogramId != null) 'planogram_id': planogramId,
      if (storeId != null) 'store_id': storeId,
      if (proposedByUid != null) 'proposed_by_uid': proposedByUid,
      if (proposedAt != null) 'proposed_at': proposedAt,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (slotChanges != null) 'slot_changes': slotChanges,
      if (reviewedByUid != null) 'reviewed_by_uid': reviewedByUid,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanogramProposalsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? planogramId,
      Value<String>? storeId,
      Value<String>? proposedByUid,
      Value<int>? proposedAt,
      Value<String>? status,
      Value<String?>? notes,
      Value<String?>? slotChanges,
      Value<String?>? reviewedByUid,
      Value<int?>? reviewedAt,
      Value<int>? rowid}) {
    return PlanogramProposalsTableCompanion(
      id: id ?? this.id,
      planogramId: planogramId ?? this.planogramId,
      storeId: storeId ?? this.storeId,
      proposedByUid: proposedByUid ?? this.proposedByUid,
      proposedAt: proposedAt ?? this.proposedAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      slotChanges: slotChanges ?? this.slotChanges,
      reviewedByUid: reviewedByUid ?? this.reviewedByUid,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (planogramId.present) {
      map['planogram_id'] = Variable<String>(planogramId.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<String>(storeId.value);
    }
    if (proposedByUid.present) {
      map['proposed_by_uid'] = Variable<String>(proposedByUid.value);
    }
    if (proposedAt.present) {
      map['proposed_at'] = Variable<int>(proposedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (slotChanges.present) {
      map['slot_changes'] = Variable<String>(slotChanges.value);
    }
    if (reviewedByUid.present) {
      map['reviewed_by_uid'] = Variable<String>(reviewedByUid.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<int>(reviewedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanogramProposalsTableCompanion(')
          ..write('id: $id, ')
          ..write('planogramId: $planogramId, ')
          ..write('storeId: $storeId, ')
          ..write('proposedByUid: $proposedByUid, ')
          ..write('proposedAt: $proposedAt, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('slotChanges: $slotChanges, ')
          ..write('reviewedByUid: $reviewedByUid, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ZonesTableTable zonesTable = $ZonesTableTable(this);
  late final $FixturesTableTable fixturesTable = $FixturesTableTable(this);
  late final $ProductsTableTable productsTable = $ProductsTableTable(this);
  late final $PlanogramsTableTable planogramsTable =
      $PlanogramsTableTable(this);
  late final $PhotoDocsTableTable photoDocsTable = $PhotoDocsTableTable(this);
  late final $StoresTableTable storesTable = $StoresTableTable(this);
  late final $StoreMembershipsTableTable storeMembershipsTable =
      $StoreMembershipsTableTable(this);
  late final $StoreGroupsTableTable storeGroupsTable =
      $StoreGroupsTableTable(this);
  late final $StoreGroupMembersTableTable storeGroupMembersTable =
      $StoreGroupMembersTableTable(this);
  late final $PlanogramProposalsTableTable planogramProposalsTable =
      $PlanogramProposalsTableTable(this);
  late final ZonesDao zonesDao = ZonesDao(this as AppDatabase);
  late final FixturesDao fixturesDao = FixturesDao(this as AppDatabase);
  late final ProductsDao productsDao = ProductsDao(this as AppDatabase);
  late final PlanogramsDao planogramsDao = PlanogramsDao(this as AppDatabase);
  late final PhotoDocsDao photoDocsDao = PhotoDocsDao(this as AppDatabase);
  late final StoresDao storesDao = StoresDao(this as AppDatabase);
  late final StoreMembershipsDao storeMembershipsDao =
      StoreMembershipsDao(this as AppDatabase);
  late final StoreGroupsDao storeGroupsDao =
      StoreGroupsDao(this as AppDatabase);
  late final PlanogramProposalsDao planogramProposalsDao =
      PlanogramProposalsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        zonesTable,
        fixturesTable,
        productsTable,
        planogramsTable,
        photoDocsTable,
        storesTable,
        storeMembershipsTable,
        storeGroupsTable,
        storeGroupMembersTable,
        planogramProposalsTable
      ];
}

typedef $$ZonesTableTableCreateCompanionBuilder = ZonesTableCompanion Function({
  required String id,
  required String name,
  required int colorValue,
  required String zoneType,
  required String storeId,
  Value<double> posX,
  Value<double> posY,
  Value<double> width,
  Value<double> height,
  Value<String?> shapePoints,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ZonesTableTableUpdateCompanionBuilder = ZonesTableCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> colorValue,
  Value<String> zoneType,
  Value<String> storeId,
  Value<double> posX,
  Value<double> posY,
  Value<double> width,
  Value<double> height,
  Value<String?> shapePoints,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ZonesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ZonesTableTable> {
  $$ZonesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get zoneType => $composableBuilder(
      column: $table.zoneType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storeId => $composableBuilder(
      column: $table.storeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get posX => $composableBuilder(
      column: $table.posX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get posY => $composableBuilder(
      column: $table.posY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get width => $composableBuilder(
      column: $table.width, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shapePoints => $composableBuilder(
      column: $table.shapePoints, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ZonesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ZonesTableTable> {
  $$ZonesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get zoneType => $composableBuilder(
      column: $table.zoneType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storeId => $composableBuilder(
      column: $table.storeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get posX => $composableBuilder(
      column: $table.posX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get posY => $composableBuilder(
      column: $table.posY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get width => $composableBuilder(
      column: $table.width, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shapePoints => $composableBuilder(
      column: $table.shapePoints, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ZonesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ZonesTableTable> {
  $$ZonesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => column);

  GeneratedColumn<String> get zoneType =>
      $composableBuilder(column: $table.zoneType, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<double> get posX =>
      $composableBuilder(column: $table.posX, builder: (column) => column);

  GeneratedColumn<double> get posY =>
      $composableBuilder(column: $table.posY, builder: (column) => column);

  GeneratedColumn<double> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get shapePoints => $composableBuilder(
      column: $table.shapePoints, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ZonesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ZonesTableTable,
    ZonesTableData,
    $$ZonesTableTableFilterComposer,
    $$ZonesTableTableOrderingComposer,
    $$ZonesTableTableAnnotationComposer,
    $$ZonesTableTableCreateCompanionBuilder,
    $$ZonesTableTableUpdateCompanionBuilder,
    (
      ZonesTableData,
      BaseReferences<_$AppDatabase, $ZonesTableTable, ZonesTableData>
    ),
    ZonesTableData,
    PrefetchHooks Function()> {
  $$ZonesTableTableTableManager(_$AppDatabase db, $ZonesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ZonesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ZonesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ZonesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> colorValue = const Value.absent(),
            Value<String> zoneType = const Value.absent(),
            Value<String> storeId = const Value.absent(),
            Value<double> posX = const Value.absent(),
            Value<double> posY = const Value.absent(),
            Value<double> width = const Value.absent(),
            Value<double> height = const Value.absent(),
            Value<String?> shapePoints = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ZonesTableCompanion(
            id: id,
            name: name,
            colorValue: colorValue,
            zoneType: zoneType,
            storeId: storeId,
            posX: posX,
            posY: posY,
            width: width,
            height: height,
            shapePoints: shapePoints,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int colorValue,
            required String zoneType,
            required String storeId,
            Value<double> posX = const Value.absent(),
            Value<double> posY = const Value.absent(),
            Value<double> width = const Value.absent(),
            Value<double> height = const Value.absent(),
            Value<String?> shapePoints = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ZonesTableCompanion.insert(
            id: id,
            name: name,
            colorValue: colorValue,
            zoneType: zoneType,
            storeId: storeId,
            posX: posX,
            posY: posY,
            width: width,
            height: height,
            shapePoints: shapePoints,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ZonesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ZonesTableTable,
    ZonesTableData,
    $$ZonesTableTableFilterComposer,
    $$ZonesTableTableOrderingComposer,
    $$ZonesTableTableAnnotationComposer,
    $$ZonesTableTableCreateCompanionBuilder,
    $$ZonesTableTableUpdateCompanionBuilder,
    (
      ZonesTableData,
      BaseReferences<_$AppDatabase, $ZonesTableTable, ZonesTableData>
    ),
    ZonesTableData,
    PrefetchHooks Function()>;
typedef $$FixturesTableTableCreateCompanionBuilder = FixturesTableCompanion
    Function({
  required String id,
  required String zoneId,
  required String fixtureType,
  Value<double> posX,
  Value<double> posY,
  Value<double> rotation,
  Value<double> widthFt,
  Value<double> depthFt,
  Value<String> label,
  Value<String> storeId,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$FixturesTableTableUpdateCompanionBuilder = FixturesTableCompanion
    Function({
  Value<String> id,
  Value<String> zoneId,
  Value<String> fixtureType,
  Value<double> posX,
  Value<double> posY,
  Value<double> rotation,
  Value<double> widthFt,
  Value<double> depthFt,
  Value<String> label,
  Value<String> storeId,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$FixturesTableTableFilterComposer
    extends Composer<_$AppDatabase, $FixturesTableTable> {
  $$FixturesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get zoneId => $composableBuilder(
      column: $table.zoneId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fixtureType => $composableBuilder(
      column: $table.fixtureType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get posX => $composableBuilder(
      column: $table.posX, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get posY => $composableBuilder(
      column: $table.posY, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rotation => $composableBuilder(
      column: $table.rotation, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get widthFt => $composableBuilder(
      column: $table.widthFt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get depthFt => $composableBuilder(
      column: $table.depthFt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storeId => $composableBuilder(
      column: $table.storeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$FixturesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FixturesTableTable> {
  $$FixturesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get zoneId => $composableBuilder(
      column: $table.zoneId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fixtureType => $composableBuilder(
      column: $table.fixtureType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get posX => $composableBuilder(
      column: $table.posX, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get posY => $composableBuilder(
      column: $table.posY, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rotation => $composableBuilder(
      column: $table.rotation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get widthFt => $composableBuilder(
      column: $table.widthFt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get depthFt => $composableBuilder(
      column: $table.depthFt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storeId => $composableBuilder(
      column: $table.storeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$FixturesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FixturesTableTable> {
  $$FixturesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get zoneId =>
      $composableBuilder(column: $table.zoneId, builder: (column) => column);

  GeneratedColumn<String> get fixtureType => $composableBuilder(
      column: $table.fixtureType, builder: (column) => column);

  GeneratedColumn<double> get posX =>
      $composableBuilder(column: $table.posX, builder: (column) => column);

  GeneratedColumn<double> get posY =>
      $composableBuilder(column: $table.posY, builder: (column) => column);

  GeneratedColumn<double> get rotation =>
      $composableBuilder(column: $table.rotation, builder: (column) => column);

  GeneratedColumn<double> get widthFt =>
      $composableBuilder(column: $table.widthFt, builder: (column) => column);

  GeneratedColumn<double> get depthFt =>
      $composableBuilder(column: $table.depthFt, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FixturesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FixturesTableTable,
    FixturesTableData,
    $$FixturesTableTableFilterComposer,
    $$FixturesTableTableOrderingComposer,
    $$FixturesTableTableAnnotationComposer,
    $$FixturesTableTableCreateCompanionBuilder,
    $$FixturesTableTableUpdateCompanionBuilder,
    (
      FixturesTableData,
      BaseReferences<_$AppDatabase, $FixturesTableTable, FixturesTableData>
    ),
    FixturesTableData,
    PrefetchHooks Function()> {
  $$FixturesTableTableTableManager(_$AppDatabase db, $FixturesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FixturesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FixturesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FixturesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> zoneId = const Value.absent(),
            Value<String> fixtureType = const Value.absent(),
            Value<double> posX = const Value.absent(),
            Value<double> posY = const Value.absent(),
            Value<double> rotation = const Value.absent(),
            Value<double> widthFt = const Value.absent(),
            Value<double> depthFt = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String> storeId = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FixturesTableCompanion(
            id: id,
            zoneId: zoneId,
            fixtureType: fixtureType,
            posX: posX,
            posY: posY,
            rotation: rotation,
            widthFt: widthFt,
            depthFt: depthFt,
            label: label,
            storeId: storeId,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String zoneId,
            required String fixtureType,
            Value<double> posX = const Value.absent(),
            Value<double> posY = const Value.absent(),
            Value<double> rotation = const Value.absent(),
            Value<double> widthFt = const Value.absent(),
            Value<double> depthFt = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String> storeId = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              FixturesTableCompanion.insert(
            id: id,
            zoneId: zoneId,
            fixtureType: fixtureType,
            posX: posX,
            posY: posY,
            rotation: rotation,
            widthFt: widthFt,
            depthFt: depthFt,
            label: label,
            storeId: storeId,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FixturesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FixturesTableTable,
    FixturesTableData,
    $$FixturesTableTableFilterComposer,
    $$FixturesTableTableOrderingComposer,
    $$FixturesTableTableAnnotationComposer,
    $$FixturesTableTableCreateCompanionBuilder,
    $$FixturesTableTableUpdateCompanionBuilder,
    (
      FixturesTableData,
      BaseReferences<_$AppDatabase, $FixturesTableTable, FixturesTableData>
    ),
    FixturesTableData,
    PrefetchHooks Function()>;
typedef $$ProductsTableTableCreateCompanionBuilder = ProductsTableCompanion
    Function({
  required String id,
  required String sku,
  required String name,
  required String category,
  Value<String> imageUrl,
  Value<String> sizesJson,
  Value<int> stockQty,
  Value<String> storeId,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ProductsTableTableUpdateCompanionBuilder = ProductsTableCompanion
    Function({
  Value<String> id,
  Value<String> sku,
  Value<String> name,
  Value<String> category,
  Value<String> imageUrl,
  Value<String> sizesJson,
  Value<int> stockQty,
  Value<String> storeId,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ProductsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sizesJson => $composableBuilder(
      column: $table.sizesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stockQty => $composableBuilder(
      column: $table.stockQty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storeId => $composableBuilder(
      column: $table.storeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ProductsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sizesJson => $composableBuilder(
      column: $table.sizesJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stockQty => $composableBuilder(
      column: $table.stockQty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storeId => $composableBuilder(
      column: $table.storeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProductsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get sizesJson =>
      $composableBuilder(column: $table.sizesJson, builder: (column) => column);

  GeneratedColumn<int> get stockQty =>
      $composableBuilder(column: $table.stockQty, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProductsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTableTable,
    ProductsTableData,
    $$ProductsTableTableFilterComposer,
    $$ProductsTableTableOrderingComposer,
    $$ProductsTableTableAnnotationComposer,
    $$ProductsTableTableCreateCompanionBuilder,
    $$ProductsTableTableUpdateCompanionBuilder,
    (
      ProductsTableData,
      BaseReferences<_$AppDatabase, $ProductsTableTable, ProductsTableData>
    ),
    ProductsTableData,
    PrefetchHooks Function()> {
  $$ProductsTableTableTableManager(_$AppDatabase db, $ProductsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sku = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> imageUrl = const Value.absent(),
            Value<String> sizesJson = const Value.absent(),
            Value<int> stockQty = const Value.absent(),
            Value<String> storeId = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsTableCompanion(
            id: id,
            sku: sku,
            name: name,
            category: category,
            imageUrl: imageUrl,
            sizesJson: sizesJson,
            stockQty: stockQty,
            storeId: storeId,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sku,
            required String name,
            required String category,
            Value<String> imageUrl = const Value.absent(),
            Value<String> sizesJson = const Value.absent(),
            Value<int> stockQty = const Value.absent(),
            Value<String> storeId = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsTableCompanion.insert(
            id: id,
            sku: sku,
            name: name,
            category: category,
            imageUrl: imageUrl,
            sizesJson: sizesJson,
            stockQty: stockQty,
            storeId: storeId,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTableTable,
    ProductsTableData,
    $$ProductsTableTableFilterComposer,
    $$ProductsTableTableOrderingComposer,
    $$ProductsTableTableAnnotationComposer,
    $$ProductsTableTableCreateCompanionBuilder,
    $$ProductsTableTableUpdateCompanionBuilder,
    (
      ProductsTableData,
      BaseReferences<_$AppDatabase, $ProductsTableTable, ProductsTableData>
    ),
    ProductsTableData,
    PrefetchHooks Function()>;
typedef $$PlanogramsTableTableCreateCompanionBuilder = PlanogramsTableCompanion
    Function({
  required String id,
  required String fixtureId,
  required String title,
  required String season,
  Value<String> status,
  Value<String> slotsJson,
  Value<DateTime?> publishedAt,
  required DateTime updatedAt,
  Value<String> storeId,
  Value<int> rowid,
});
typedef $$PlanogramsTableTableUpdateCompanionBuilder = PlanogramsTableCompanion
    Function({
  Value<String> id,
  Value<String> fixtureId,
  Value<String> title,
  Value<String> season,
  Value<String> status,
  Value<String> slotsJson,
  Value<DateTime?> publishedAt,
  Value<DateTime> updatedAt,
  Value<String> storeId,
  Value<int> rowid,
});

class $$PlanogramsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlanogramsTableTable> {
  $$PlanogramsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fixtureId => $composableBuilder(
      column: $table.fixtureId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get season => $composableBuilder(
      column: $table.season, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get slotsJson => $composableBuilder(
      column: $table.slotsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
      column: $table.publishedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storeId => $composableBuilder(
      column: $table.storeId, builder: (column) => ColumnFilters(column));
}

class $$PlanogramsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanogramsTableTable> {
  $$PlanogramsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fixtureId => $composableBuilder(
      column: $table.fixtureId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get season => $composableBuilder(
      column: $table.season, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get slotsJson => $composableBuilder(
      column: $table.slotsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
      column: $table.publishedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storeId => $composableBuilder(
      column: $table.storeId, builder: (column) => ColumnOrderings(column));
}

class $$PlanogramsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanogramsTableTable> {
  $$PlanogramsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fixtureId =>
      $composableBuilder(column: $table.fixtureId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get slotsJson =>
      $composableBuilder(column: $table.slotsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
      column: $table.publishedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);
}

class $$PlanogramsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlanogramsTableTable,
    PlanogramsTableData,
    $$PlanogramsTableTableFilterComposer,
    $$PlanogramsTableTableOrderingComposer,
    $$PlanogramsTableTableAnnotationComposer,
    $$PlanogramsTableTableCreateCompanionBuilder,
    $$PlanogramsTableTableUpdateCompanionBuilder,
    (
      PlanogramsTableData,
      BaseReferences<_$AppDatabase, $PlanogramsTableTable, PlanogramsTableData>
    ),
    PlanogramsTableData,
    PrefetchHooks Function()> {
  $$PlanogramsTableTableTableManager(
      _$AppDatabase db, $PlanogramsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanogramsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanogramsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanogramsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> fixtureId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> season = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> slotsJson = const Value.absent(),
            Value<DateTime?> publishedAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> storeId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanogramsTableCompanion(
            id: id,
            fixtureId: fixtureId,
            title: title,
            season: season,
            status: status,
            slotsJson: slotsJson,
            publishedAt: publishedAt,
            updatedAt: updatedAt,
            storeId: storeId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String fixtureId,
            required String title,
            required String season,
            Value<String> status = const Value.absent(),
            Value<String> slotsJson = const Value.absent(),
            Value<DateTime?> publishedAt = const Value.absent(),
            required DateTime updatedAt,
            Value<String> storeId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanogramsTableCompanion.insert(
            id: id,
            fixtureId: fixtureId,
            title: title,
            season: season,
            status: status,
            slotsJson: slotsJson,
            publishedAt: publishedAt,
            updatedAt: updatedAt,
            storeId: storeId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlanogramsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlanogramsTableTable,
    PlanogramsTableData,
    $$PlanogramsTableTableFilterComposer,
    $$PlanogramsTableTableOrderingComposer,
    $$PlanogramsTableTableAnnotationComposer,
    $$PlanogramsTableTableCreateCompanionBuilder,
    $$PlanogramsTableTableUpdateCompanionBuilder,
    (
      PlanogramsTableData,
      BaseReferences<_$AppDatabase, $PlanogramsTableTable, PlanogramsTableData>
    ),
    PlanogramsTableData,
    PrefetchHooks Function()>;
typedef $$PhotoDocsTableTableCreateCompanionBuilder = PhotoDocsTableCompanion
    Function({
  required String id,
  required String fixtureId,
  required String phase,
  required String localPath,
  Value<String> remoteUrl,
  Value<String> uploadStatus,
  Value<String> approvalStatus,
  Value<String?> planogramId,
  required DateTime capturedAt,
  required DateTime updatedAt,
  Value<String> storeId,
  Value<int> rowid,
});
typedef $$PhotoDocsTableTableUpdateCompanionBuilder = PhotoDocsTableCompanion
    Function({
  Value<String> id,
  Value<String> fixtureId,
  Value<String> phase,
  Value<String> localPath,
  Value<String> remoteUrl,
  Value<String> uploadStatus,
  Value<String> approvalStatus,
  Value<String?> planogramId,
  Value<DateTime> capturedAt,
  Value<DateTime> updatedAt,
  Value<String> storeId,
  Value<int> rowid,
});

class $$PhotoDocsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PhotoDocsTableTable> {
  $$PhotoDocsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fixtureId => $composableBuilder(
      column: $table.fixtureId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phase => $composableBuilder(
      column: $table.phase, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteUrl => $composableBuilder(
      column: $table.remoteUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uploadStatus => $composableBuilder(
      column: $table.uploadStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get approvalStatus => $composableBuilder(
      column: $table.approvalStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get planogramId => $composableBuilder(
      column: $table.planogramId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storeId => $composableBuilder(
      column: $table.storeId, builder: (column) => ColumnFilters(column));
}

class $$PhotoDocsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotoDocsTableTable> {
  $$PhotoDocsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fixtureId => $composableBuilder(
      column: $table.fixtureId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phase => $composableBuilder(
      column: $table.phase, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteUrl => $composableBuilder(
      column: $table.remoteUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uploadStatus => $composableBuilder(
      column: $table.uploadStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get approvalStatus => $composableBuilder(
      column: $table.approvalStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get planogramId => $composableBuilder(
      column: $table.planogramId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storeId => $composableBuilder(
      column: $table.storeId, builder: (column) => ColumnOrderings(column));
}

class $$PhotoDocsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotoDocsTableTable> {
  $$PhotoDocsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fixtureId =>
      $composableBuilder(column: $table.fixtureId, builder: (column) => column);

  GeneratedColumn<String> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get remoteUrl =>
      $composableBuilder(column: $table.remoteUrl, builder: (column) => column);

  GeneratedColumn<String> get uploadStatus => $composableBuilder(
      column: $table.uploadStatus, builder: (column) => column);

  GeneratedColumn<String> get approvalStatus => $composableBuilder(
      column: $table.approvalStatus, builder: (column) => column);

  GeneratedColumn<String> get planogramId => $composableBuilder(
      column: $table.planogramId, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
      column: $table.capturedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);
}

class $$PhotoDocsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PhotoDocsTableTable,
    PhotoDocsTableData,
    $$PhotoDocsTableTableFilterComposer,
    $$PhotoDocsTableTableOrderingComposer,
    $$PhotoDocsTableTableAnnotationComposer,
    $$PhotoDocsTableTableCreateCompanionBuilder,
    $$PhotoDocsTableTableUpdateCompanionBuilder,
    (
      PhotoDocsTableData,
      BaseReferences<_$AppDatabase, $PhotoDocsTableTable, PhotoDocsTableData>
    ),
    PhotoDocsTableData,
    PrefetchHooks Function()> {
  $$PhotoDocsTableTableTableManager(
      _$AppDatabase db, $PhotoDocsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotoDocsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotoDocsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotoDocsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> fixtureId = const Value.absent(),
            Value<String> phase = const Value.absent(),
            Value<String> localPath = const Value.absent(),
            Value<String> remoteUrl = const Value.absent(),
            Value<String> uploadStatus = const Value.absent(),
            Value<String> approvalStatus = const Value.absent(),
            Value<String?> planogramId = const Value.absent(),
            Value<DateTime> capturedAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> storeId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PhotoDocsTableCompanion(
            id: id,
            fixtureId: fixtureId,
            phase: phase,
            localPath: localPath,
            remoteUrl: remoteUrl,
            uploadStatus: uploadStatus,
            approvalStatus: approvalStatus,
            planogramId: planogramId,
            capturedAt: capturedAt,
            updatedAt: updatedAt,
            storeId: storeId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String fixtureId,
            required String phase,
            required String localPath,
            Value<String> remoteUrl = const Value.absent(),
            Value<String> uploadStatus = const Value.absent(),
            Value<String> approvalStatus = const Value.absent(),
            Value<String?> planogramId = const Value.absent(),
            required DateTime capturedAt,
            required DateTime updatedAt,
            Value<String> storeId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PhotoDocsTableCompanion.insert(
            id: id,
            fixtureId: fixtureId,
            phase: phase,
            localPath: localPath,
            remoteUrl: remoteUrl,
            uploadStatus: uploadStatus,
            approvalStatus: approvalStatus,
            planogramId: planogramId,
            capturedAt: capturedAt,
            updatedAt: updatedAt,
            storeId: storeId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PhotoDocsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PhotoDocsTableTable,
    PhotoDocsTableData,
    $$PhotoDocsTableTableFilterComposer,
    $$PhotoDocsTableTableOrderingComposer,
    $$PhotoDocsTableTableAnnotationComposer,
    $$PhotoDocsTableTableCreateCompanionBuilder,
    $$PhotoDocsTableTableUpdateCompanionBuilder,
    (
      PhotoDocsTableData,
      BaseReferences<_$AppDatabase, $PhotoDocsTableTable, PhotoDocsTableData>
    ),
    PhotoDocsTableData,
    PrefetchHooks Function()>;
typedef $$StoresTableTableCreateCompanionBuilder = StoresTableCompanion
    Function({
  required String id,
  required String name,
  required String inviteCode,
  required int createdAt,
  required String ownerUid,
  Value<int> rowid,
});
typedef $$StoresTableTableUpdateCompanionBuilder = StoresTableCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> inviteCode,
  Value<int> createdAt,
  Value<String> ownerUid,
  Value<int> rowid,
});

class $$StoresTableTableFilterComposer
    extends Composer<_$AppDatabase, $StoresTableTable> {
  $$StoresTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get inviteCode => $composableBuilder(
      column: $table.inviteCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerUid => $composableBuilder(
      column: $table.ownerUid, builder: (column) => ColumnFilters(column));
}

class $$StoresTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StoresTableTable> {
  $$StoresTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get inviteCode => $composableBuilder(
      column: $table.inviteCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerUid => $composableBuilder(
      column: $table.ownerUid, builder: (column) => ColumnOrderings(column));
}

class $$StoresTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoresTableTable> {
  $$StoresTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get inviteCode => $composableBuilder(
      column: $table.inviteCode, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get ownerUid =>
      $composableBuilder(column: $table.ownerUid, builder: (column) => column);
}

class $$StoresTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StoresTableTable,
    StoresTableData,
    $$StoresTableTableFilterComposer,
    $$StoresTableTableOrderingComposer,
    $$StoresTableTableAnnotationComposer,
    $$StoresTableTableCreateCompanionBuilder,
    $$StoresTableTableUpdateCompanionBuilder,
    (
      StoresTableData,
      BaseReferences<_$AppDatabase, $StoresTableTable, StoresTableData>
    ),
    StoresTableData,
    PrefetchHooks Function()> {
  $$StoresTableTableTableManager(_$AppDatabase db, $StoresTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoresTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoresTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoresTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> inviteCode = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<String> ownerUid = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StoresTableCompanion(
            id: id,
            name: name,
            inviteCode: inviteCode,
            createdAt: createdAt,
            ownerUid: ownerUid,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String inviteCode,
            required int createdAt,
            required String ownerUid,
            Value<int> rowid = const Value.absent(),
          }) =>
              StoresTableCompanion.insert(
            id: id,
            name: name,
            inviteCode: inviteCode,
            createdAt: createdAt,
            ownerUid: ownerUid,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StoresTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StoresTableTable,
    StoresTableData,
    $$StoresTableTableFilterComposer,
    $$StoresTableTableOrderingComposer,
    $$StoresTableTableAnnotationComposer,
    $$StoresTableTableCreateCompanionBuilder,
    $$StoresTableTableUpdateCompanionBuilder,
    (
      StoresTableData,
      BaseReferences<_$AppDatabase, $StoresTableTable, StoresTableData>
    ),
    StoresTableData,
    PrefetchHooks Function()>;
typedef $$StoreMembershipsTableTableCreateCompanionBuilder
    = StoreMembershipsTableCompanion Function({
  required String id,
  required String storeId,
  required String userUid,
  required String role,
  required String displayName,
  required String status,
  required int joinedAt,
  Value<int> rowid,
});
typedef $$StoreMembershipsTableTableUpdateCompanionBuilder
    = StoreMembershipsTableCompanion Function({
  Value<String> id,
  Value<String> storeId,
  Value<String> userUid,
  Value<String> role,
  Value<String> displayName,
  Value<String> status,
  Value<int> joinedAt,
  Value<int> rowid,
});

class $$StoreMembershipsTableTableFilterComposer
    extends Composer<_$AppDatabase, $StoreMembershipsTableTable> {
  $$StoreMembershipsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storeId => $composableBuilder(
      column: $table.storeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userUid => $composableBuilder(
      column: $table.userUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnFilters(column));
}

class $$StoreMembershipsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StoreMembershipsTableTable> {
  $$StoreMembershipsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storeId => $composableBuilder(
      column: $table.storeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userUid => $composableBuilder(
      column: $table.userUid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnOrderings(column));
}

class $$StoreMembershipsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoreMembershipsTableTable> {
  $$StoreMembershipsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get userUid =>
      $composableBuilder(column: $table.userUid, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);
}

class $$StoreMembershipsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StoreMembershipsTableTable,
    StoreMembershipsTableData,
    $$StoreMembershipsTableTableFilterComposer,
    $$StoreMembershipsTableTableOrderingComposer,
    $$StoreMembershipsTableTableAnnotationComposer,
    $$StoreMembershipsTableTableCreateCompanionBuilder,
    $$StoreMembershipsTableTableUpdateCompanionBuilder,
    (
      StoreMembershipsTableData,
      BaseReferences<_$AppDatabase, $StoreMembershipsTableTable,
          StoreMembershipsTableData>
    ),
    StoreMembershipsTableData,
    PrefetchHooks Function()> {
  $$StoreMembershipsTableTableTableManager(
      _$AppDatabase db, $StoreMembershipsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoreMembershipsTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$StoreMembershipsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoreMembershipsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> storeId = const Value.absent(),
            Value<String> userUid = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> joinedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StoreMembershipsTableCompanion(
            id: id,
            storeId: storeId,
            userUid: userUid,
            role: role,
            displayName: displayName,
            status: status,
            joinedAt: joinedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String storeId,
            required String userUid,
            required String role,
            required String displayName,
            required String status,
            required int joinedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              StoreMembershipsTableCompanion.insert(
            id: id,
            storeId: storeId,
            userUid: userUid,
            role: role,
            displayName: displayName,
            status: status,
            joinedAt: joinedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StoreMembershipsTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $StoreMembershipsTableTable,
        StoreMembershipsTableData,
        $$StoreMembershipsTableTableFilterComposer,
        $$StoreMembershipsTableTableOrderingComposer,
        $$StoreMembershipsTableTableAnnotationComposer,
        $$StoreMembershipsTableTableCreateCompanionBuilder,
        $$StoreMembershipsTableTableUpdateCompanionBuilder,
        (
          StoreMembershipsTableData,
          BaseReferences<_$AppDatabase, $StoreMembershipsTableTable,
              StoreMembershipsTableData>
        ),
        StoreMembershipsTableData,
        PrefetchHooks Function()>;
typedef $$StoreGroupsTableTableCreateCompanionBuilder
    = StoreGroupsTableCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  required String createdByUid,
  required int createdAt,
  Value<int> rowid,
});
typedef $$StoreGroupsTableTableUpdateCompanionBuilder
    = StoreGroupsTableCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String> createdByUid,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$StoreGroupsTableTableFilterComposer
    extends Composer<_$AppDatabase, $StoreGroupsTableTable> {
  $$StoreGroupsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdByUid => $composableBuilder(
      column: $table.createdByUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$StoreGroupsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StoreGroupsTableTable> {
  $$StoreGroupsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdByUid => $composableBuilder(
      column: $table.createdByUid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$StoreGroupsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoreGroupsTableTable> {
  $$StoreGroupsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get createdByUid => $composableBuilder(
      column: $table.createdByUid, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StoreGroupsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StoreGroupsTableTable,
    StoreGroupsTableData,
    $$StoreGroupsTableTableFilterComposer,
    $$StoreGroupsTableTableOrderingComposer,
    $$StoreGroupsTableTableAnnotationComposer,
    $$StoreGroupsTableTableCreateCompanionBuilder,
    $$StoreGroupsTableTableUpdateCompanionBuilder,
    (
      StoreGroupsTableData,
      BaseReferences<_$AppDatabase, $StoreGroupsTableTable,
          StoreGroupsTableData>
    ),
    StoreGroupsTableData,
    PrefetchHooks Function()> {
  $$StoreGroupsTableTableTableManager(
      _$AppDatabase db, $StoreGroupsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoreGroupsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoreGroupsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoreGroupsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> createdByUid = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StoreGroupsTableCompanion(
            id: id,
            name: name,
            description: description,
            createdByUid: createdByUid,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            required String createdByUid,
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              StoreGroupsTableCompanion.insert(
            id: id,
            name: name,
            description: description,
            createdByUid: createdByUid,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StoreGroupsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StoreGroupsTableTable,
    StoreGroupsTableData,
    $$StoreGroupsTableTableFilterComposer,
    $$StoreGroupsTableTableOrderingComposer,
    $$StoreGroupsTableTableAnnotationComposer,
    $$StoreGroupsTableTableCreateCompanionBuilder,
    $$StoreGroupsTableTableUpdateCompanionBuilder,
    (
      StoreGroupsTableData,
      BaseReferences<_$AppDatabase, $StoreGroupsTableTable,
          StoreGroupsTableData>
    ),
    StoreGroupsTableData,
    PrefetchHooks Function()>;
typedef $$StoreGroupMembersTableTableCreateCompanionBuilder
    = StoreGroupMembersTableCompanion Function({
  required String id,
  required String groupId,
  required String storeId,
  required int addedAt,
  required String addedByUid,
  Value<int> rowid,
});
typedef $$StoreGroupMembersTableTableUpdateCompanionBuilder
    = StoreGroupMembersTableCompanion Function({
  Value<String> id,
  Value<String> groupId,
  Value<String> storeId,
  Value<int> addedAt,
  Value<String> addedByUid,
  Value<int> rowid,
});

class $$StoreGroupMembersTableTableFilterComposer
    extends Composer<_$AppDatabase, $StoreGroupMembersTableTable> {
  $$StoreGroupMembersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storeId => $composableBuilder(
      column: $table.storeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get addedByUid => $composableBuilder(
      column: $table.addedByUid, builder: (column) => ColumnFilters(column));
}

class $$StoreGroupMembersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StoreGroupMembersTableTable> {
  $$StoreGroupMembersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storeId => $composableBuilder(
      column: $table.storeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get addedByUid => $composableBuilder(
      column: $table.addedByUid, builder: (column) => ColumnOrderings(column));
}

class $$StoreGroupMembersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoreGroupMembersTableTable> {
  $$StoreGroupMembersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<int> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<String> get addedByUid => $composableBuilder(
      column: $table.addedByUid, builder: (column) => column);
}

class $$StoreGroupMembersTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StoreGroupMembersTableTable,
    StoreGroupMembersTableData,
    $$StoreGroupMembersTableTableFilterComposer,
    $$StoreGroupMembersTableTableOrderingComposer,
    $$StoreGroupMembersTableTableAnnotationComposer,
    $$StoreGroupMembersTableTableCreateCompanionBuilder,
    $$StoreGroupMembersTableTableUpdateCompanionBuilder,
    (
      StoreGroupMembersTableData,
      BaseReferences<_$AppDatabase, $StoreGroupMembersTableTable,
          StoreGroupMembersTableData>
    ),
    StoreGroupMembersTableData,
    PrefetchHooks Function()> {
  $$StoreGroupMembersTableTableTableManager(
      _$AppDatabase db, $StoreGroupMembersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoreGroupMembersTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$StoreGroupMembersTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoreGroupMembersTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> storeId = const Value.absent(),
            Value<int> addedAt = const Value.absent(),
            Value<String> addedByUid = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StoreGroupMembersTableCompanion(
            id: id,
            groupId: groupId,
            storeId: storeId,
            addedAt: addedAt,
            addedByUid: addedByUid,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String groupId,
            required String storeId,
            required int addedAt,
            required String addedByUid,
            Value<int> rowid = const Value.absent(),
          }) =>
              StoreGroupMembersTableCompanion.insert(
            id: id,
            groupId: groupId,
            storeId: storeId,
            addedAt: addedAt,
            addedByUid: addedByUid,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StoreGroupMembersTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $StoreGroupMembersTableTable,
        StoreGroupMembersTableData,
        $$StoreGroupMembersTableTableFilterComposer,
        $$StoreGroupMembersTableTableOrderingComposer,
        $$StoreGroupMembersTableTableAnnotationComposer,
        $$StoreGroupMembersTableTableCreateCompanionBuilder,
        $$StoreGroupMembersTableTableUpdateCompanionBuilder,
        (
          StoreGroupMembersTableData,
          BaseReferences<_$AppDatabase, $StoreGroupMembersTableTable,
              StoreGroupMembersTableData>
        ),
        StoreGroupMembersTableData,
        PrefetchHooks Function()>;
typedef $$PlanogramProposalsTableTableCreateCompanionBuilder
    = PlanogramProposalsTableCompanion Function({
  required String id,
  required String planogramId,
  required String storeId,
  required String proposedByUid,
  required int proposedAt,
  required String status,
  Value<String?> notes,
  Value<String?> slotChanges,
  Value<String?> reviewedByUid,
  Value<int?> reviewedAt,
  Value<int> rowid,
});
typedef $$PlanogramProposalsTableTableUpdateCompanionBuilder
    = PlanogramProposalsTableCompanion Function({
  Value<String> id,
  Value<String> planogramId,
  Value<String> storeId,
  Value<String> proposedByUid,
  Value<int> proposedAt,
  Value<String> status,
  Value<String?> notes,
  Value<String?> slotChanges,
  Value<String?> reviewedByUid,
  Value<int?> reviewedAt,
  Value<int> rowid,
});

class $$PlanogramProposalsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlanogramProposalsTableTable> {
  $$PlanogramProposalsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get planogramId => $composableBuilder(
      column: $table.planogramId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storeId => $composableBuilder(
      column: $table.storeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get proposedByUid => $composableBuilder(
      column: $table.proposedByUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get proposedAt => $composableBuilder(
      column: $table.proposedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get slotChanges => $composableBuilder(
      column: $table.slotChanges, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reviewedByUid => $composableBuilder(
      column: $table.reviewedByUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => ColumnFilters(column));
}

class $$PlanogramProposalsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanogramProposalsTableTable> {
  $$PlanogramProposalsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get planogramId => $composableBuilder(
      column: $table.planogramId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storeId => $composableBuilder(
      column: $table.storeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get proposedByUid => $composableBuilder(
      column: $table.proposedByUid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get proposedAt => $composableBuilder(
      column: $table.proposedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get slotChanges => $composableBuilder(
      column: $table.slotChanges, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reviewedByUid => $composableBuilder(
      column: $table.reviewedByUid,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => ColumnOrderings(column));
}

class $$PlanogramProposalsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanogramProposalsTableTable> {
  $$PlanogramProposalsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get planogramId => $composableBuilder(
      column: $table.planogramId, builder: (column) => column);

  GeneratedColumn<String> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get proposedByUid => $composableBuilder(
      column: $table.proposedByUid, builder: (column) => column);

  GeneratedColumn<int> get proposedAt => $composableBuilder(
      column: $table.proposedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get slotChanges => $composableBuilder(
      column: $table.slotChanges, builder: (column) => column);

  GeneratedColumn<String> get reviewedByUid => $composableBuilder(
      column: $table.reviewedByUid, builder: (column) => column);

  GeneratedColumn<int> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => column);
}

class $$PlanogramProposalsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlanogramProposalsTableTable,
    PlanogramProposalsTableData,
    $$PlanogramProposalsTableTableFilterComposer,
    $$PlanogramProposalsTableTableOrderingComposer,
    $$PlanogramProposalsTableTableAnnotationComposer,
    $$PlanogramProposalsTableTableCreateCompanionBuilder,
    $$PlanogramProposalsTableTableUpdateCompanionBuilder,
    (
      PlanogramProposalsTableData,
      BaseReferences<_$AppDatabase, $PlanogramProposalsTableTable,
          PlanogramProposalsTableData>
    ),
    PlanogramProposalsTableData,
    PrefetchHooks Function()> {
  $$PlanogramProposalsTableTableTableManager(
      _$AppDatabase db, $PlanogramProposalsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanogramProposalsTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanogramProposalsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanogramProposalsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> planogramId = const Value.absent(),
            Value<String> storeId = const Value.absent(),
            Value<String> proposedByUid = const Value.absent(),
            Value<int> proposedAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> slotChanges = const Value.absent(),
            Value<String?> reviewedByUid = const Value.absent(),
            Value<int?> reviewedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanogramProposalsTableCompanion(
            id: id,
            planogramId: planogramId,
            storeId: storeId,
            proposedByUid: proposedByUid,
            proposedAt: proposedAt,
            status: status,
            notes: notes,
            slotChanges: slotChanges,
            reviewedByUid: reviewedByUid,
            reviewedAt: reviewedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String planogramId,
            required String storeId,
            required String proposedByUid,
            required int proposedAt,
            required String status,
            Value<String?> notes = const Value.absent(),
            Value<String?> slotChanges = const Value.absent(),
            Value<String?> reviewedByUid = const Value.absent(),
            Value<int?> reviewedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanogramProposalsTableCompanion.insert(
            id: id,
            planogramId: planogramId,
            storeId: storeId,
            proposedByUid: proposedByUid,
            proposedAt: proposedAt,
            status: status,
            notes: notes,
            slotChanges: slotChanges,
            reviewedByUid: reviewedByUid,
            reviewedAt: reviewedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlanogramProposalsTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $PlanogramProposalsTableTable,
        PlanogramProposalsTableData,
        $$PlanogramProposalsTableTableFilterComposer,
        $$PlanogramProposalsTableTableOrderingComposer,
        $$PlanogramProposalsTableTableAnnotationComposer,
        $$PlanogramProposalsTableTableCreateCompanionBuilder,
        $$PlanogramProposalsTableTableUpdateCompanionBuilder,
        (
          PlanogramProposalsTableData,
          BaseReferences<_$AppDatabase, $PlanogramProposalsTableTable,
              PlanogramProposalsTableData>
        ),
        PlanogramProposalsTableData,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ZonesTableTableTableManager get zonesTable =>
      $$ZonesTableTableTableManager(_db, _db.zonesTable);
  $$FixturesTableTableTableManager get fixturesTable =>
      $$FixturesTableTableTableManager(_db, _db.fixturesTable);
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db, _db.productsTable);
  $$PlanogramsTableTableTableManager get planogramsTable =>
      $$PlanogramsTableTableTableManager(_db, _db.planogramsTable);
  $$PhotoDocsTableTableTableManager get photoDocsTable =>
      $$PhotoDocsTableTableTableManager(_db, _db.photoDocsTable);
  $$StoresTableTableTableManager get storesTable =>
      $$StoresTableTableTableManager(_db, _db.storesTable);
  $$StoreMembershipsTableTableTableManager get storeMembershipsTable =>
      $$StoreMembershipsTableTableTableManager(_db, _db.storeMembershipsTable);
  $$StoreGroupsTableTableTableManager get storeGroupsTable =>
      $$StoreGroupsTableTableTableManager(_db, _db.storeGroupsTable);
  $$StoreGroupMembersTableTableTableManager get storeGroupMembersTable =>
      $$StoreGroupMembersTableTableTableManager(
          _db, _db.storeGroupMembersTable);
  $$PlanogramProposalsTableTableTableManager get planogramProposalsTable =>
      $$PlanogramProposalsTableTableTableManager(
          _db, _db.planogramProposalsTable);
}
