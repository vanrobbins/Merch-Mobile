import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import 'photo_provider.dart';

class PhotoCaptureButton extends ConsumerStatefulWidget {
  const PhotoCaptureButton({
    super.key,
    required this.fixtureId,
    required this.phase,
  });

  final String fixtureId;
  final String phase;

  @override
  ConsumerState<PhotoCaptureButton> createState() =>
      _PhotoCaptureButtonState();
}

class _PhotoCaptureButtonState extends ConsumerState<PhotoCaptureButton>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: DesignTokens.durationMed,
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  bool _hasPendingUploads(PhotoState state) {
    return state.photos.any(
      (p) => p.uploadStatus == 'pending',
    );
  }

  Future<void> _captureCamera() async {
    _toggle();
    await ref
        .read(photoNotifierProvider.notifier)
        .capturePhoto(widget.fixtureId, widget.phase);
  }

  Future<void> _pickGallery() async {
    _toggle();
    await ref
        .read(photoNotifierProvider.notifier)
        .pickFromGallery(widget.fixtureId, widget.phase);
  }

  @override
  Widget build(BuildContext context) {
    final photoAsync = ref.watch(photoNotifierProvider);
    final hasPending = photoAsync.when(
      data: (s) => _hasPendingUploads(s),
      loading: () => false,
      error: (_, __) => false,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Mini FABs
        ScaleTransition(
          scale: _scaleAnim,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MiniFab(
                label: 'GALLERY',
                icon: Icons.photo_library_outlined,
                onTap: _pickGallery,
              ),
              const SizedBox(height: DesignTokens.spaceSm),
              _MiniFab(
                label: 'CAMERA',
                icon: Icons.camera_alt_outlined,
                onTap: _captureCamera,
              ),
              const SizedBox(height: DesignTokens.spaceSm),
            ],
          ),
        ),
        // Main FAB
        Stack(
          alignment: Alignment.center,
          children: [
            FloatingActionButton(
              onPressed: _toggle,
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              child: AnimatedRotation(
                turns: _expanded ? 0.125 : 0,
                duration: DesignTokens.durationMed,
                child: const Icon(Icons.add_a_photo),
              ),
            ),
            if (hasPending)
              Positioned.fill(
                child: IgnorePointer(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white.withAlpha(180)),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MiniFab extends StatelessWidget {
  const _MiniFab({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceSm,
            vertical: DesignTokens.spaceXs,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: DesignTokens.typeXs,
              fontWeight: DesignTokens.weightBold,
              letterSpacing: DesignTokens.letterSpacingEyebrow,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: DesignTokens.spaceSm),
        FloatingActionButton.small(
          heroTag: label,
          onPressed: onTap,
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          child: Icon(icon),
        ),
      ],
    );
  }
}
