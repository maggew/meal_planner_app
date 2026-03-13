import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_plan_clipboard_provider.g.dart';

class MealPlanClipboardEntry {
  final MealPlanEntry entry;
  final bool isCut;
  final String? displayName;

  const MealPlanClipboardEntry({
    required this.entry,
    required this.isCut,
    this.displayName,
  });
}

@riverpod
class MealPlanClipboard extends _$MealPlanClipboard {
  @override
  MealPlanClipboardEntry? build() => null;

  void copy(MealPlanEntry entry, {String? displayName}) =>
      state = MealPlanClipboardEntry(
          entry: entry, isCut: false, displayName: displayName);

  void cut(MealPlanEntry entry, {String? displayName}) =>
      state = MealPlanClipboardEntry(
          entry: entry, isCut: true, displayName: displayName);

  void clear() => state = null;
}
