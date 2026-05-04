import 'package:flutter/material.dart';
import 'planogram_detail_screen.dart';

/// Thin wrapper that opens [PlanogramDetailScreen] directly in edit mode.
/// Registered at `planogramEdit` route so deep-links can land in edit mode
/// without requiring the user to press the EDIT button manually.
class PlanogramEditorScreen extends StatelessWidget {
  const PlanogramEditorScreen({super.key, required this.planogramId});
  final String planogramId;

  @override
  Widget build(BuildContext context) {
    // PlanogramDetailScreen contains all edit logic internally.
    // We surface it here so the router can reach it via a separate path.
    return PlanogramDetailScreen(planogramId: planogramId);
  }
}
