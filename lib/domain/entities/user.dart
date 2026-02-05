class User {
  final String id;
  final String name;
  final String? currentGroup;

  User({
    required this.id,
    required this.name,
    this.currentGroup,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? groups,
    String? currentGroup,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      currentGroup: currentGroup ?? this.currentGroup,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
