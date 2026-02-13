import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/cookbook/widgets/cookbook_sorting_button.dart';
import 'package:meal_planner/services/providers/recipe/recipe_search_provider.dart';

class CookbookSearchbar extends ConsumerStatefulWidget {
  const CookbookSearchbar({super.key});

  @override
  ConsumerState<CookbookSearchbar> createState() => _CookbookSearchbarState();
}

class _CookbookSearchbarState extends ConsumerState<CookbookSearchbar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchAll = ref.watch(searchAllCategoriesProvider);
    final query = ref.watch(searchQueryProvider);

    if (_controller.text != query) {
      _controller.text = query;
      _controller.selection = TextSelection.collapsed(offset: query.length);
    }

    final showHint = query.isNotEmpty && query.trim().length < 3;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 48,
            child: Row(
              spacing: 10,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    textAlignVertical: TextAlignVertical.center,
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).set(value);
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _controller.clear();
                                ref.read(searchQueryProvider.notifier).clear();
                              },
                            )
                          : null,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      hintText: "Suche",
                      fillColor: Colors.white70,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                Tooltip(
                  message: 'In allen Kategorien suchen',
                  child: FilterChip(
                    label: Text('Alle'),
                    selected: searchAll,
                    onSelected: (_) {
                      ref.read(searchAllCategoriesProvider.notifier).toggle();
                    },
                  ),
                ),
                CookbookSortingButton(),
              ],
            ),
          ),
          // Animierter Hinweis
          AnimatedSize(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              opacity: showHint ? 1.0 : 0.0,
              child: showHint
                  ? Padding(
                      padding: EdgeInsets.only(top: 6, left: 16),
                      child: Text(
                        'Mindestens 3 Zeichen eingeben',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    )
                  : SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
