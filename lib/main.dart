import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/theme/app_theme.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/presentation/router/router.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/notification_service.dart';
import 'package:meal_planner/services/providers/auth_providers.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/router_provider.dart';
import 'package:meal_planner/services/providers/shopping_list/shopping_list_sync_provider.dart';
import 'package:meal_planner/services/providers/user/user_settings_provider.dart';
import 'package:meal_planner/services/shopping_list/shopping_list_sync_observer.dart';
import 'package:meal_planner/services/timer_lifecycle_observer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meal_planner/services/providers/shared_preferences_provider.dart';

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
        return await firebaseUser.getIdToken(true);
      });
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final prefs = await SharedPreferences.getInstance();

  await NotificationService.instance.initialize();
  await NotificationService.instance.requestPermissions();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MyApp(),
    ),
  );
}

//TODO: dart run build_runner watch --delete-conflicting-outputs

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final TimerLifecycleObserver _lifecycleObserver;
  late final ShoppingListSyncObserver _shoppingListSyncObserver;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = ref.read(appRouterProvider);

    _lifecycleObserver = TimerLifecycleObserver(ref);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);

    _shoppingListSyncObserver = ShoppingListSyncObserver(ref);
    WidgetsBinding.instance.addObserver(_shoppingListSyncObserver);

    NotificationService.instance.onNotificationTapped = _onTimerTapped;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    WidgetsBinding.instance.removeObserver(_shoppingListSyncObserver);
    super.dispose();
  }

  _onTimerTapped(String payload) {
    final parts = payload.split(':');
    if (parts.length != 2) return;
    final recipeId = parts[0];
    final stepIndex = int.tryParse(parts[1]);
    if (stepIndex == null) return;

    NotificationService.instance.stopAlarmSound();
    ref.read(activeTimerProvider.notifier).markAsFinished(payload);

    _appRouter.push(ShowRecipeRoute(
      recipeId: recipeId,
      initialStep: stepIndex,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final themeOption =
        ref.watch(userSettingsProvider.select((s) => s.themeOption));

    ref.listen(authStateProvider, (prev, next) {
      next.whenData((userId) {
        final wasLoggedIn = prev?.asData?.value != null;
        final isLoggedOut = userId == null;

        if (wasLoggedIn && isLoggedOut) {
          _appRouter.replaceAll([const LoginRoute()]);
        }
      });
    });

    ref.listen(connectivityProvider, (previous, next) {
      next.whenData((isOnline) {
        final wasOffline = previous?.asData?.value == false;
        if (isOnline && wasOffline) {
          ref.read(shoppingListSyncServiceProvider).syncPendingItems();
        }
      });
    });

    return MaterialApp.router(
      title: 'Meal Planner',
      themeMode: switch (themeOption) {
        ThemeOption.light => ThemeMode.light,
        ThemeOption.dark => ThemeMode.dark,
        ThemeOption.system => ThemeMode.system,
      },
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _appRouter.config(),
      builder: (context, child) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: child,
      ),
    );
  }
}
