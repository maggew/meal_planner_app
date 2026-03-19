class SuggestionUsage {
  final String groupId;
  final int weekYear;
  final int weekNumber;
  final int usageCount;

  static const int freeWeeklyLimit = 3;
  static const int freeResultLimit = 5;

  const SuggestionUsage({
    required this.groupId,
    required this.weekYear,
    required this.weekNumber,
    this.usageCount = 0,
  });

  bool get limitReached => usageCount >= freeWeeklyLimit;

  SuggestionUsage copyWith({
    String? groupId,
    int? weekYear,
    int? weekNumber,
    int? usageCount,
  }) {
    return SuggestionUsage(
      groupId: groupId ?? this.groupId,
      weekYear: weekYear ?? this.weekYear,
      weekNumber: weekNumber ?? this.weekNumber,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}
