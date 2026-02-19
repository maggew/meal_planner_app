import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeAuthService {
  StreamSubscription? _tokenSubscription;

  Future<void> initialize() async {
    // Einmalig Token setzen
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final token = await firebaseUser?.getIdToken(true);
    if (token != null) {
      Supabase.instance.client.realtime.setAuth(token);
    }

    // Auto-Refresh bei Token-Erneuerung
    _tokenSubscription?.cancel();
    _tokenSubscription =
        FirebaseAuth.instance.idTokenChanges().listen((user) async {
      if (user != null) {
        final newToken = await user.getIdToken();
        if (newToken != null) {
          Supabase.instance.client.realtime.setAuth(newToken);
        }
      }
    });
  }

  void dispose() {
    _tokenSubscription?.cancel();
    _tokenSubscription = null;
  }
}

final realtimeAuthServiceProvider = Provider<RealtimeAuthService>((ref) {
  final service = RealtimeAuthService();
  ref.onDispose(() => service.dispose());
  return service;
});
