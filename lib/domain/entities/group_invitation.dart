class GroupInvitation {
  final String id;
  final String groupId;
  final String code;
  final String createdBy;
  final DateTime expiresAt;
  final int useCount;
  final DateTime createdAt;

  GroupInvitation({
    required this.id,
    required this.groupId,
    required this.code,
    required this.createdBy,
    required this.expiresAt,
    required this.useCount,
    required this.createdAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
