class UserNotFoundException implements Exception {
  final String userId;
  UserNotFoundException(this.userId);

  @override
  String toString() => 'User nicht gefunden: $userId';
}

class UserCreationException implements Exception {
  final String message;
  UserCreationException(this.message);

  @override
  String toString() => 'User konnte nicht erstellt werden: $message';
}

class UserUpdateException implements Exception {
  final String message;
  UserUpdateException(this.message);

  @override
  String toString() => 'User konnte nicht aktualisiert werden: $message';
}
