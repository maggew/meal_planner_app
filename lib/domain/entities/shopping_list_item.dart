class ShoppingListItem {
  final String id;
  final String groupId;
  final String information;
  final String? quantity;
  final bool isChecked;

  const ShoppingListItem({
    required this.id,
    required this.groupId,
    required this.information,
    this.quantity,
    required this.isChecked,
  });

  ShoppingListItem copyWith({
    String? id,
    String? groupId,
    String? information,
    String? quantity,
    bool? isChecked,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      information: information ?? this.information,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
