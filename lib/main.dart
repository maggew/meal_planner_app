import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import 'package:meal_planner/services/providers/recipe/timer/timer_notification_controller.dart';
import 'package:meal_planner/services/providers/router_provider.dart';
import 'package:meal_planner/services/providers/sync/sync_providers.dart';
import 'package:meal_planner/services/subscription/subscription_refresh_observer.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/providers/user/user_settings_provider.dart';
import 'package:meal_planner/services/timer_lifecycle_observer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz_local;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meal_planner/core/security/pinned_http_client.dart';
import 'package:meal_planner/presentation/common/analytics_consent_sheet.dart';
import 'package:meal_planner/services/providers/consent_provider.dart';
import 'package:meal_planner/services/providers/shared_preferences_provider.dart';

// Port name used by the background isolate to send timer actions directly to
// the main isolate when the app is alive (foreground or inactive).
const _timerActionsPortName = 'timer_actions_port';

// Must be a top-level function — background notification responses run in a
// separate isolate with no Riverpod access.
// If the main isolate is alive, we send directly via IsolateNameServer so the
// action is processed immediately (even while the notification shade is open).
// If the app is fully backgrounded (port not registered), we fall back to
// SharedPreferences so TimerLifecycleObserver can apply it on next resume.
@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(
    NotificationResponse details) async {
  final actionId = details.actionId;
  if (actionId == null) return;

  // Action IDs have format 'type:recipeId:stepIndex' (e.g. 'pause:r1:0')
  final parts = actionId.split(':');
  if (parts.length < 3) return;
  if (!{'pause', 'resume', 'cancel'}.contains(parts[0])) return;
  if (int.tryParse(parts[2]) == null) return;

  // Fast path: main isolate is alive — send directly, no round-trip needed.
  final sendPort = IsolateNameServer.lookupPortByName(_timerActionsPortName);
  if (sendPort != null) {
    sendPort.send(actionId);
    return;
  }

  // Fallback: app is fully backgrounded — store for processing on next resume.
  final prefs = await SharedPreferences.getInstance();
  final pending = prefs.getStringList('pending_timer_actions') ?? [];
  pending.add(actionId);
  await prefs.setStringList('pending_timer_actions', pending);
}

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

  // MobileAds is initialized by ConsentService after the UMP consent flow.
  // TODO(security): Replace test AdMob IDs with production IDs before store release.
  //  Affected: AndroidManifest.xml, ios/Runner/Info.plist, native_ad_widget.dart.

  await NotificationService.instance.initialize(
    onBackgroundResponse: onDidReceiveBackgroundNotificationResponse,
  );
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
  late final SubscriptionRefreshObserver _subscriptionRefreshObserver;
  late final AppRouter _appRouter;
  ReceivePort? _timerActionsPort;

  @override
  void initState() {
    super.initState();
    _appRouter = ref.read(appRouterProvider);

    _lifecycleObserver = TimerLifecycleObserver(ref);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);

    ref.read(timerNotificationControllerProvider);

    // SyncCoordinator owns lifecycle + connectivity sync triggers for both
    // meal plan and shopping list. Pages opt into polling via
    // enable*Polling/disable*Polling in their initState/dispose.
    ref.read(syncCoordinatorProvider).start();

    _subscriptionRefreshObserver = SubscriptionRefreshObserver(ref);
    WidgetsBinding.instance.addObserver(_subscriptionRefreshObserver);

    NotificationService.instance.onNotificationTapped = _onTimerTapped;
    NotificationService.instance.onNotificationActionReceived = _onTimerAction;

    // Register a port so the background notification isolate can send timer
    // actions directly without waiting for the next app resume.
    // Pre-clear first to handle hot-reload / re-init without stale entries.
    IsolateNameServer.removePortNameMapping(_timerActionsPortName);
    _timerActionsPort = ReceivePort();
    IsolateNameServer.registerPortWithName(
      _timerActionsPort!.sendPort,
      _timerActionsPortName,
    );
    _timerActionsPort!.listen((message) {
      if (!mounted) return;
      if (message is String) _onTimerAction(message);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _runConsentFlow());
  }

  Future<void> _runConsentFlow() async {
    // Wait for auth state to be determined so the AuthGuard navigation
    // has already completed before we try to show any dialog.
    await ref.read(authStateProvider.future);

    // Wait one more frame to let the auth-triggered navigation finish.
    final frameCompleter = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => frameCompleter.complete());
    await frameCompleter.future;

    final consentService = ref.read(consentServiceProvider);
    await consentService.applyStoredAnalyticsConsent();
    await consentService.requestAdsConsent();

    if (consentService.analyticsConsentAsked) return;
    if (!mounted) return;

    final ctx = _appRouter.navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;

    final result = await showModalBottomSheet<bool>(
      context: ctx,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => const AnalyticsConsentSheet(),
    );

    if (!ctx.mounted) return;
    await ref
        .read(analyticsConsentProvider.notifier)
        .setConsent(result ?? false);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping(_timerActionsPortName);
    _timerActionsPort?.close();
    _timerActionsPort = null;
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    WidgetsBinding.instance.removeObserver(_subscriptionRefreshObserver);
    super.dispose();
  }

  _onTimerTapped(String payload) {
    final parts = payload.split(':');
    if (parts.length != 2) return;
    final recipeId = parts[0];
    final stepIndex = int.tryParse(parts[1]);
    if (stepIndex == null) return;

    // Stop alarm sound; timer stays visible as "finished" in the cooking mode UI.
    NotificationService.instance.stopAlarmSound();

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

  void _onTimerAction(String actionId) {
    final parts = actionId.split(':');
    if (parts.length < 3) return;
    if (!{'pause', 'resume', 'cancel'}.contains(parts[0])) return;
    final stepIndex = int.tryParse(parts[2]);
    if (stepIndex == null) return;

    final type = parts[0];
    final recipeId = parts[1];
    final key = '$recipeId:$stepIndex';
    final notifier = ref.read(activeTimerProvider.notifier);
    switch (type) {
      case 'pause':
        notifier.pauseTimer(key);
      case 'resume':
        notifier.resumeTimer(key);
      case 'cancel':
        notifier.cancelTimer(key);
    }
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
          // Sync on connectivity restore is owned by SyncCoordinator.
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
