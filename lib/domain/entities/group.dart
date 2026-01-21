class Group {
  final String name;
  final String id;
  final String imageUrl;

  Group({
    required this.name,
    required this.id,
    required this.imageUrl,
  });

  Group copyWith({
    String? name,
    String? id,
    String? imageUrl,
  }) {
    return Group(
      name: name ?? this.name,
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() {
    return 'Group(name: $name, id: $id, imageUrl: $imageUrl)';
  }
}
