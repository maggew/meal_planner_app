class GroupNotFoundException implements Exception {
  final String groupId;
  GroupNotFoundException(this.groupId);

  @override
  String toString() => 'Gruppe nicht gefunden: $groupId';
}

class GroupsNotFoundException implements Exception {
  final String message;
  GroupsNotFoundException(this.message);

  @override
  String toString() => "Keine Gruppen gefunden: $message";
}

class GroupCreationException implements Exception {
  final String message;
  GroupCreationException(this.message);

  @override
  String toString() => 'Gruppe konnte nicht erstellt werden: $message';
}

class GroupUpdateException implements Exception {
  final String message;
  GroupUpdateException(this.message);

  @override
  String toString() => 'Gruppe konnte nicht aktualisiert werden: $message';
}

class GroupMemberException implements Exception {
  final String message;
  GroupMemberException(this.message);

  @override
  String toString() => 'Mitglied konnte nicht hinzugefügt werden: $message';
}

class GroupDeletionException implements Exception {
  final String message;
  GroupDeletionException(this.message);

  @override
  String toString() => 'Gruppe konnte nicht gelöscht werden: $message';
}
