import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../models/schematic_project.dart';
import '../services/pdf_export_service.dart';
import '../theme/app_theme.dart';

class ExportScreen extends StatefulWidget {
  final SchematicProject project;

  const ExportScreen({super.key, required this.project});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final _service = PdfExportService();
  bool _generating = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    try {
      await _service.exportProject(widget.project);
      if (mounted) setState(() => _generating = false);
    } catch (e) {
      if (mounted) setState(() {
        _generating = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export PDF'),
        actions: [
          if (!_generating && _error == null)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Share',
              onPressed: _share,
            ),
        ],
      ),
      body: _generating
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating PDF...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      const Text('Export failed'),
                      const SizedBox(height: 6),
                      Text(_error!,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            _generating = true;
                            _error = null;
                          });
                          _generate();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : PdfPreview(
                  build: (_) => _service.exportProject(widget.project),
                  allowPrinting: true,
                  allowSharing: true,
                  canChangePageFormat: false,
                  pdfFileName:
                      '${widget.project.name.replaceAll(' ', '_')}.pdf',
                  actions: [
                    PdfPreviewAction(
                      icon: const Icon(Icons.download_outlined),
                      onPressed: (ctx, fn, fmt) async {
                        final bytes = await fn(fmt);
                        if (bytes != null && ctx.mounted) {
                          await Printing.sharePdf(
                            bytes: bytes,
                            filename:
                                '${widget.project.name.replaceAll(' ', '_')}.pdf',
                          );
                        }
                      },
                    ),
                  ],
                ),
    );
  }

  Future<void> _share() async {
    final bytes = await _service.exportProject(widget.project);
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${widget.project.name.replaceAll(' ', '_')}.pdf',
    );
  }
}
