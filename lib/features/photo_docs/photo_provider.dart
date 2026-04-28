import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/photo_doc.dart';
import '../../core/providers/store_provider.dart';
import '../../core/services/firestore_refs.dart';

part 'photo_provider.g.dart';

class PhotoState {
  final List<PhotoDoc> photos;
  final bool isLoading;
  final Map<String, double> uploadProgress;

  const PhotoState({
    required this.photos,
    this.isLoading = false,
    this.uploadProgress = const {},
  });

  PhotoState copyWith({
    List<PhotoDoc>? photos,
    bool? isLoading,
    Map<String, double>? uploadProgress,
  }) => PhotoState(
    photos: photos ?? this.photos,
    isLoading: isLoading ?? this.isLoading,
    uploadProgress: uploadProgress ?? this.uploadProgress,
  );
}

@riverpod
class PhotoNotifier extends _$PhotoNotifier {
  @override
  Future<PhotoState> build() async {
    final storeId = ref.watch(activeStoreIdProvider).value;
    if (storeId == null) return const PhotoState(photos: []);

    final sub = FirestoreRefs.photos(storeId).snapshots().listen(
      (snap) {
        final photos = snap.docs
            .map((d) => PhotoDocFirestore.fromDoc(d, storeId))
            .toList();
        if (state case AsyncData(:final value)) {
          state = AsyncData(value.copyWith(photos: photos));
        }
      },
      onError: (_, __) {},
    );
    ref.onDispose(sub.cancel);

    final snap = await FirestoreRefs.photos(storeId).get();
    final photos = snap.docs
        .map((d) => PhotoDocFirestore.fromDoc(d, storeId))
        .toList();
    return PhotoState(photos: photos);
  }

  String get _storeId => ref.read(activeStoreIdProvider).value ?? '';

  Future<void> capturePhoto(String fixtureId, String phase) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked == null) return;
    await _savePhoto(fixtureId, phase, picked.path);
  }

  Future<void> pickFromGallery(String fixtureId, String phase) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
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
      storeId: _storeId,
      capturedAt: now,
      updatedAt: now,
    );
    await FirestoreRefs.photos(_storeId)
        .doc(doc.id)
        .set(doc.toFirestore());
  }

  Future<void> uploadPhoto(String id) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final photo = current.photos.firstWhere((p) => p.id == id,
        orElse: () => throw StateError('Photo $id not found'));
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final storageRef = FirebaseStorage.instance.ref('photos/$uid/$id.jpg');
    final uploadTask = storageRef.putFile(File(photo.localPath!));

    uploadTask.snapshotEvents.listen((snap) {
      if (state case AsyncData(:final value)) {
        final progress = snap.bytesTransferred / snap.totalBytes;
        state = AsyncData(value.copyWith(uploadProgress: {
          ...value.uploadProgress,
          id: progress,
        }));
      }
    });

    try {
      await uploadTask;
      final remoteUrl = await storageRef.getDownloadURL();
      await FirestoreRefs.photos(_storeId).doc(id).update({
        'remoteUrl': remoteUrl,
        'uploadStatus': 'uploaded',
        'updatedAt': Timestamp.now(),
      });
    } catch (_) {
      await FirestoreRefs.photos(_storeId).doc(id).update({
        'uploadStatus': 'failed',
        'updatedAt': Timestamp.now(),
      });
    } finally {
      if (state case AsyncData(:final value)) {
        final p = Map<String, double>.from(value.uploadProgress)..remove(id);
        state = AsyncData(value.copyWith(uploadProgress: p));
      }
    }
  }

  Future<void> requestApproval(String id) =>
      _updateApprovalStatus(id, 'pending');
  Future<void> approvePhoto(String id) =>
      _updateApprovalStatus(id, 'approved');
  Future<void> rejectPhoto(String id) =>
      _updateApprovalStatus(id, 'rejected');

  Future<void> _updateApprovalStatus(String id, String status) async {
    await FirestoreRefs.photos(_storeId).doc(id).update({
      'approvalStatus': status,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> linkToPlanogram(String photoId, String planogramId) async {
    await FirestoreRefs.photos(_storeId).doc(photoId).update({
      'planogramId': planogramId,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> retryFailedUploads() async {
    final current = state.valueOrNull;
    if (current == null) return;
    for (final photo in current.photos.where((p) => p.uploadStatus == 'failed')) {
      await uploadPhoto(photo.id);
    }
  }
}
