class Group {
  final String name;
  final String id;
  final String imageUrl;
  final List<String> memberIDs;

  Group({
    required this.name,
    required this.id,
    required this.imageUrl,
    required this.memberIDs,
  });

  Group copyWith({
    String? name,
    String? id,
    String? imageUrl,
    List<String>? memberIDs,
  }) {
    return Group(
      name: name ?? this.name,
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      memberIDs: memberIDs ?? this.memberIDs,
    );
  }

  @override
  String toString() {
    return 'Group(name: $name, id: $id, imageUrl: $imageUrl, memberIDs: $memberIDs)';
  }
}
