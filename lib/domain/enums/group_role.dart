enum GroupRole {
  admin,
  member;

  static GroupRole fromString(String value) {
    return switch (value) {
      'admin' => GroupRole.admin,
      _ => GroupRole.member,
    };
  }
}
