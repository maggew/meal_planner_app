import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/entities/shopping_list_item.dart';
import 'package:meal_planner/services/providers/shopping_list/shopping_list_provider.dart';

class ShoppingListItemTile extends ConsumerStatefulWidget {
  final ShoppingListItem item;

  const ShoppingListItemTile({super.key, required this.item});

  @override
  ConsumerState<ShoppingListItemTile> createState() =>
      _ShoppingListItemTileState();
}

class _ShoppingListItemTileState extends ConsumerState<ShoppingListItemTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDimensions.animationDuration,
    );
    // Entrance: spring pop-in
    _controller.animateTo(1.0, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    // Exit: quick shrink before state change
    await _controller.animateTo(
      0.0,
      duration: AppDimensions.animationDuration,
      curve: Curves.easeIn,
    );
    if (!mounted) return;
    ref
        .read(shoppingListActionsProvider.notifier)
        .toggleItem(widget.item.id, !widget.item.isChecked);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ScaleTransition(
      scale: _controller,
      child: Card(
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _handleTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  widget.item.information[0],
                  style: GoogleFonts.frederickaTheGreat(
                      fontSize: 50,
                      color: widget.item.isChecked
                          ? colorScheme.onSurface.withValues(alpha: 0.4)
                          : null),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 10,
                  child: Text(
                    [
                      if (widget.item.quantity != null) widget.item.quantity!,
                      widget.item.information,
                    ].join(' '),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          widget.item.quantity != null ? FontWeight.bold : null,
                      color: widget.item.isChecked
                          ? colorScheme.onSurface.withValues(alpha: 0.4)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
