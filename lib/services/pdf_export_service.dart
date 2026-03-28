import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/schematic_project.dart';
import '../models/display_section.dart';
import '../models/garment_item.dart';
import '../models/garment_type.dart';
import '../models/mannequin_look.dart';
import '../models/color_variant.dart';
import '../models/decorative_element.dart';

class PdfExportService {
  static const _pageFormat = PdfPageFormat.letter;

  Future<Uint8List> exportProject(SchematicProject project) async {
    final pdf = pw.Document(
      title: project.name,
      author: project.storeName ?? 'Merch Mobile',
    );

    // Cover page
    pdf.addPage(_buildCoverPage(project));

    // One page per section
    for (final section in project.sections) {
      pdf.addPage(_buildSectionPage(project, section));
    }

    return pdf.save();
  }

  pw.Page _buildCoverPage(SchematicProject project) {
    return pw.Page(
      pageFormat: _pageFormat,
      margin: const pw.EdgeInsets.all(40),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Spacer(),
          pw.Text(
            project.name,
            style: pw.TextStyle(
              fontSize: 32,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (project.storeName != null)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 8),
              child: pw.Text(
                project.storeName!,
                style: pw.TextStyle(fontSize: 16, color: PdfColors.grey600),
              ),
            ),
          pw.Divider(height: 40, color: PdfColors.grey300),
          pw.Text(
            '${project.sections.length} Section${project.sections.length == 1 ? '' : 's'}',
            style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
          ),
          ...project.sections.map((s) => pw.Padding(
                padding: const pw.EdgeInsets.only(top: 6),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 6,
                      height: 6,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey400,
                        shape: pw.BoxShape.circle,
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      '${s.title} · ${s.garments.length} product${s.garments.length == 1 ? '' : 's'}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              )),
          pw.Spacer(flex: 3),
          pw.Text(
            'Created with Merch Mobile',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey400),
          ),
        ],
      ),
    );
  }

  pw.Page _buildSectionPage(SchematicProject project, DisplaySection section) {
    return pw.Page(
      pageFormat: _pageFormat,
      margin: const pw.EdgeInsets.all(32),
      build: (ctx) {
        final pageWidth = _pageFormat.width - 64;
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Section title
            pw.Text(
              section.title,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            if (project.storeName != null)
              pw.Text(
                project.storeName!,
                style: const pw.TextStyle(
                    fontSize: 10, color: PdfColors.grey500),
              ),
            pw.SizedBox(height: 16),

            // Section content
            pw.Expanded(
              child: pw.Container(
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                ),
                padding: const pw.EdgeInsets.all(16),
                child: _buildSectionContent(section, pageWidth - 32),
              ),
            ),

            pw.SizedBox(height: 8),

            // Footer
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  section.type.displayName.toUpperCase(),
                  style: pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey400),
                ),
                pw.Text(
                  '${project.sections.indexOf(section) + 1} / ${project.sections.length}',
                  style: const pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey400),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  pw.Widget _buildSectionContent(DisplaySection section, double width) {
    return switch (section.type) {
      SectionType.table => _buildTableContent(section, width),
      SectionType.perimeter => _buildWallContent(section, width),
      SectionType.floorRack => _buildRackContent(section, width),
    };
  }

  // ── Table section ─────────────────────────────────────────────────────────

  pw.Widget _buildTableContent(DisplaySection section, double width) {
    final sorted = _sortByTablePriority(section.garments);

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Left: product grids
        pw.Expanded(
          flex: 3,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: sorted
                .map((g) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 12),
                      child: _buildColorwayGrid(g),
                    ))
                .toList(),
          ),
        ),

        // Right: mannequin look
        if (section.mannequinLook != null &&
            section.mannequinLook!.items.isNotEmpty) ...[
          pw.SizedBox(width: 16),
          pw.SizedBox(
            width: 140,
            child: _buildMannequinPanel(section.mannequinLook!),
          ),
        ],
      ],
    );
  }

  pw.Widget _buildColorwayGrid(GarmentItem garment) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: garment.isFeatured ? PdfColors.red : PdfColors.grey400,
          width: garment.isFeatured ? 1.5 : 0.5,
        ),
      ),
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        children: [
          // Colorway swatches row
          pw.Wrap(
            spacing: 8,
            runSpacing: 4,
            children: garment.colorways.map((cv) {
              return pw.Column(
                children: [
                  _pdfGarmentBox(cv, 50, 50),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    cv.name,
                    style: pw.TextStyle(
                        fontSize: 6,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey600),
                  ),
                ],
              );
            }).toList(),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            garment.name.toUpperCase(),
            style: pw.TextStyle(
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfGarmentBox(ColorVariant cv, double w, double h) {
    final pdfColor = _toPdfColor(cv.color);
    return pw.Container(
      width: w,
      height: h,
      color: pdfColor,
      child: pw.Center(
        child: pw.Container(
          width: w * 0.7,
          height: h * 0.7,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
                color: _strokeColor(pdfColor), width: 0.5),
          ),
        ),
      ),
    );
  }

  // ── Wall section ──────────────────────────────────────────────────────────

  pw.Widget _buildWallContent(DisplaySection section, double width) {
    final shelfItems = section.garments
        .where((g) => g.type.suggestedPosition == 'shelf')
        .toList();
    final upperItems = section.garments
        .where((g) => g.type.suggestedPosition == 'upper_rod')
        .toList();
    final lowerItems = section.garments
        .where((g) =>
            g.type.suggestedPosition == 'mid_rod' ||
            g.type.suggestedPosition == 'lower_rod')
        .toList();

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (shelfItems.isNotEmpty) ...[
                _sectionLabel('TOP SHELF'),
                pw.SizedBox(height: 4),
                pw.Wrap(
                  spacing: 8,
                  children: shelfItems.map((g) => _garmentLabel(g)).toList(),
                ),
                pw.SizedBox(height: 12),
              ],
              if (upperItems.isNotEmpty) ...[
                _sectionLabel('UPPER ROD · Face-out: ${section.faceOutCount}'),
                pw.SizedBox(height: 4),
                pw.Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: upperItems.map((g) => _hangingItem(g)).toList(),
                ),
                pw.SizedBox(height: 12),
              ],
              if (lowerItems.isNotEmpty) ...[
                _sectionLabel('LOWER ROD · U-bar: ${section.uBarCount}'),
                pw.SizedBox(height: 4),
                pw.Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: lowerItems.map((g) => _hangingItem(g)).toList(),
                ),
              ],
            ],
          ),
        ),
        if (section.mannequinLook != null &&
            section.mannequinLook!.items.isNotEmpty) ...[
          pw.SizedBox(width: 12),
          pw.SizedBox(
            width: 120,
            child: _buildMannequinPanel(section.mannequinLook!),
          ),
        ],
      ],
    );
  }

  pw.Widget _garmentLabel(GarmentItem g) {
    final color = g.colorways.isNotEmpty
        ? _toPdfColor(g.colorways.first.color)
        : PdfColors.grey400;
    return pw.Column(
      children: [
        pw.Container(
          width: 40,
          height: 40,
          color: color,
        ),
        pw.Text(g.name, style: const pw.TextStyle(fontSize: 6)),
      ],
    );
  }

  pw.Widget _hangingItem(GarmentItem g) {
    final color = g.colorways.isNotEmpty
        ? _toPdfColor(g.colorways.first.color)
        : PdfColors.grey400;
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
      ),
      padding: const pw.EdgeInsets.all(6),
      child: pw.Column(
        children: [
          pw.Container(width: 44, height: 52, color: color),
          pw.SizedBox(height: 3),
          pw.SizedBox(
            width: 50,
            child: pw.Text(
              g.name,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 6, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Rack section ──────────────────────────────────────────────────────────

  pw.Widget _buildRackContent(DisplaySection section, double width) {
    final upper = section.garments.take(4).toList();
    final lower = section.garments.skip(4).take(4).toList();

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _sectionLabel('UPPER CROSSBAR · Face-out: ${section.faceOutCount}'),
              pw.SizedBox(height: 6),
              pw.Wrap(
                spacing: 8,
                children: upper.map((g) => _hangingItem(g)).toList(),
              ),
              if (lower.isNotEmpty) ...[
                pw.SizedBox(height: 12),
                _sectionLabel('LOWER CROSSBAR · U-bar: ${section.uBarCount}'),
                pw.SizedBox(height: 6),
                pw.Wrap(
                  spacing: 8,
                  children: lower.map((g) => _hangingItem(g)).toList(),
                ),
              ],
            ],
          ),
        ),
        if (section.mannequinLook != null &&
            section.mannequinLook!.items.isNotEmpty) ...[
          pw.SizedBox(width: 12),
          pw.SizedBox(
            width: 120,
            child: _buildMannequinPanel(section.mannequinLook!),
          ),
        ],
      ],
    );
  }

  // ── Shared ────────────────────────────────────────────────────────────────

  pw.Widget _buildMannequinPanel(MannequinLook look) {
    final topColor = look.items.isNotEmpty
        ? _toPdfColor(look.items.first.colorVariant.color)
        : PdfColors.lightBlue200;
    final bottomColor = look.items.length > 1
        ? _toPdfColor(look.items[1].colorVariant.color)
        : PdfColors.grey800;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Simple mannequin rectangle stand-in
        pw.Center(
          child: pw.Column(
            children: [
              // Head
              pw.Container(
                width: 20,
                height: 22,
                decoration: pw.BoxDecoration(
                  color: PdfColors.lightBlue200,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
              ),
              pw.SizedBox(height: 2),
              // Torso
              pw.Container(width: 48, height: 50, color: topColor),
              // Legs
              pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Container(width: 20, height: 60, color: bottomColor),
                  pw.SizedBox(width: 4),
                  pw.Container(width: 20, height: 60, color: bottomColor),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'MANNEQUIN LOOK',
          style: pw.TextStyle(
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.red,
          ),
        ),
        pw.SizedBox(height: 4),
        ...look.items.map((item) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: '• ${item.productName} – ',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.TextSpan(
                      text: item.colorVariant.name,
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red,
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  pw.Widget _sectionLabel(String label) {
    return pw.Text(
      label,
      style: pw.TextStyle(
        fontSize: 7,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.grey600,
        letterSpacing: 0.5,
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  PdfColor _toPdfColor(dynamic color) {
    // color is a Flutter Color (int value)
    final v = color is int ? color : (color?.value ?? 0xFF888888);
    final r = ((v >> 16) & 0xFF) / 255.0;
    final g = ((v >> 8) & 0xFF) / 255.0;
    final b = (v & 0xFF) / 255.0;
    return PdfColor(r, g, b);
  }

  PdfColor _strokeColor(PdfColor fill) {
    final lum = 0.299 * fill.red + 0.587 * fill.green + 0.114 * fill.blue;
    return lum > 0.85 ? PdfColors.grey600 : PdfColors.grey300;
  }

  List<GarmentItem> _sortByTablePriority(List<GarmentItem> items) {
    const order = [
      GarmentType.hoodie,
      GarmentType.halfZip,
      GarmentType.quarterZip,
      GarmentType.tshirt,
      GarmentType.pants,
      GarmentType.jogger,
      GarmentType.shorts,
    ];
    final sorted = [...items];
    sorted.sort((a, b) {
      final ai = order.indexOf(a.type);
      final bi = order.indexOf(b.type);
      return (ai == -1 ? 999 : ai).compareTo(bi == -1 ? 999 : bi);
    });
    return sorted;
  }
}
