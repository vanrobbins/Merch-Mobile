import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/models/photo_doc.dart';
import '../../core/providers/database_provider.dart';

part 'photo_provider.g.dart';

class PhotoState {
  final List<PhotoDoc> photos;
  final bool isLoading;
  final Map<String, double> uploadProgress; // photoId -> 0.0-1.0

  const PhotoState({
    required this.photos,
    this.isLoading = false,
    this.uploadProgress = const {},
  });

  PhotoState copyWith({
    List<PhotoDoc>? photos,
    bool? isLoading,
    Map<String, double>? uploadProgress,
  }) =>
      PhotoState(
        photos: photos ?? this.photos,
        isLoading: isLoading ?? this.isLoading,
        uploadProgress: uploadProgress ?? this.uploadProgress,
      );
}

PhotoDoc _rowToPhoto(PhotoDocsTableData r) => PhotoDoc(
      id: r.id,
      fixtureId: r.fixtureId,
      phase: r.phase,
      localPath: r.localPath,
      remoteUrl: r.remoteUrl,
      uploadStatus: r.uploadStatus,
      approvalStatus: r.approvalStatus,
      planogramId: r.planogramId,
      capturedAt: r.capturedAt,
      updatedAt: r.updatedAt,
    );

PhotoDocsTableCompanion _photoToCompanion(PhotoDoc p) => PhotoDocsTableCompanion(
      id: Value(p.id),
      fixtureId: Value(p.fixtureId),
      phase: Value(p.phase),
      localPath: Value(p.localPath),
      remoteUrl: Value(p.remoteUrl),
      uploadStatus: Value(p.uploadStatus),
      approvalStatus: Value(p.approvalStatus),
      planogramId: Value(p.planogramId),
      capturedAt: Value(p.capturedAt),
      updatedAt: Value(p.updatedAt),
    );

@riverpod
class PhotoNotifier extends _$PhotoNotifier {
  @override
  Future<PhotoState> build() async {
    final db = ref.watch(appDatabaseProvider);
    final rows = await db.photoDocsDao.watchAll().first;
    final photos = rows.map(_rowToPhoto).toList();

    // Keep the state updated as the stream emits new values
    db.photoDocsDao.watchAll().listen((rows) {
      if (state case AsyncData(:final value)) {
        state = AsyncData(value.copyWith(photos: rows.map(_rowToPhoto).toList()));
      }
    });

    return PhotoState(photos: photos);
  }

  Future<void> capturePhoto(String fixtureId, String phase) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;
    await _savePhoto(fixtureId, phase, picked.path);
  }

  Future<void> pickFromGallery(String fixtureId, String phase) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    await _savePhoto(fixtureId, phase, picked.path);
  }

  Future<void> _savePhoto(String fixtureId, String phase, String localPath) async {
    final now = DateTime.now();
    final doc = PhotoDoc(
      id: const Uuid().v4(),
      fixtureId: fixtureId,
      phase: phase,
      localPath: localPath,
      uploadStatus: 'pending',
      capturedAt: now,
      updatedAt: now,
    );
    final db = ref.read(appDatabaseProvider);
    await db.photoDocsDao.upsert(_photoToCompanion(doc));
  }

  Future<void> uploadPhoto(String id) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final photo = current.photos.firstWhere(
      (p) => p.id == id,
      orElse: () => throw StateError('Photo $id not found'),
    );

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final storageRef = FirebaseStorage.instance.ref('photos/$uid/$id.jpg');
    final file = File(photo.localPath);

    // Track upload progress
    final uploadTask = storageRef.putFile(file);
    uploadTask.snapshotEvents.listen((snapshot) {
      if (state case AsyncData(:final value)) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        final updatedProgress = Map<String, double>.from(value.uploadProgress)
          ..[id] = progress;
        state = AsyncData(value.copyWith(uploadProgress: updatedProgress));
      }
    });

    try {
      await uploadTask;
      final remoteUrl = await storageRef.getDownloadURL();
      final updated = photo.copyWith(
        remoteUrl: remoteUrl,
        uploadStatus: 'uploaded',
        updatedAt: DateTime.now(),
      );
      final db = ref.read(appDatabaseProvider);
      await db.photoDocsDao.upsert(_photoToCompanion(updated));

      // Clear progress entry
      if (state case AsyncData(:final value)) {
        final updatedProgress = Map<String, double>.from(value.uploadProgress)
          ..remove(id);
        state = AsyncData(value.copyWith(uploadProgress: updatedProgress));
      }
    } catch (_) {
      final failed = photo.copyWith(
        uploadStatus: 'failed',
        updatedAt: DateTime.now(),
      );
      final db = ref.read(appDatabaseProvider);
      await db.photoDocsDao.upsert(_photoToCompanion(failed));

      // Clear progress entry on failure too
      if (state case AsyncData(:final value)) {
        final updatedProgress = Map<String, double>.from(value.uploadProgress)
          ..remove(id);
        state = AsyncData(value.copyWith(uploadProgress: updatedProgress));
      }
    }
  }

  Future<void> requestApproval(String id) async {
    await _updateApprovalStatus(id, 'pending');
  }

  Future<void> approvePhoto(String id) async {
    await _updateApprovalStatus(id, 'approved');
  }

  Future<void> rejectPhoto(String id) async {
    await _updateApprovalStatus(id, 'rejected');
  }

  Future<void> _updateApprovalStatus(String id, String approvalStatus) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final photo = current.photos.firstWhere(
      (p) => p.id == id,
      orElse: () => throw StateError('Photo $id not found'),
    );

    final updated = photo.copyWith(
      approvalStatus: approvalStatus,
      updatedAt: DateTime.now(),
    );
    final db = ref.read(appDatabaseProvider);
    await db.photoDocsDao.upsert(_photoToCompanion(updated));
  }

  Future<void> linkToPlanogram(String photoId, String planogramId) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final photo = current.photos.firstWhere(
      (p) => p.id == photoId,
      orElse: () => throw StateError('Photo $photoId not found'),
    );

    final updated = photo.copyWith(
      planogramId: planogramId,
      updatedAt: DateTime.now(),
    );
    final db = ref.read(appDatabaseProvider);
    await db.photoDocsDao.upsert(_photoToCompanion(updated));
  }

  Future<void> retryFailedUploads() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final failed = current.photos.where((p) => p.uploadStatus == 'failed').toList();
    for (final photo in failed) {
      await uploadPhoto(photo.id);
    }
  }
}
