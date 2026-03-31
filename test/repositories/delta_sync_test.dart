import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/data/repositories/cached_recipe_repository.dart';

void main() {
  group('computeSyncDelta', () {
    final baseTime = DateTime(2026, 3, 30, 12, 0);
    final updatedTime = DateTime(2026, 3, 30, 14, 0);

    test('returns empty when manifests are identical', () {
      final manifest = [
        (id: 'r1', updatedAt: baseTime as DateTime?),
        (id: 'r2', updatedAt: baseTime as DateTime?),
      ];

      final result = computeSyncDelta(
        remoteManifest: manifest,
        localManifest: manifest,
      );

      expect(result.idsToFetch, isEmpty);
      expect(result.idsToDelete, isEmpty);
    });

    test('detects new recipes (in remote, not in local)', () {
      final result = computeSyncDelta(
        remoteManifest: [
          (id: 'r1', updatedAt: baseTime as DateTime?),
          (id: 'r2', updatedAt: baseTime as DateTime?),
        ],
        localManifest: [
          (id: 'r1', updatedAt: baseTime as DateTime?),
        ],
      );

      expect(result.idsToFetch, ['r2']);
      expect(result.idsToDelete, isEmpty);
    });

    test('detects deleted recipes (in local, not in remote)', () {
      final result = computeSyncDelta(
        remoteManifest: [
          (id: 'r1', updatedAt: baseTime as DateTime?),
        ],
        localManifest: [
          (id: 'r1', updatedAt: baseTime as DateTime?),
          (id: 'r2', updatedAt: baseTime as DateTime?),
        ],
      );

      expect(result.idsToFetch, isEmpty);
      expect(result.idsToDelete, ['r2']);
    });

    test('detects updated recipes (different timestamps)', () {
      final result = computeSyncDelta(
        remoteManifest: [
          (id: 'r1', updatedAt: updatedTime as DateTime?),
        ],
        localManifest: [
          (id: 'r1', updatedAt: baseTime as DateTime?),
        ],
      );

      expect(result.idsToFetch, ['r1']);
      expect(result.idsToDelete, isEmpty);
    });

    test('skips recipes with matching timestamps', () {
      final result = computeSyncDelta(
        remoteManifest: [
          (id: 'r1', updatedAt: baseTime as DateTime?),
          (id: 'r2', updatedAt: updatedTime as DateTime?),
        ],
        localManifest: [
          (id: 'r1', updatedAt: baseTime as DateTime?),
          (id: 'r2', updatedAt: baseTime as DateTime?),
        ],
      );

      expect(result.idsToFetch, ['r2']);
      expect(result.idsToDelete, isEmpty);
    });

    test('handles null updatedAt in local (legacy cache entry)', () {
      final result = computeSyncDelta(
        remoteManifest: [
          (id: 'r1', updatedAt: baseTime as DateTime?),
        ],
        localManifest: [
          (id: 'r1', updatedAt: null),
        ],
      );

      // Remote has a timestamp, local doesn't → should fetch
      expect(result.idsToFetch, ['r1']);
    });

    test('handles null updatedAt in remote', () {
      final result = computeSyncDelta(
        remoteManifest: [
          (id: 'r1', updatedAt: null),
        ],
        localManifest: [
          (id: 'r1', updatedAt: baseTime as DateTime?),
        ],
      );

      // Remote has null timestamp → no change detected
      expect(result.idsToFetch, isEmpty);
    });

    test('combined: new, updated, deleted, unchanged', () {
      final result = computeSyncDelta(
        remoteManifest: [
          (id: 'r1', updatedAt: baseTime as DateTime?), // unchanged
          (id: 'r2', updatedAt: updatedTime as DateTime?), // updated
          (id: 'r4', updatedAt: baseTime as DateTime?), // new
        ],
        localManifest: [
          (id: 'r1', updatedAt: baseTime as DateTime?), // unchanged
          (id: 'r2', updatedAt: baseTime as DateTime?), // will be updated
          (id: 'r3', updatedAt: baseTime as DateTime?), // deleted
        ],
      );

      expect(result.idsToFetch, ['r2', 'r4']);
      expect(result.idsToDelete, ['r3']);
    });
  });
}
