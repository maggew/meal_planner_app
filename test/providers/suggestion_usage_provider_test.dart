import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/group_subscription.dart';
import 'package:meal_planner/domain/entities/suggestion_usage.dart';
import 'package:meal_planner/domain/enums/subscription_status.dart';
import 'package:meal_planner/domain/repositories/suggestion_usage_repository.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/providers/subscription/subscription_provider.dart';
import 'package:meal_planner/services/providers/subscription/suggestion_usage_provider.dart';
import 'package:mocktail/mocktail.dart';

// --- Mocks ---

class MockSuggestionUsageRepository extends Mock
    implements SuggestionUsageRepository {}

// --- Fixtures ---

const _groupId = '00000000-0000-0000-0000-000000000001';

final _freeSubscription = GroupSubscription(
  groupId: _groupId,
  status: SubscriptionStatus.free,
);

final _premiumSubscription = GroupSubscription(
  groupId: _groupId,
  status: SubscriptionStatus.premium,
);

SuggestionUsage _usage({int count = 0}) => SuggestionUsage(
      groupId: _groupId,
      weekYear: 2026,
      weekNumber: 12,
      usageCount: count,
    );

// --- Helpers ---

ProviderContainer _makeContainer({
  required MockSuggestionUsageRepository mockUsageRepo,
  bool isPremium = false,
  SuggestionUsage? initialUsage,
}) {
  final sub = isPremium ? _premiumSubscription : _freeSubscription;
  final usage = initialUsage ?? _usage();

  return ProviderContainer(overrides: [
    sessionProvider.overrideWithValue(
      const SessionState(userId: 'u1', groupId: _groupId),
    ),
    suggestionUsageRepositoryProvider.overrideWithValue(mockUsageRepo),
    isPremiumProvider.overrideWithValue(sub.isPremium),
    // Override the notifier provider directly with pre-loaded state
    suggestionUsageProvider.overrideWith(() {
      return _PreloadedUsageNotifier(usage);
    }),
  ]);
}

/// A test notifier that returns pre-loaded usage state synchronously.
class _PreloadedUsageNotifier extends SuggestionUsageNotifier {
  final SuggestionUsage _usage;

  _PreloadedUsageNotifier(this._usage);

  @override
  AsyncValue<SuggestionUsage> build() => AsyncValue.data(_usage);
}

void main() {
  late MockSuggestionUsageRepository mockUsageRepo;

  setUp(() {
    mockUsageRepo = MockSuggestionUsageRepository();
  });

  group('canUseSuggestion()', () {
    test('gibt true wenn Premium', () {
      final container = _makeContainer(
        mockUsageRepo: mockUsageRepo,
        isPremium: true,
        initialUsage: _usage(count: 10),
      );
      addTearDown(container.dispose);

      final canUse =
          container.read(suggestionUsageProvider.notifier).canUseSuggestion();

      expect(canUse, true);
    });

    test('gibt true wenn Free + usageCount < 3', () {
      final container = _makeContainer(
        mockUsageRepo: mockUsageRepo,
        isPremium: false,
        initialUsage: _usage(count: 1),
      );
      addTearDown(container.dispose);

      final canUse =
          container.read(suggestionUsageProvider.notifier).canUseSuggestion();

      expect(canUse, true);
    });

    test('gibt false wenn Free + usageCount >= 3', () {
      final container = _makeContainer(
        mockUsageRepo: mockUsageRepo,
        isPremium: false,
        initialUsage: _usage(count: 3),
      );
      addTearDown(container.dispose);

      final canUse =
          container.read(suggestionUsageProvider.notifier).canUseSuggestion();

      expect(canUse, false);
    });

    test('gibt false wenn Free + usageCount = 5 (über Limit)', () {
      final container = _makeContainer(
        mockUsageRepo: mockUsageRepo,
        isPremium: false,
        initialUsage: _usage(count: 5),
      );
      addTearDown(container.dispose);

      final canUse =
          container.read(suggestionUsageProvider.notifier).canUseSuggestion();

      expect(canUse, false);
    });
  });

  group('recordUsage()', () {
    test('ruft incrementUsage auf dem Repository auf', () async {
      when(() => mockUsageRepo.getCurrentWeekUsage(_groupId))
          .thenAnswer((_) async => _usage(count: 0));
      when(() => mockUsageRepo.incrementUsage(_groupId))
          .thenAnswer((_) async {});

      final container = _makeContainer(
        mockUsageRepo: mockUsageRepo,
        initialUsage: _usage(count: 0),
      );
      addTearDown(container.dispose);

      await container
          .read(suggestionUsageProvider.notifier)
          .recordUsage();

      verify(() => mockUsageRepo.incrementUsage(_groupId)).called(1);
    });
  });
}
