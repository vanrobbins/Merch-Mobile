import 'dart:convert';

/// A row in a planogram (wall/shelf/rack/table).
/// Stored as JSON in [Planogram.rowsJson].
class PgRow {
  final int index;
  final String rowType; // 'bar' | 'shelf'
  final String? label;

  const PgRow({
    required this.index,
    this.rowType = 'bar',
    this.label,
  });

  PgRow copyWith({String? rowType, String? label}) => PgRow(
        index: index,
        rowType: rowType ?? this.rowType,
        label: label ?? this.label,
      );

  Map<String, dynamic> toJson() => {
        'index': index,
        'rowType': rowType,
        if (label != null) 'label': label,
      };

  factory PgRow.fromJson(Map<String, dynamic> json) => PgRow(
        index: json['index'] as int,
        rowType: json['rowType'] as String? ?? 'bar',
        label: json['label'] as String?,
      );

  static String encodeList(List<PgRow> rows) =>
      jsonEncode(rows.map((r) => r.toJson()).toList());

  static List<PgRow> decodeList(String json) {
    if (json.isEmpty || json == '[]') return [];
    final list = jsonDecode(json) as List;
    return list
        .map((e) => PgRow.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Default rows for a new planogram.
  /// Wall/shelf/rack default to 'bar'. Table defaults to 'shelf'.
  static List<PgRow> defaults(int count, String planogramType) =>
      List.generate(
        count,
        (i) => PgRow(
          index: i,
          rowType: planogramType == 'table' ? 'shelf' : 'bar',
        ),
      );
}
