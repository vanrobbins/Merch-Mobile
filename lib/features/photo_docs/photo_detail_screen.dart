import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
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
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('PHOTO DETAIL')),
        body: Center(child: Text('Error: $err')),
      ),
      data: (state) {
        final photoOrNull = state.photos
            .cast<dynamic>()
            .firstWhere((p) => p.id == widget.photoId, orElse: () => null);

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
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('PHOTO DETAIL'),
            backgroundColor: Colors.black,
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
                              color: Colors.white,
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
                                child: ElevatedButton(
                                  onPressed: photo.approvalStatus == 'approved'
                                      ? null
                                      : () async {
                                          await ref
                                              .read(
                                                  photoNotifierProvider.notifier)
                                              .approvePhoto(widget.photoId);
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        Colors.green.shade900,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              DesignTokens.radiusSm)),
                                    ),
                                  ),
                                  child: const Text('APPROVE'),
                                ),
                              ),
                              const SizedBox(width: DesignTokens.spaceSm),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: photo.approvalStatus == 'rejected'
                                      ? null
                                      : () async {
                                          await ref
                                              .read(
                                                  photoNotifierProvider.notifier)
                                              .rejectPhoto(widget.photoId);
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.red.shade900,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              DesignTokens.radiusSm)),
                                    ),
                                  ),
                                  child: const Text('REJECT'),
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

  Widget _buildImage(dynamic photo) {
    if (photo.localPath.isNotEmpty) {
      return Image.file(
        File(photo.localPath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const _ErrorImage(),
      );
    }
    if (photo.remoteUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: photo.remoteUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const _ErrorImage(),
      );
    }
    return const _ErrorImage();
  }
}

class _ErrorImage extends StatelessWidget {
  const _ErrorImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade900,
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.white38,
          size: 64,
        ),
      ),
    );
  }
}
