class User {
  final String id;
  final String name;
  final String? image_url;

  User({
    required this.id,
    required this.name,
    this.image_url,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? groups,
    String? imageUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      image_url: image_url ?? this.image_url,
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
