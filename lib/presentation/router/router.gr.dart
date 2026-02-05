// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i17;
import 'package:flutter/material.dart' as _i18;
import 'package:meal_planner/domain/entities/recipe.dart' as _i19;
import 'package:meal_planner/presentation/add_edit_recipe/add_edit_recipe_page.dart'
    as _i1;
import 'package:meal_planner/presentation/cookbook/cookbook_page.dart' as _i2;
import 'package:meal_planner/presentation/create_group/create_group_page.dart'
    as _i3;
import 'package:meal_planner/presentation/detailes_weekplan/detailed_weekplan_page.dart'
    as _i4;
import 'package:meal_planner/presentation/group_created/group_created_page.dart'
    as _i5;
import 'package:meal_planner/presentation/group_onboarding/group_onboarding_page.dart'
    as _i6;
import 'package:meal_planner/presentation/groups/groups_page.dart' as _i7;
import 'package:meal_planner/presentation/join_group/join_group_page.dart'
    as _i8;
import 'package:meal_planner/presentation/login/login_page.dart' as _i9;
import 'package:meal_planner/presentation/refrigerator/refrigerator_page.dart'
    as _i10;
import 'package:meal_planner/presentation/registration/registration_page.dart'
    as _i11;
import 'package:meal_planner/presentation/show_recipe/show_recipe_page.dart'
    as _i12;
import 'package:meal_planner/presentation/show_single_group/show_single_group_page.dart'
    as _i13;
import 'package:meal_planner/presentation/show_user_groups/show_user_groups_page.dart'
    as _i14;
import 'package:meal_planner/presentation/welcome/welcome_page.dart' as _i15;
import 'package:meal_planner/presentation/zoom_picture/zoom_pic_page.dart'
    as _i16;

/// generated route for
/// [_i1.AddEditRecipePage]
class AddEditRecipeRoute extends _i17.PageRouteInfo<AddEditRecipeRouteArgs> {
  AddEditRecipeRoute({
    _i18.Key? key,
    _i19.Recipe? existingRecipe,
    List<_i17.PageRouteInfo>? children,
  }) : super(
          AddEditRecipeRoute.name,
          args:
              AddEditRecipeRouteArgs(key: key, existingRecipe: existingRecipe),
          initialChildren: children,
        );

  static const String name = 'AddEditRecipeRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddEditRecipeRouteArgs>(
        orElse: () => const AddEditRecipeRouteArgs(),
      );
      return _i1.AddEditRecipePage(
        key: args.key,
        existingRecipe: args.existingRecipe,
      );
    },
  );
}

class AddEditRecipeRouteArgs {
  const AddEditRecipeRouteArgs({this.key, this.existingRecipe});

  final _i18.Key? key;

  final _i19.Recipe? existingRecipe;

  @override
  String toString() {
    return 'AddEditRecipeRouteArgs{key: $key, existingRecipe: $existingRecipe}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddEditRecipeRouteArgs) return false;
    return key == other.key && existingRecipe == other.existingRecipe;
  }

  @override
  int get hashCode => key.hashCode ^ existingRecipe.hashCode;
}

/// generated route for
/// [_i2.CookbookPage]
class CookbookRoute extends _i17.PageRouteInfo<void> {
  const CookbookRoute({List<_i17.PageRouteInfo>? children})
      : super(CookbookRoute.name, initialChildren: children);

  static const String name = 'CookbookRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i2.CookbookPage();
    },
  );
}

/// generated route for
/// [_i3.CreateGroupPage]
class CreateGroupRoute extends _i17.PageRouteInfo<void> {
  const CreateGroupRoute({List<_i17.PageRouteInfo>? children})
      : super(CreateGroupRoute.name, initialChildren: children);

  static const String name = 'CreateGroupRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i3.CreateGroupPage();
    },
  );
}

/// generated route for
/// [_i4.DetailedWeekplanPage]
class DetailedWeekplanRoute extends _i17.PageRouteInfo<void> {
  const DetailedWeekplanRoute({List<_i17.PageRouteInfo>? children})
      : super(DetailedWeekplanRoute.name, initialChildren: children);

  static const String name = 'DetailedWeekplanRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i4.DetailedWeekplanPage();
    },
  );
}

/// generated route for
/// [_i5.GroupCreatedPage]
class GroupCreatedRoute extends _i17.PageRouteInfo<GroupCreatedRouteArgs> {
  GroupCreatedRoute({
    required String groupName,
    List<_i17.PageRouteInfo>? children,
  }) : super(
          GroupCreatedRoute.name,
          args: GroupCreatedRouteArgs(groupName: groupName),
          initialChildren: children,
        );

  static const String name = 'GroupCreatedRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GroupCreatedRouteArgs>();
      return _i5.GroupCreatedPage(groupName: args.groupName);
    },
  );
}

class GroupCreatedRouteArgs {
  const GroupCreatedRouteArgs({required this.groupName});

  final String groupName;

  @override
  String toString() {
    return 'GroupCreatedRouteArgs{groupName: $groupName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GroupCreatedRouteArgs) return false;
    return groupName == other.groupName;
  }

