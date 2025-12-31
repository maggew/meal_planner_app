class User {
  final String uid;
  final String name;
  final String email;
  final List<String> groups;
  final String? currentGroup;

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.groups,
    this.currentGroup,
  });

  // Business-Logik
  bool get hasActiveGroup => currentGroup != null && currentGroup!.isNotEmpty;

  bool get hasGroups => groups.isNotEmpty;

  bool isMemberOf(String groupId) => groups.contains(groupId);

  int get groupCount => groups.length;

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
      email: email ?? this.email,
      groups: groups ?? this.groups,
      currentGroup: currentGroup ?? this.currentGroup,
    );
  }

  User addGroup(String groupId) {
    if (groups.contains(groupId)) return this;
    return copyWith(
      groups: [...groups, groupId],
      currentGroup: currentGroup ?? groupId,
    );
  }

  User removeGroup(String groupId) {
    final newGroups = groups.where((g) => g != groupId).toList();
    String? newCurrentGroup = currentGroup;

    if (currentGroup == groupId) {
      newCurrentGroup = newGroups.isEmpty ? null : newGroups.first;
    }

    return copyWith(
      groups: newGroups,
      currentGroup: newCurrentGroup,
    );
  }

  User setActiveGroup(String groupId) {
    if (!groups.contains(groupId)) {
      throw Exception('User ist nicht Mitglied dieser Gruppe');
    }
    return copyWith(currentGroup: groupId);
  }

  @override
  String toString() {
    return 'User(uid: $uid, name: $name, email: $email, groups: ${groups.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
