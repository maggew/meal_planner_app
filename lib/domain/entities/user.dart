class User {
  final String id;
  final String name;
  final String? imageUrl;

  User({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  User copyWith({
    String? id,
    String? name,
    String? imageUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
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
