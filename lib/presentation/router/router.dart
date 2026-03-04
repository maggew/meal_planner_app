import 'package:auto_route/auto_route.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/auth_guard.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter(this.authGuard);

  final AuthGuard authGuard;

  @override
  List<AutoRoute> get routes => [
        /// Welcome / Splash (nur UI)
        AutoRoute(
          page: WelcomeRoute.page,
          initial: true,
        ),

        /// Öffentlich
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: RegistrationRoute.page),

        /// Gruppen
        AutoRoute(page: GroupsRoute.page),
        AutoRoute(page: GroupOnboardingRoute.page),
        AutoRoute(page: CreateGroupRoute.page),
        AutoRoute(page: JoinGroupRoute.page),
        AutoRoute(page: ShowUserGroupsRoute.page),
        AutoRoute(page: ShowSingleGroupRoute.page),
        AutoRoute(page: EditGroupRoute.page),

        /// Shell (geschützter Einstieg mit Bottom Navigation)
        AutoRoute(
          path: '/',
          page: ShellRoute.page,
          guards: [authGuard],
          children: [
            AutoRoute(page: DetailedWeekplanRoute.page),
            AutoRoute(page: CookbookRoute.page),
            AutoRoute(page: ShoppingListRoute.page),
            AutoRoute(page: ProfileRoute.page),
          ],
        ),

        /// Sub-Pages (Root-Level — außerhalb der Shell)
        AutoRoute(page: SettingsRoute.page),
        AutoRoute(page: ShowRecipeRoute.page),
        AutoRoute(
          page: AddEditRecipeRoute.page,
          type: RouteType.custom(
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) => child,
            duration: const Duration(milliseconds: 50),
            reverseDuration: const Duration(milliseconds: 50),
          ),
        ),
        AutoRoute(page: ZoomPictureRoute.page),
        AutoRoute(page: TrashRoute.page),
      ];
}
