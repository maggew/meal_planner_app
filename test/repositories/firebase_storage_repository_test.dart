import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/data/repositories/firebase_storage_repository.dart';
import 'package:mocktail/mocktail.dart';

// ─── Fakes ───────────────────────────────────────────────────────────────────

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

/// Minimal fake TaskSnapshot — only needed as the resolved type of UploadTask.
class _FakeTaskSnapshot extends Fake implements TaskSnapshot {}

/// Fake UploadTask that resolves immediately.
class _FakeUploadTask extends Fake implements UploadTask {
  final _future = Future<TaskSnapshot>.value(_FakeTaskSnapshot());

  @override
  Future<R> then<R>(FutureOr<R> Function(TaskSnapshot) onValue,
          {Function? onError}) =>
      _future.then(onValue, onError: onError);

  @override
  Future<TaskSnapshot> catchError(Function f,
          {bool Function(Object)? test}) =>
      _future.catchError(f, test: test);

  @override
  Future<TaskSnapshot> whenComplete(FutureOr<void> Function() action) =>
      _future.whenComplete(action);

  @override
  Future<TaskSnapshot> timeout(Duration d,
          {FutureOr<TaskSnapshot> Function()? onTimeout}) =>
      _future.timeout(d, onTimeout: onTimeout);

  @override
  Stream<TaskSnapshot> asStream() => _future.asStream();
}

/// Configurable fake Reference for upload and delete scenarios.
class _FakeReference extends Fake implements Reference {
  final String _downloadUrl;
  final bool _deleteThrows;
  final bool _putFileThrows;

  _FakeReference({
    String downloadUrl = 'https://firebase.storage/test-image.jpg',
    bool deleteThrows = false,
    bool putFileThrows = false,
  })  : _downloadUrl = downloadUrl,
        _deleteThrows = deleteThrows,
        _putFileThrows = putFileThrows;

  @override
  Reference child(String path) => this;

  @override
  UploadTask putFile(File file, [SettableMetadata? metadata]) {
    if (_putFileThrows) throw Exception('upload failed');
    return _FakeUploadTask();
  }

  @override
  Future<String> getDownloadURL() => Future.value(_downloadUrl);

  @override
  Future<void> delete() {
    if (_deleteThrows) throw Exception('delete failed');
    return Future<void>.value();
  }
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late MockFirebaseStorage mockStorage;
  late FirebaseStorageRepository repo;

  setUpAll(() {
    registerFallbackValue(File(''));
  });

  setUp(() {
    mockStorage = MockFirebaseStorage();
    repo = FirebaseStorageRepository(storage: mockStorage);
  });

  // ── uploadImage ─────────────────────────────────────────────────────────────

  group('uploadImage', () {
    test('returns download URL from Firebase Storage', () async {
      final fakeRef = _FakeReference(downloadUrl: 'https://cdn.test/photo.jpg');
      when(() => mockStorage.ref()).thenReturn(fakeRef);

      final url = await repo.uploadImage(File('image.jpg'), 'images/user');
      expect(url, 'https://cdn.test/photo.jpg');
    });

    test('completes without throwing', () async {
      when(() => mockStorage.ref())
          .thenReturn(_FakeReference());

      await expectLater(
          repo.uploadImage(File('image.jpg'), 'images/user'), completes);
    });

    test('uses storage.ref() as the root for building the file path', () async {
      when(() => mockStorage.ref()).thenReturn(_FakeReference());

      await repo.uploadImage(File('image.jpg'), 'images/recipes');

      verify(() => mockStorage.ref()).called(1);
    });

    test('propagates error when putFile() throws', () async {
      final fakeRef = _FakeReference(putFileThrows: true);
      when(() => mockStorage.ref()).thenReturn(fakeRef);

      await expectLater(
          repo.uploadImage(File('image.jpg'), 'images/user'),
          throwsA(isA<Exception>()));
    });
  });

  // ── deleteImage ─────────────────────────────────────────────────────────────

  group('deleteImage', () {
    test('returns immediately for empty string without calling storage',
        () async {
      await expectLater(repo.deleteImage(''), completes);
      verifyNever(() => mockStorage.refFromURL(any()));
    });

    test('completes for a valid URL', () async {
      when(() => mockStorage.refFromURL(any()))
          .thenReturn(_FakeReference());

      await expectLater(
          repo.deleteImage('https://firebase.storage/img.jpg'), completes);
    });

    test('completes even when delete() throws (error is swallowed)', () async {
      when(() => mockStorage.refFromURL(any()))
          .thenReturn(_FakeReference(deleteThrows: true));

      await expectLater(
          repo.deleteImage('https://firebase.storage/img.jpg'), completes);
    });
  });
}
