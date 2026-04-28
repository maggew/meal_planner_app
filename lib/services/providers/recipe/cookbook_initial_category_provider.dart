import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cookbook_initial_category_provider.g.dart';

/// Hält die Kategorie-ID + eine Generation, zu der das Kochbuch beim nächsten
/// Build springen soll. Die Generation wird bei jedem Upload hochgezählt und
/// dient als ValueKey für VerticalTabs, damit initState neu ausgeführt wird.
/// Nach dem Build wird nur die categoryId gecleart — die Generation bleibt,
/// damit kein weiterer Rebuild ausgelöst wird.
@riverpod
class CookbookInitialCategory extends _$CookbookInitialCategory {
  @override
  ({String? categoryId, int generation}) build() =>
      (categoryId: null, generation: 0);

  void set(String categoryId) => state = (
        categoryId: categoryId,
        generation: state.generation + 1,
      );

  /// Only jumps if no explicit navigation has happened this session (generation == 0).
  void setIfFirstTime(String categoryId) {
    if (state.generation == 0) {
      state = (categoryId: categoryId, generation: 1);
    }
  }

  void clear() => state = (categoryId: null, generation: state.generation);
}
