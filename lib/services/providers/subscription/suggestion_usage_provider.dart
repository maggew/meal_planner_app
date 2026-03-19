import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/suggestion_usage.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/providers/subscription/subscription_provider.dart';

class SuggestionUsageNotifier extends Notifier<AsyncValue<SuggestionUsage>> {
  @override
  AsyncValue<SuggestionUsage> build() {
    final groupId =
        ref.watch(sessionProvider.select((s) => s.groupId)) ?? '';
    if (groupId.isEmpty) {
      return AsyncValue.data(const SuggestionUsage(
        groupId: '',
        weekYear: 0,
        weekNumber: 0,
      ));
    }

    _load(groupId);
    return const AsyncValue.loading();
  }

  Future<void> _load(String groupId) async {
    try {
      final repo = ref.read(suggestionUsageRepositoryProvider);
      final usage = await repo.getCurrentWeekUsage(groupId);
      state = AsyncValue.data(usage);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  bool canUseSuggestion() {
    final isPremium = ref.read(isPremiumProvider);
    if (isPremium) return true;

    final usage = state.asData?.value;
    if (usage == null) return true;
    return !usage.limitReached;
  }

  Future<void> recordUsage() async {
    final groupId =
        ref.read(sessionProvider.select((s) => s.groupId)) ?? '';
    if (groupId.isEmpty) return;

    final repo = ref.read(suggestionUsageRepositoryProvider);
    await repo.incrementUsage(groupId);
    ref.invalidateSelf();
  }
}

final suggestionUsageProvider =
    NotifierProvider<SuggestionUsageNotifier, AsyncValue<SuggestionUsage>>(
  SuggestionUsageNotifier.new,
);
