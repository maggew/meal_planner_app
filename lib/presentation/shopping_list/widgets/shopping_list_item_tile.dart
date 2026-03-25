import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  bool get _hasQuantity =>
      widget.item.quantity != null &&
      widget.item.quantity!.isNotEmpty &&
      widget.item.quantity != 'null';

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

  Future<void> _handleEdit() async {
    final item = widget.item;
    final nameController = TextEditingController(text: item.information);
    final quantityController = TextEditingController(
      text: _hasQuantity ? item.quantity! : '',
    );

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadius),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppDimensions.screenMargin,
            right: AppDimensions.screenMargin,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Eintrag bearbeiten',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name'),
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: [LengthLimitingTextInputFormatter(300)],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Menge'),
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Abbrechen'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Speichern'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (result == true && mounted && nameController.text.trim().isNotEmpty) {
      final newName = nameController.text.trim();
      final newQuantity = quantityController.text.trim();
      ref.read(shoppingListActionsProvider.notifier).updateItem(
            item.id,
            newName,
            newQuantity.isEmpty ? null : newQuantity,
          );
    }
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
          onLongPress: _handleEdit,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    widget.item.information.isNotEmpty
                        ? widget.item.information[0]
                        : '?',
                    style: GoogleFonts.frederickaTheGreat(
                        fontSize: 50,
                        color: widget.item.isChecked
                            ? colorScheme.onSurface.withValues(alpha: 0.4)
                            : null),
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      if (_hasQuantity)
                        TextSpan(
                          text: '${widget.item.quantity!} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      TextSpan(text: widget.item.information),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.item.isChecked
                        ? colorScheme.onSurface.withValues(alpha: 0.4)
                        : null,
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
