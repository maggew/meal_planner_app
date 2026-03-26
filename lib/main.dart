import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meal_planner/core/env/env.dart';
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
import 'package:meal_planner/services/meal_plan/meal_plan_sync_observer.dart';
import 'package:meal_planner/services/subscription/subscription_refresh_observer.dart';
import 'package:meal_planner/services/providers/meal_plan/meal_plan_sync_provider.dart';
import 'package:meal_planner/services/providers/shopping_list/shopping_list_sync_provider.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/providers/user/user_settings_provider.dart';
import 'package:meal_planner/services/shopping_list/shopping_list_sync_observer.dart';
import 'package:meal_planner/services/timer_lifecycle_observer.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz_local;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meal_planner/core/security/pinned_http_client.dart';
import 'package:meal_planner/services/providers/shared_preferences_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    runApp(ErrorApp('Firebase init failed: $e'));
    return;
  }

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      httpClient: PinnedHttpClientFactory.createSupabaseClient(),
      accessToken: () async {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser == null) return null;
        return await firebaseUser.getIdToken(true);
      });
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final prefs = await SharedPreferences.getInstance();

  tz.initializeTimeZones();
  final deviceTimeZone = await FlutterTimezone.getLocalTimezone();
  tz_local.setLocalLocation(tz_local.getLocation(deviceTimeZone.identifier));

  // TODO(security): Replace test AdMob IDs with production IDs before store release.
  //  Affected: AndroidManifest.xml, ios/Runner/Info.plist, native_ad_widget.dart.
  await MobileAds.instance.initialize();

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

class ErrorApp extends StatelessWidget {
  final String message;
  const ErrorApp(this.message, {super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(message, style: TextStyle(color: Colors.red)),
        )),
      ),
    );
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final TimerLifecycleObserver _lifecycleObserver;
  late final ShoppingListSyncObserver _shoppingListSyncObserver;
  late final MealPlanSyncObserver _mealPlanSyncObserver;
  late final SubscriptionRefreshObserver _subscriptionRefreshObserver;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = ref.read(appRouterProvider);

    _lifecycleObserver = TimerLifecycleObserver(ref);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);

    _shoppingListSyncObserver = ShoppingListSyncObserver(ref);
    WidgetsBinding.instance.addObserver(_shoppingListSyncObserver);

    _mealPlanSyncObserver = MealPlanSyncObserver(ref);
    WidgetsBinding.instance.addObserver(_mealPlanSyncObserver);

    _subscriptionRefreshObserver = SubscriptionRefreshObserver(ref);
    WidgetsBinding.instance.addObserver(_subscriptionRefreshObserver);

    NotificationService.instance.onNotificationTapped = _onTimerTapped;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    WidgetsBinding.instance.removeObserver(_shoppingListSyncObserver);
    WidgetsBinding.instance.removeObserver(_mealPlanSyncObserver);
    WidgetsBinding.instance.removeObserver(_subscriptionRefreshObserver);
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

    // Prüfen ob wir schon auf dem richtigen Rezept sind
    final stack = _appRouter.stack;
    if (stack.isNotEmpty) {
      final topRoute = stack.last;
      if (topRoute.name == ShowRecipeRoute.name) {
        final args = topRoute.routeData.args as ShowRecipeRouteArgs?;
        if (args != null &&
            (args.recipeId == recipeId || args.recipe?.id == recipeId)) {
          return; // Schon auf dem richtigen Rezept
        }
      }
    }

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
          ref.read(sessionProvider.notifier).reloadActiveGroup();
          ref.read(shoppingListSyncServiceProvider).sync();
          final now = DateTime.now();
          ref.read(mealPlanSyncServiceProvider).sync(now.year, now.month);
        }
      });
    });

    return MaterialApp.router(
      title: 'Meal Planner',
      locale: const Locale('de'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('de'), Locale('en')],
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
