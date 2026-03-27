abstract class DeleteAccountRepository {
  /// Whether the user must provide a password to re-authenticate.
  /// False for OAuth providers (e.g. Google) that re-auth silently.
  bool get requiresPasswordReauth;

  /// Deletes the account: re-authenticates, removes all remote data,
  /// deletes the auth user, and clears local storage.
  Future<void> deleteAccount({String? password});
}
