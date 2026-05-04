import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/models/photo_doc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_button.dart';
import '../../core/widgets/mm_empty_state.dart';
import '../../core/widgets/role_guard.dart';
import 'approval_status_chip.dart';
import 'photo_provider.dart';

class PhotoDetailScreen extends ConsumerStatefulWidget {
  const PhotoDetailScreen({super.key, required this.photoId});

  final String photoId;

  @override
  ConsumerState<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends ConsumerState<PhotoDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final photoAsync = ref.watch(photoNotifierProvider);

    return photoAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('PHOTO DETAIL')),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('PHOTO DETAIL')),
        body: Center(child: Text('Error: $err')),
      ),
      data: (state) {
        final PhotoDoc? photoOrNull = state.photos
            .cast<PhotoDoc?>()
            .firstWhere((p) => p?.id == widget.photoId, orElse: () => null);

        if (photoOrNull == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('PHOTO DETAIL')),
            body: const MmEmptyState(
              icon: Icons.error_outline,
              headline: 'Not Found',
              body: 'This photo could not be found.',
            ),
          );
        }

        final photo = photoOrNull;

        return Scaffold(
          backgroundColor: AppTheme.primary,
          appBar: AppBar(
            title: Text(
              DateFormat('MMM d, h:mm a').format(photo.capturedAt).toUpperCase(),
            ),
            backgroundColor: AppTheme.primary,
          ),
          body: Column(
            children: [
              // Full-screen zoomable image
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5.0,
                  child: Center(child: _buildImage(photo)),
                ),
              ),
              // Bottom info panel
              Container(
                color: AppTheme.primary,
                padding: const EdgeInsets.all(DesignTokens.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fixture ID
                    Row(
                      children: [
                        const Text(
                          'FIXTURE: ',
                          style: TextStyle(
                            fontSize: DesignTokens.typeXs,
                            fontWeight: DesignTokens.weightBold,
                            letterSpacing: DesignTokens.letterSpacingEyebrow,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            photo.fixtureId.isNotEmpty
                                ? photo.fixtureId
                                : '—',
                            style: const TextStyle(
                              fontSize: DesignTokens.typeSm,
                              color: AppTheme.canvasBg,
                              fontWeight: DesignTokens.weightMedium,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.spaceXs),
                    // Captured at
                    Text(
                      DateFormat('MMM d, yyyy h:mm a').format(photo.capturedAt),
                      style: const TextStyle(
                        fontSize: DesignTokens.typeSm,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceSm),
                    // Approval status chip
                    ApprovalStatusChip(status: photo.approvalStatus),
                    // Approve / Reject buttons for coordinator/manager only
                    RoleGuard(
                      allowedRoles: const ['coordinator', 'manager'],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: DesignTokens.spaceMd),
                          Row(
                            children: [
                              Expanded(
                                child: _ApproveButton(
                                  disabled: photo.approvalStatus == 'approved',
                                  onPressed: () async {
                                    await ref
                                        .read(photoNotifierProvider.notifier)
                                        .approvePhoto(widget.photoId);
                                  },
                                ),
                              ),
                              const SizedBox(width: DesignTokens.spaceSm),
                              Expanded(
                                child: MmButton.destructive(
                                  label: 'REJECT',
                                  onPressed: photo.approvalStatus == 'rejected'
                                      ? null
                                      : () async {
                                          await ref
                                              .read(
                                                  photoNotifierProvider.notifier)
                                              .rejectPhoto(widget.photoId);
                                        },
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildImage(PhotoDoc photo) {
    if (photo.localPath != null && photo.localPath!.isNotEmpty) {
      return Image.file(
        File(photo.localPath!),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const _ErrorImage(),
      );
    }
    if (photo.remoteUrl != null && photo.remoteUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: photo.remoteUrl!,
        fit: BoxFit.contain,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
        errorWidget: (context, url, error) => const _ErrorImage(),
      );
    }
    return const _ErrorImage();
  }
}

/// Approve button styled with successColor — no MmButton variant for green,
/// so we use a themed ElevatedButton directly.
class _ApproveButton extends StatelessWidget {
  const _ApproveButton({required this.disabled, required this.onPressed});

  final bool disabled;
  final VoidCallback onPressed;

  static const _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(DesignTokens.radiusCta)),
  );

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: disabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.successColor,
        foregroundColor: AppTheme.canvasBg,
        disabledBackgroundColor: AppTheme.successColor.withValues(alpha: 0.4),
        minimumSize: const Size(double.infinity, 44),
        shape: _shape,
        elevation: 0,
      ),
      child: const Text(
        'APPROVE',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2),
      ),
    );
  }
}

class _ErrorImage extends StatelessWidget {
  const _ErrorImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primary,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: AppTheme.canvasBg.withValues(alpha: 0.38),
          size: 64,
        ),
      ),
    );
  }
}
