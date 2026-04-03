import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/core/utils/recipe_link_parser.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';

/// Shows a recipe suggestion overlay at the cursor position when the user types `@`.
/// Uses CompositedTransform so the overlay scrolls with the TextField.
class RecipeMentionOverlay extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final Widget child;
  final String? currentRecipeId;

  const RecipeMentionOverlay({
    super.key,
    required this.controller,
    required this.child,
    this.currentRecipeId,
  });

  @override
  ConsumerState<RecipeMentionOverlay> createState() =>
      _RecipeMentionOverlayState();
}

class _RecipeMentionOverlayState extends ConsumerState<RecipeMentionOverlay> {
  List<Recipe> _suggestions = [];
  String _currentQuery = '';
  OverlayEntry? _overlayEntry;
  final _layerLink = LayerLink();
  final _childKey = GlobalKey();
  double _caretYOffset = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _removeOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final cursorPos = widget.controller.selection.baseOffset;
    if (cursorPos < 0 || cursorPos > text.length) {
      _removeOverlay();
      return;
    }

    final textBeforeCursor = text.substring(0, cursorPos);
    final atIndex = textBeforeCursor.lastIndexOf('@');
    if (atIndex < 0) {
      _removeOverlay();
      return;
    }

    final textFromAt = text.substring(atIndex);
    if (RecipeLinkParser.hasLinks(textFromAt)) {
      _removeOverlay();
      return;
    }

    final query = textBeforeCursor.substring(atIndex + 1);
    if (query.contains('\n') || query.length < 2) {
      if (query.isEmpty || atIndex == textBeforeCursor.length - 1) {
        _suggestions = [];
        _currentQuery = query;
        _showOverlay();
      } else if (query.length < 2) {
        _suggestions = [];
        _currentQuery = query;
        _showOverlay();
      } else {
        _removeOverlay();
      }
      return;
    }

    _searchRecipes(query);
  }

  Future<void> _searchRecipes(String query) async {
    _currentQuery = query;
    try {
      final repo = ref.read(recipeRepositoryProvider);
      final results = await repo.searchRecipes(query);
      if (!mounted || _currentQuery != query) return;
      _suggestions = results
          .where((r) =>
              widget.currentRecipeId == null || r.id != widget.currentRecipeId)
          .take(5)
          .toList();
      _showOverlay();
    } catch (_) {}
  }

  /// Returns the caret's Y offset relative to the top of the child widget.
  double? _getCaretYRelativeToChild() {
    final renderObject = _childKey.currentContext?.findRenderObject();
    if (renderObject == null || renderObject is! RenderBox) return null;

    RenderEditable? editable;
    void visitor(RenderObject child) {
      if (child is RenderEditable) {
        editable = child;
        return;
      }
      child.visitChildren(visitor);
    }
    renderObject.visitChildren(visitor);
    if (editable == null) return null;

    final cursorPos = widget.controller.selection.baseOffset;
    if (cursorPos < 0) return null;

    final caretRect = editable!.getLocalRectForCaret(
      TextPosition(offset: cursorPos),
    );

    // Convert caret bottom from RenderEditable-local to child-widget-local
    final caretGlobal = editable!.localToGlobal(caretRect.bottomLeft);
    final childGlobal = renderObject.localToGlobal(Offset.zero);

    return caretGlobal.dy - childGlobal.dy;
  }

  double? _childWidth;

  void _showOverlay() {
    final yOffset = _getCaretYRelativeToChild();
    if (yOffset == null) return;
    _caretYOffset = yOffset;

    final renderObject = _childKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      _childWidth = renderObject.size.width;
    }

    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        const double maxHeight = 200;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, _caretYOffset + 4),
              child: Material(
                elevation: 8,
                borderRadius: AppDimensions.borderRadiusAll,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: maxHeight,
                    maxWidth: _childWidth ?? double.infinity,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: AppDimensions.borderRadiusAll,
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: _suggestions.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _currentQuery.length < 2
                                ? 'Rezeptname eingeben...'
                                : 'Keine Rezepte gefunden',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: _suggestions.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final recipe = _suggestions[index];
                            return ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              leading: Icon(
                                Icons.restaurant_menu,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                              title: Text(
                                recipe.name,
                                style: textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _selectRecipe(recipe),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectRecipe(Recipe recipe) {
    final text = widget.controller.text;
    final cursorPos = widget.controller.selection.baseOffset;
    final textBeforeCursor = text.substring(0, cursorPos);
    final atIndex = textBeforeCursor.lastIndexOf('@');
    if (atIndex < 0) return;

    final encoded = RecipeLinkParser.encode(recipe.name, recipe.id!);
    final newText = text.substring(0, atIndex) +
        encoded +
        ' ' +
        text.substring(cursorPos);

    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: atIndex + encoded.length + 1,
      ),
    );

    _removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: KeyedSubtree(
        key: _childKey,
        child: widget.child,
      ),
    );
  }
}
