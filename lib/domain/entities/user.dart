class User {
  final String uid;
  final String name;
  final String? currentGroup;

  User({
    required this.uid,
    required this.name,
    this.currentGroup,
  });

  User copyWith({
    String? uid,
    String? name,
    String? email,
    List<String>? groups,
    String? currentGroup,
  }) {
    return User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      currentGroup: currentGroup ?? this.currentGroup,
    );
  }

  @override
  String toString() {
    return 'User(uid: $uid, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
