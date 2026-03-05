class Group {
  final String name;
  final String id;
  final String imageUrl;
  final bool showCarbTags;

  Group({
    required this.name,
    required this.id,
    required this.imageUrl,
    this.showCarbTags = true,
  });

  Group copyWith({
    String? name,
    String? id,
    String? imageUrl,
    bool? showCarbTags,
  }) {
    return Group(
      name: name ?? this.name,
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      showCarbTags: showCarbTags ?? this.showCarbTags,
    );
  }

  @override
  String toString() {
    return 'Group(name: $name, id: $id, imageUrl: $imageUrl, showCarbTags: $showCarbTags)';
  }
}
