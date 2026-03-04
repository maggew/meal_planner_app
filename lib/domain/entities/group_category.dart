class GroupCategory {
  final String id;
  final String groupId;
  final String name;
  final int sortOrder;
  final String? iconName;

  const GroupCategory({
    required this.id,
    required this.groupId,
    required this.name,
    this.sortOrder = 0,
    this.iconName,
  });

  GroupCategory copyWith({
    String? id,
    String? groupId,
    String? name,
    int? sortOrder,
    String? iconName,
  }) {
    return GroupCategory(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      iconName: iconName ?? this.iconName,
    );
  }
}
