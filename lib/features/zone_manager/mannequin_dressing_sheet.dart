import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/models/mannequin.dart';
import '../../core/models/mannequin_outfit_proposal.dart';
import '../../core/models/mannequin_outfit_slot.dart';
import '../../core/models/product.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/firestore_refs.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';

// ---------------------------------------------------------------------------
// Public entry point
// ---------------------------------------------------------------------------

void showMannequinDressingSheet(
    BuildContext context, Mannequin mannequin, String storeId) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        MannequinDressingSheet(mannequin: mannequin, storeId: storeId),
  );
}

// ---------------------------------------------------------------------------
// Slot definitions per mannequin type
// ---------------------------------------------------------------------------

const _slotsForType = <String, List<String>>{
  'full_body': [
    'head',
    'torso',
    'legs',
    'feet',
    'left_hand',
    'right_hand',
    'accessory_1',
    'accessory_2',
  ],
  'half_body': [
    'torso',
    'left_hand',
    'right_hand',
    'accessory_1',
    'accessory_2',
  ],
  'torso': ['torso', 'accessory_1', 'accessory_2'],
  'leg_form': ['legs', 'feet'],
  'bra_form': ['torso'],
};

const _silhouetteAsset = <String, String>{
  'full_body': 'assets/silhouettes/dress.svg',
  'half_body': 'assets/silhouettes/shirt_ss.svg',
  'torso': 'assets/silhouettes/tank_top.svg',
  'leg_form': 'assets/silhouettes/pant.svg',
  'bra_form': 'assets/silhouettes/bra.svg',
};

const _slotIcon = <String, IconData>{
  'head': Icons.face_outlined,
  'torso': Icons.dry_outlined,
  'legs': Icons.straighten_outlined,
  'feet': Icons.directions_walk_outlined,
  'left_hand': Icons.back_hand_outlined,
  'right_hand': Icons.front_hand_outlined,
  'accessory_1': Icons.watch_outlined,
  'accessory_2': Icons.style_outlined,
};

String _slotLabel(String slot) =>
    slot.replaceAll('_', ' ').toUpperCase();

// ---------------------------------------------------------------------------
// Sheet widget
// ---------------------------------------------------------------------------

class MannequinDressingSheet extends ConsumerStatefulWidget {
  const MannequinDressingSheet({
    super.key,
    required this.mannequin,
    required this.storeId,
  });

  final Mannequin mannequin;
  final String storeId;

  @override
  ConsumerState<MannequinDressingSheet> createState() =>
      _MannequinDressingSheetState();
}

