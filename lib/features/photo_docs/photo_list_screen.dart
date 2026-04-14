import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/photo_doc.dart';
import '../../core/providers/connectivity_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/mm_banner.dart';
import '../../core/widgets/mm_empty_state.dart';
import '../../core/widgets/role_guard.dart';
import 'approval_status_chip.dart';
import 'photo_capture_button.dart';
import 'photo_provider.dart';

class PhotoListScreen extends ConsumerStatefulWidget {
  const PhotoListScreen({super.key});

  @override
  ConsumerState<PhotoListScreen> createState() => _PhotoListScreenState();
}

class _PhotoListScreenState extends ConsumerState<PhotoListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photoAsync = ref.watch(photoNotifierProvider);
    final connectivityAsync = ref.watch(connectivityProvider);
    final isOnline = connectivityAsync.valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PHOTO DOCS'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: AppTheme.accent,
          labelStyle: const TextStyle(
            fontSize: DesignTokens.typeXs,
            fontWeight: DesignTokens.weightBold,
            letterSpacing: DesignTokens.letterSpacingEyebrow,
          ),
          tabs: const [
            Tab(text: 'BEFORE'),
            Tab(text: 'AFTER'),
          ],
        ),
      ),
      floatingActionButton: const RoleGuard(
        allowedRoles: ['coordinator', 'manager', 'staff'],
        child: PhotoCaptureButton(
          fixtureId: '',
          phase: 'before',
        ),
      ),
      body: Column(
        children: [
          if (!isOnline)
            const MmBanner(
              variant: BannerVariant.offline,
              message: 'You are offline. Uploads will resume when connected.',
            ),
          Expanded(
            child: photoAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ),
              data: (state) => TabBarView(
                controller: _tabController,
                children: [
                  _PhotoGrid(
                    photos: state.photos
                        .where((p) => p.phase == 'before')
                        .toList(),
                  ),
                  _PhotoGrid(
                    photos: state.photos
                        .where((p) => p.phase == 'after')
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.photos});

  final List<PhotoDoc> photos;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const MmEmptyState(
        icon: Icons.photo_library_outlined,
        headline: 'No Photos',
        body: 'Capture or upload photos using the button below.',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(DesignTokens.spaceXs),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: DesignTokens.spaceXs,
        mainAxisSpacing: DesignTokens.spaceXs,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return _PhotoGridItem(photo: photo);
      },
    );
  }
}

class _PhotoGridItem extends StatelessWidget {
  const _PhotoGridItem({required this.photo});

  final PhotoDoc photo;

  Widget _buildImage() {
    if (photo.localPath.isNotEmpty) {
      final file = File(photo.localPath);
      return Image.file(file, fit: BoxFit.cover);
    }
    if (photo.remoteUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: photo.remoteUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.grey.shade200),
        errorWidget: (context, url, error) =>
            Container(color: Colors.grey.shade300),
      );
    }
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.goNamed(
        AppRoutes.photoDetail,
        pathParameters: {'photoId': photo.id},
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            child: _buildImage(),
          ),
          // Approval status overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(DesignTokens.radiusSm),
                  bottomRight: Radius.circular(DesignTokens.radiusSm),
                ),
              ),
              padding: const EdgeInsets.all(DesignTokens.spaceXs),
              child: ApprovalStatusChip(status: photo.approvalStatus),
            ),
          ),
        ],
      ),
    );
  }
}
