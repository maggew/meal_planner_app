enum WeekStartDay {
  monday,
  sunday;

  String get displayName => switch (this) {
        WeekStartDay.monday => 'Montag',
        WeekStartDay.sunday => 'Sonntag',
      };
}