  @override
  int get hashCode => groupName.hashCode;
}

/// generated route for
/// [_i6.GroupOnboardingPage]
class GroupOnboardingRoute extends _i17.PageRouteInfo<void> {
  const GroupOnboardingRoute({List<_i17.PageRouteInfo>? children})
      : super(GroupOnboardingRoute.name, initialChildren: children);

  static const String name = 'GroupOnboardingRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i6.GroupOnboardingPage();
    },
  );
}

/// generated route for
/// [_i7.GroupsPage]
class GroupsRoute extends _i17.PageRouteInfo<void> {
  const GroupsRoute({List<_i17.PageRouteInfo>? children})
      : super(GroupsRoute.name, initialChildren: children);

  static const String name = 'GroupsRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i7.GroupsPage();
    },
  );
}

/// generated route for
/// [_i8.JoinGroupPage]
class JoinGroupRoute extends _i17.PageRouteInfo<void> {
  const JoinGroupRoute({List<_i17.PageRouteInfo>? children})
      : super(JoinGroupRoute.name, initialChildren: children);

  static const String name = 'JoinGroupRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i8.JoinGroupPage();
    },
  );
}

/// generated route for
/// [_i9.LoginPage]
class LoginRoute extends _i17.PageRouteInfo<void> {
  const LoginRoute({List<_i17.PageRouteInfo>? children})
      : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i9.LoginPage();
    },
  );
}

/// generated route for
/// [_i10.RefrigeratorScreen]
class RefrigeratorRoute extends _i17.PageRouteInfo<void> {
  const RefrigeratorRoute({List<_i17.PageRouteInfo>? children})
      : super(RefrigeratorRoute.name, initialChildren: children);

  static const String name = 'RefrigeratorRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i10.RefrigeratorScreen();
    },
  );
}

/// generated route for
/// [_i11.RegistrationPage]
class RegistrationRoute extends _i17.PageRouteInfo<void> {
  const RegistrationRoute({List<_i17.PageRouteInfo>? children})
      : super(RegistrationRoute.name, initialChildren: children);

  static const String name = 'RegistrationRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i11.RegistrationPage();
    },
  );
}

/// generated route for
/// [_i12.ShowRecipePage]
class ShowRecipeRoute extends _i17.PageRouteInfo<ShowRecipeRouteArgs> {
  ShowRecipeRoute({
    _i18.Key? key,
    required _i19.Recipe recipe,
    required _i18.Image image,
    List<_i17.PageRouteInfo>? children,
  }) : super(
          ShowRecipeRoute.name,
          args: ShowRecipeRouteArgs(key: key, recipe: recipe, image: image),
          initialChildren: children,
        );

  static const String name = 'ShowRecipeRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ShowRecipeRouteArgs>();
      return _i12.ShowRecipePage(
        key: args.key,
        recipe: args.recipe,
        image: args.image,
      );
    },
  );
}

class ShowRecipeRouteArgs {
  const ShowRecipeRouteArgs({
    this.key,
    required this.recipe,
    required this.image,
  });

  final _i18.Key? key;

  final _i19.Recipe recipe;

  final _i18.Image image;

  @override
  String toString() {
    return 'ShowRecipeRouteArgs{key: $key, recipe: $recipe, image: $image}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ShowRecipeRouteArgs) return false;
    return key == other.key && recipe == other.recipe && image == other.image;
  }

  @override
  int get hashCode => key.hashCode ^ recipe.hashCode ^ image.hashCode;
}

/// generated route for
/// [_i13.ShowSingleGroupPage]
class ShowSingleGroupRoute extends _i17.PageRouteInfo<void> {
  const ShowSingleGroupRoute({List<_i17.PageRouteInfo>? children})
      : super(ShowSingleGroupRoute.name, initialChildren: children);

  static const String name = 'ShowSingleGroupRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i13.ShowSingleGroupPage();
    },
  );
}

/// generated route for
/// [_i14.ShowUserGroupsPage]
class ShowUserGroupsRoute extends _i17.PageRouteInfo<void> {
  const ShowUserGroupsRoute({List<_i17.PageRouteInfo>? children})
      : super(ShowUserGroupsRoute.name, initialChildren: children);

  static const String name = 'ShowUserGroupsRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i14.ShowUserGroupsPage();
    },
  );
}

/// generated route for
/// [_i15.WelcomePage]
class WelcomeRoute extends _i17.PageRouteInfo<void> {
  const WelcomeRoute({List<_i17.PageRouteInfo>? children})
      : super(WelcomeRoute.name, initialChildren: children);

  static const String name = 'WelcomeRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i15.WelcomePage();
    },
  );
}

/// generated route for
/// [_i16.ZoomPicturePage]
class ZoomPictureRoute extends _i17.PageRouteInfo<void> {
  const ZoomPictureRoute({List<_i17.PageRouteInfo>? children})
      : super(ZoomPictureRoute.name, initialChildren: children);

  static const String name = 'ZoomPictureRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i16.ZoomPicturePage();
    },
  );
}
