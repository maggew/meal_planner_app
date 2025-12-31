import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/theme/app_theme.dart';
import 'package:meal_planner/presentation/router/router.dart';
import 'package:meal_planner/widgets/DismissKeyboard.dart';
import 'package:meal_planner/services/providers/auth_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

//TODO: dart run build_runner build

class MyApp extends ConsumerStatefulWidget {
  final String groupName;

  const MyApp({Key? key, this.groupName = ''}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _appRouter = AppRouter();

  @override
  void initState() {
    super.initState();
    _loadGroupId();
  }

  Future<void> _loadGroupId() async {
    ref.read(loadGroupIdProvider);
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: MaterialApp.router(
        title: 'Meal Planner',
        theme: AppTheme().getAppTheme(),
        routerConfig: _appRouter.config(),
      ),
    );
  }
}

