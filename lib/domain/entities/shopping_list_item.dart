class ShoppingListItem {
  final String id;
  final String groupId;
  final String information;
  final bool isChecked;

  const ShoppingListItem({
    required this.id,
    required this.groupId,
    required this.information,
    required this.isChecked,
  });

  ShoppingListItem copyWith({
    String? id,
    String? groupId,
    String? information,
    bool? isChecked,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      information: information ?? this.information,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
