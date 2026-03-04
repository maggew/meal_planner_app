import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/group_category.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/domain/repositories/group_category_repository.dart';
import 'package:meal_planner/services/providers/groups/group_category_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:mocktail/mocktail.dart';

// --- Mocks ---

class MockGroupCategoryRepository extends Mock
    implements GroupCategoryRepository {}

class FakeSessionNotifier extends StateNotifier<SessionState>
    implements SessionController {
  FakeSessionNotifier(super.state);

  @override
  Future<void> loadSession(String userId) async {}
  @override
  Future<void> joinGroup(String groupId) async {}
  @override
  Future<void> setActiveGroup(String groupId) async {}
  @override
  Future<void> reloadActiveGroup() async {}
  @override
  void setActiveUserAfterRegistration(String userId) {}
  @override
  Future<void> changeSettings(UserSettings settings) async {}
  @override
  Future<void> clearSession() async {}
  @override
  Ref get ref => throw UnimplementedError();
}

// --- Fixtures ---

// Gültige UUID — GroupCategories.build() prüft mit _uuidRegex
const _groupId = '00000000-0000-0000-0000-000000000001';

final _cat0 = GroupCategory(id: 'c0', groupId: _groupId, name: 'suppen', sortOrder: 0);
final _cat1 = GroupCategory(id: 'c1', groupId: _groupId, name: 'salate', sortOrder: 1);
final _cat2 = GroupCategory(id: 'c2', groupId: _groupId, name: 'desserts', sortOrder: 2);
final _initialCategories = [_cat0, _cat1, _cat2];

// --- Helpers ---

ProviderContainer _makeContainer(MockGroupCategoryRepository mockRepo) {
  final container = ProviderContainer(overrides: [
    sessionProvider.overrideWith(
      (ref) => FakeSessionNotifier(
        const SessionState(userId: 'u1', groupId: _groupId),
      ),
    ),
    groupCategoryRepositoryProvider.overrideWithValue(mockRepo),
  ]);
  return container;
}

void main() {
  late MockGroupCategoryRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(<GroupCategory>[]);
  });

  setUp(() {
    mockRepo = MockGroupCategoryRepository();
    // Standard-Antwort für initialen Fetch
    when(() => mockRepo.getCategories(_groupId))
        .thenAnswer((_) async => _initialCategories);
  });

  group('GroupCategories.build()', () {
    test('gibt leere Liste zurück wenn kein groupId in Session', () async {
      final container = ProviderContainer(overrides: [
        sessionProvider.overrideWith(
          (ref) => FakeSessionNotifier(const SessionState()),
        ),
        groupCategoryRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      final result = await container.read(groupCategoriesProvider.future);

      expect(result, isEmpty);
      verifyNever(() => mockRepo.getCategories(any()));
    });

    test('lädt Kategorien vom Repository', () async {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      final result = await container.read(groupCategoriesProvider.future);

      expect(result, equals(_initialCategories));
      verify(() => mockRepo.getCategories(_groupId)).called(1);
    });
  });

  group('reorderCategories()', () {
    test('ruft updateSortOrders mit korrekten sortOrder-Werten auf', () async {
      when(() => mockRepo.updateSortOrders(any()))
          .thenAnswer((_) async {});

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      await container.read(groupCategoriesProvider.future);

      // Neue Reihenfolge: cat2, cat0, cat1
      final newOrder = [_cat2, _cat0, _cat1];
      await container
          .read(groupCategoriesProvider.notifier)
          .reorderCategories(newOrder);

      final captured = verify(() => mockRepo.updateSortOrders(captureAny()))
          .captured
          .single as List<GroupCategory>;

      // cat2 → sortOrder 0, cat0 → sortOrder 1, cat1 → sortOrder 2
      expect(captured.map((c) => c.id).toList(), equals(['c2', 'c0', 'c1']));
      expect(captured.map((c) => c.sortOrder).toList(), equals([0, 1, 2]));
    });

    test('aktualisiert lokalen State sofort (vor Supabase-Abschluss)', () async {
      final completer = Completer<void>();
      when(() => mockRepo.updateSortOrders(any()))
          .thenAnswer((_) => completer.future);

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      await container.read(groupCategoriesProvider.future);

      final newOrder = [_cat2, _cat0, _cat1];
      // Nicht awaiten — Supabase-Update hängt am Completer
      final reorderFuture = container
          .read(groupCategoriesProvider.notifier)
          .reorderCategories(newOrder);

      // Mikrotask-Queue durchlaufen lassen (state = AsyncData(...) ist synchron vor dem ersten await)
      await Future.microtask(() {});

      final currentState = container.read(groupCategoriesProvider);
      final ids = currentState.value!.map((c) => c.id).toList();
      expect(ids, equals(['c2', 'c0', 'c1']),
          reason: 'Lokaler State sollte sofort aktualisiert sein');

      // Aufräumen
      completer.complete();
      await reorderFuture;
    });

    test('ruft nach Erfolg KEIN ref.invalidateSelf() auf (kein unnötiges Re-fetch)',
        () async {
      when(() => mockRepo.updateSortOrders(any()))
          .thenAnswer((_) async {});

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      await container.read(groupCategoriesProvider.future);

      await container
          .read(groupCategoriesProvider.notifier)
          .reorderCategories([_cat1, _cat0, _cat2]);

      // getCategories sollte nur einmal aufgerufen worden sein (initialer build)
      // — kein Re-fetch nach erfolgreichem Reorder
      verify(() => mockRepo.getCategories(_groupId)).called(1);
    });

    test('bei Supabase-Fehler: wirft Exception und lädt Supabase-Stand neu',
        () async {
      when(() => mockRepo.updateSortOrders(any()))
          .thenThrow(Exception('Netzwerkfehler'));

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      await container.read(groupCategoriesProvider.future);

      await expectLater(
        container
            .read(groupCategoriesProvider.notifier)
            .reorderCategories([_cat2, _cat0, _cat1]),
        throwsException,
      );

      // invalidateSelf bei Fehler → getCategories erneut aufgerufen
      await container.read(groupCategoriesProvider.future);
      verify(() => mockRepo.getCategories(_groupId))
          .called(greaterThanOrEqualTo(2));
    });

    test('bei Fehler bleibt Exception-Typ erhalten (rethrow)', () async {
      when(() => mockRepo.updateSortOrders(any()))
          .thenThrow(StateError('irgendein Fehler'));

      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      await container.read(groupCategoriesProvider.future);

      await expectLater(
        container
            .read(groupCategoriesProvider.notifier)
            .reorderCategories([_cat1, _cat0, _cat2]),
        throwsA(isA<StateError>()),
      );
    });
  });
}
