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

        /// Geschützter Einstieg
        AutoRoute(
          path: '/',
          page: CookbookRoute.page,
          guards: [authGuard],
        ),

        /// Öffentlich
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: RegistrationRoute.page),

        /// Gruppen
        AutoRoute(page: GroupsRoute.page),
        AutoRoute(page: CreateGroupRoute.page),
        AutoRoute(page: JoinGroupRoute.page),
        AutoRoute(page: GroupCreatedRoute.page),
        AutoRoute(page: ShowUserGroupsRoute.page),

        /// App
        AutoRoute(page: RefrigeratorRoute.page),
        AutoRoute(page: DetailedWeekplanRoute.page),
        AutoRoute(page: ShowRecipeRoute.page),
        AutoRoute(page: AddEditRecipeRoute.page),
        AutoRoute(page: ZoomPictureRoute.page),
      ];
}
