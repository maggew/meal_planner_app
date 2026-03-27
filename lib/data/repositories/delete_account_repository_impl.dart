import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/env/env.dart';
import 'package:meal_planner/domain/repositories/delete_account_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteAccountRepositoryImpl implements DeleteAccountRepository {
  final AppDatabase _db;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final SupabaseClient _supabase;

  DeleteAccountRepositoryImpl({
    required AppDatabase db,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
    required SupabaseClient supabase,
  })  : _db = db,
        _auth = auth,
        _googleSignIn = googleSignIn,
        _supabase = supabase;

  @override
  bool get requiresPasswordReauth {
    final user = _auth.currentUser;
    return user?.providerData.any((p) => p.providerId == 'password') ?? true;
  }

  @override
  Future<void> deleteAccount({String? password}) async {
    await _reauthenticate(password: password);
    await _supabase.functions.invoke('delete-account');
    await _auth.currentUser?.delete();
    await _db.delete(_db.localShoppingItems).go();
    await _db.delete(_db.localRecipes).go();
    await _db.delete(_db.localMealPlanEntries).go();
  }

  Future<void> _reauthenticate({String? password}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    if (requiresPasswordReauth) {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password!,
      );
      await user.reauthenticateWithCredential(credential);
    } else {
      await _googleSignIn.initialize(
          serverClientId: Env.googleLoginServerClientId);
      final googleUser = await _googleSignIn.authenticate();
      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
      );
      await user.reauthenticateWithCredential(credential);
    }
  }
}