class _MannequinDressingSheetState
    extends ConsumerState<MannequinDressingSheet> {
  late TextEditingController _outfitNameCtrl;
  late TextEditingController _outfitNotesCtrl;

  /// slot -> productId (nullable = unassigned)
  final Map<String, String?> _slotProductMap = {};

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _outfitNameCtrl =
        TextEditingController(text: widget.mannequin.outfitName ?? '');
    _outfitNotesCtrl =
        TextEditingController(text: widget.mannequin.outfitNotes ?? '');
  }

  @override
  void dispose() {
    _outfitNameCtrl.dispose();
    _outfitNotesCtrl.dispose();
    super.dispose();
  }

  List<String> get _slots =>
      _slotsForType[widget.mannequin.mannequinType] ??
      _slotsForType['full_body']!;

  void _applyExistingSlots(List<MannequinOutfitSlot> slots) {
    // Only seed once — don't overwrite edits in progress.
    for (final s in slots) {
      _slotProductMap.putIfAbsent(s.bodySlot, () => s.productId);
    }
  }

  Future<void> _save(String role) async {
    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      if (role == 'coordinator' || role == 'manager') {
        await _saveDirectly();
      } else {
        await _submitProposal(user);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveDirectly() async {
    final batch = FirebaseFirestore.instance.batch();

    // Delete old outfit slots.
    final oldDocs = await FirestoreRefs.mannequinOutfitSlots(
            widget.storeId, widget.mannequin.id)
        .get();
    for (final doc in oldDocs.docs) {
      batch.delete(doc.reference);
    }

    // Set new slots.
    for (final entry in _slotProductMap.entries) {
      if (entry.value != null) {
        final ref = FirestoreRefs.mannequinOutfitSlots(
                widget.storeId, widget.mannequin.id)
            .doc();
        batch.set(
          ref,
          MannequinOutfitSlot(
            id: ref.id,
            mannequinId: widget.mannequin.id,
            bodySlot: entry.key,
            productId: entry.value,
            updatedAt: DateTime.now(),
          ).toFirestore(),
        );
      }
    }

    // Update mannequin outfitName / outfitNotes.
    final outfitName = _outfitNameCtrl.text.trim();
    final outfitNotes = _outfitNotesCtrl.text.trim();
    batch.update(
        FirestoreRefs.mannequin(widget.storeId, widget.mannequin.id), {
      'outfitName': outfitName.isEmpty ? null : outfitName,
      'outfitNotes': outfitNotes.isEmpty ? null : outfitNotes,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    await batch.commit();
  }

  Future<void> _submitProposal(User user) async {
    final outfitNotes = _outfitNotesCtrl.text.trim();
    final slotChangesJson = jsonEncode(_slotProductMap.entries
        .where((e) => e.value != null)
        .map((e) => {'bodySlot': e.key, 'productId': e.value})
        .toList());

    final ref = FirestoreRefs.mannequinProposals(widget.storeId).doc();
    await ref.set(MannequinOutfitProposal(
      id: ref.id,
      mannequinId: widget.mannequin.id,
      storeId: widget.storeId,
      proposedByUid: user.uid,
      proposedByName: user.displayName ?? 'Staff',
      proposedAt: DateTime.now(),
      status: 'pending',
      slotChanges: slotChangesJson,
      notes: outfitNotes.isEmpty ? null : outfitNotes,
    ).toFirestore());
  }

  @override
  Widget build(BuildContext context) {
    final membership = ref.watch(currentMembershipProvider).value;
    final role = membership?.role ?? 'staff';
    final isManager = role == 'coordinator' || role == 'manager';

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (sheetContext, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.canvasBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirestoreRefs.mannequinOutfitSlots(
                    widget.storeId, widget.mannequin.id)
                .snapshots(),
            builder: (context, snap) {
              if (snap.hasData) {
                final loaded = snap.data!.docs
                    .map(MannequinOutfitSlot.fromDoc)
                    .toList();
                _applyExistingSlots(loaded);
              }

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirestoreRefs.products(widget.storeId).snapshots(),
                builder: (context, prodSnap) {
                  final products = prodSnap.data?.docs
                          .map(ProductFirestore.fromDoc)
                          .toList() ??
                      [];

                  return Column(
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.divider,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          DesignTokens.spaceMd,
                          DesignTokens.spaceSm,
                          DesignTokens.spaceMd,
                          0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'DRESS MANNEQUIN',
                                    style: TextStyle(
                                      fontSize: DesignTokens.typeXs,
                                      fontWeight: DesignTokens.weightBold,
                                      letterSpacing:
                                          DesignTokens.letterSpacingEyebrow,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: DesignTokens.spaceXs),
                                  Text(
                                    widget.mannequin.name?.isNotEmpty == true
                                        ? widget.mannequin.name!
                                        : widget.mannequin.mannequinType
                                            .replaceAll('_', ' ')
                                            .toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: DesignTokens.typeLg,
                                      fontWeight: DesignTokens.weightBold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Body
                      Expanded(
                        child: ListView(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.all(DesignTokens.spaceMd),
                          children: [
                            _buildSilhouetteAndName(),
                            const SizedBox(height: DesignTokens.spaceMd),
                            _buildSlotList(products),
                            const SizedBox(height: DesignTokens.spaceLg),
                            _buildNotesField(),
                            const SizedBox(height: DesignTokens.spaceLg),
                            _buildSaveButton(role, isManager),
                            const SizedBox(height: DesignTokens.spaceLg),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSilhouetteAndName() {
    final assetPath = _silhouetteAsset[widget.mannequin.mannequinType];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Silhouette
        Container(
          width: 88,
          height: 132,
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: assetPath != null
              ? _SilhouetteImage(assetPath: assetPath)
              : const Icon(
                  Icons.accessibility_new_outlined,
                  size: 48,
                  color: AppTheme.textHint,
                ),
        ),
        const SizedBox(width: DesignTokens.spaceMd),
        Expanded(
          child: TextField(
            controller: _outfitNameCtrl,
            decoration: InputDecoration(
              labelText: 'OUTFIT NAME',
              labelStyle: const TextStyle(
                fontSize: DesignTokens.typeXs,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
                color: AppTheme.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadius),
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlotList(List<Product> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OUTFIT SLOTS',
          style: TextStyle(
            fontSize: DesignTokens.typeXs,
            fontWeight: DesignTokens.weightBold,
            letterSpacing: DesignTokens.letterSpacingEyebrow,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: DesignTokens.spaceSm),
        ..._slots.map((slot) => _SlotRow(
              slot: slot,
              productId: _slotProductMap[slot],
              products: products,
              onPick: (pid) => setState(() => _slotProductMap[slot] = pid),
            )),
      ],
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _outfitNotesCtrl,
      decoration: InputDecoration(
        labelText: 'NOTES',
        labelStyle: const TextStyle(
          fontSize: DesignTokens.typeXs,
          fontWeight: DesignTokens.weightBold,
          letterSpacing: DesignTokens.letterSpacingEyebrow,
          color: AppTheme.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        alignLabelWithHint: true,
        isDense: true,
      ),
      maxLines: 3,
      minLines: 2,
    );
  }

  Widget _buildSaveButton(String role, bool isManager) {
    return ElevatedButton(
      onPressed: _isSaving ? null : () => _save(role),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(AppTheme.borderRadius)),
        ),
      ),
      child: _isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
          : Text(
              isManager ? 'SAVE OUTFIT' : 'SUBMIT PROPOSAL',
              style: const TextStyle(
                fontWeight: DesignTokens.weightBold,
                letterSpacing: DesignTokens.letterSpacingEyebrow,
              ),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Silhouette image with fallback
// ---------------------------------------------------------------------------

class _SilhouetteImage extends StatelessWidget {
  const _SilhouetteImage({required this.assetPath});
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      fit: BoxFit.contain,
      placeholderBuilder: (_) => const Icon(
        Icons.accessibility_new_outlined,
        size: 48,
        color: AppTheme.textHint,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slot row
// ---------------------------------------------------------------------------

class _SlotRow extends StatelessWidget {
  const _SlotRow({
    required this.slot,
    required this.productId,
    required this.products,
    required this.onPick,
  });

  final String slot;
  final String? productId;
  final List<Product> products;
  final void Function(String?) onPick;

  Product? get _assigned =>
      productId != null ? products.where((p) => p.id == productId).firstOrNull : null;

  @override
  Widget build(BuildContext context) {
    final product = _assigned;
    final icon = _slotIcon[slot] ?? Icons.check_box_outline_blank;

    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spaceXs),
      child: Row(
        children: [
          Icon(icon, size: DesignTokens.iconSm, color: AppTheme.textSecondary),
          const SizedBox(width: DesignTokens.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _slotLabel(slot),
                  style: const TextStyle(
                    fontSize: DesignTokens.typeXs,
                    fontWeight: DesignTokens.weightBold,
                    letterSpacing: DesignTokens.letterSpacingEyebrow,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (product != null)
                  Text(
                    '${product.sku} — ${product.name}',
                    style: const TextStyle(
                      fontSize: DesignTokens.typeSm,
                      color: AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  const Text(
                    'Unassigned',
                    style: TextStyle(
                      fontSize: DesignTokens.typeSm,
                      color: AppTheme.textHint,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: DesignTokens.spaceXs),
          OutlinedButton(
            onPressed: () => _showProductPicker(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.accent,
              side: const BorderSide(color: AppTheme.accent),
              padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceSm),
              minimumSize: const Size(0, 32),
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(AppTheme.borderRadius)),
              ),
            ),
            child: Text(
              product != null ? 'CHANGE' : 'ASSIGN',
              style: const TextStyle(
                fontSize: DesignTokens.typeXs,
                fontWeight: DesignTokens.weightBold,
                letterSpacing: 1.0,
              ),
            ),
          ),
          if (product != null) ...[
            const SizedBox(width: DesignTokens.spaceXs),
            GestureDetector(
              onTap: () => onPick(null),
              child: const Icon(Icons.close,
                  size: DesignTokens.iconSm, color: AppTheme.textHint),
            ),
          ],
        ],
      ),
    );
  }

  void _showProductPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductPickerSheet(
        slot: slot,
        products: products,
        currentProductId: productId,
        onPick: (pid) {
          onPick(pid);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Product picker bottom sheet
// ---------------------------------------------------------------------------

class _ProductPickerSheet extends StatefulWidget {
  const _ProductPickerSheet({
    required this.slot,
    required this.products,
    required this.currentProductId,
    required this.onPick,
  });

  final String slot;
  final List<Product> products;
  final String? currentProductId;
  final void Function(String?) onPick;

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Product> get _filtered {
    final query = _query.toLowerCase();
    return widget.products.where((p) {
      if (query.isEmpty) return true;
      return p.name.toLowerCase().contains(query) ||
          p.sku.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.canvasBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DesignTokens.spaceMd,
                  DesignTokens.spaceSm,
                  DesignTokens.spaceMd,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ASSIGN PRODUCT — ${_slotLabel(widget.slot)}',
                      style: const TextStyle(
                        fontSize: DesignTokens.typeXs,
                        fontWeight: DesignTokens.weightBold,
                        letterSpacing: DesignTokens.letterSpacingEyebrow,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceSm),
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search products…',
                        prefixIcon:
                            const Icon(Icons.search, size: DesignTokens.iconMd),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadius),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.spaceXs),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  children: [
                    if (widget.currentProductId != null)
                      ListTile(
                        leading: const Icon(Icons.remove_circle_outline,
                            color: AppTheme.errorColor),
                        title: const Text(
                          'Remove assignment',
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                        onTap: () => widget.onPick(null),
                      ),
                    ..._filtered.map((p) {
                      final isSelected = p.id == widget.currentProductId;
                      return ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.accent
                                : AppTheme.accent.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppTheme.borderRadius),
                          ),
                          child: Icon(
                            Icons.checkroom_outlined,
                            color: isSelected ? Colors.white : AppTheme.accent,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          p.name,
                          style: TextStyle(
                            fontWeight: DesignTokens.weightBold,
                            color: isSelected ? AppTheme.accent : null,
                          ),
                        ),
                        subtitle: Text(
                          '${p.sku} · ${p.category}',
                          style: const TextStyle(
                              fontSize: DesignTokens.typeSm),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: AppTheme.accent)
                            : null,
                        onTap: () => widget.onPick(p.id),
                      );
                    }),
                    if (_filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(DesignTokens.spaceLg),
                        child: Center(
                          child: Text(
                            'No products found',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
