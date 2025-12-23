import 'package:auto_route/auto_route.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: LoginRoute.page),
        AutoRoute(page: CookbookRoute.page),
        AutoRoute(page: WelcomeRoute.page, initial: true),
        AutoRoute(page: AuthRoute.page),
        AutoRoute(page: ShowUserGroupsRoute.page),
        AutoRoute(page: RefrigeratorRoute.page),
        AutoRoute(page: RegistrationRoute.page),
        AutoRoute(page: DetailedWeekplanRoute.page),
        AutoRoute(page: AddRecipeFromKeyboardRoute.page),
        AutoRoute(page: CreateGroupRoute.page),
        AutoRoute(page: GroupCreatedRoute.page),
        AutoRoute(page: GroupsRoute.page),
        AutoRoute(page: JoinGroupRoute.page),
        AutoRoute(page: ShowRecipeRoute.page),
        AutoRoute(page: ShowSingleGroupRoute.page),
        AutoRoute(page: ZoomPictureRoute.page),
      ];
}
