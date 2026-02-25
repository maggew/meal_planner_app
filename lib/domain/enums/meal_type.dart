enum MealType {
  breakfast,
  lunch,
  dinner;

  String get value => name; // 'breakfast' | 'lunch' | 'dinner'

  String get displayName => switch (this) {
        MealType.breakfast => 'Frühstück',
        MealType.lunch => 'Mittagessen',
        MealType.dinner => 'Abendessen',
      };

  static MealType fromValue(String value) => switch (value) {
        'breakfast' => MealType.breakfast,
        'lunch' => MealType.lunch,
        'dinner' => MealType.dinner,
        _ => throw ArgumentError('Unknown meal type: $value'),
      };
}
