import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/theme/app_theme.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/auth_providers.dart';
import 'package:meal_planner/services/providers/router_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('Supabase environment variables are not set');
  }

  await Firebase.initializeApp();

  await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      accessToken: () async {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser == null) return null;
        return await firebaseUser.getIdToken();
      });
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

//TODO: dart run build_runner watch --delete-conflicting-outputs

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);

    ref.listen(authStateProvider, (prev, next) {
      next.whenData((userId) {
        final wasLoggedIn = prev?.asData?.value != null;
        final isLoggedOut = userId == null;

        if (wasLoggedIn && isLoggedOut) {
          appRouter.replaceAll([const LoginRoute()]);
        }
      });
    });

    return MaterialApp.router(
      title: 'Meal Planner',
      theme: AppTheme().getAppTheme(),
      routerConfig: appRouter.config(),
    );
  }
}

// TODO: supabase policies definieren für production!
