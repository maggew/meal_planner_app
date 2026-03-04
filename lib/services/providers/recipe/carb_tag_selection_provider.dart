import 'package:flutter_riverpod/flutter_riverpod.dart';

class CarbTagSelectionNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void toggle(String tag) {
    if (state.contains(tag)) {
      state = state.where((t) => t != tag).toList();
    } else {
      state = [...state, tag];
    }
  }

  void set(List<String> tags) {
    state = List.from(tags);
  }

  void clear() {
    state = [];
  }
}

final carbTagSelectionProvider =
    NotifierProvider<CarbTagSelectionNotifier, List<String>>(
  CarbTagSelectionNotifier.new,
);
