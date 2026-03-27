// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i22;
import 'package:collection/collection.dart' as _i27;
import 'package:flutter/material.dart' as _i23;
import 'package:meal_planner/domain/entities/group.dart' as _i25;
import 'package:meal_planner/domain/entities/recipe.dart' as _i24;
import 'package:meal_planner/domain/enums/meal_type.dart' as _i26;
import 'package:meal_planner/presentation/add_edit_recipe/add_edit_recipe_page.dart'
    as _i1;
import 'package:meal_planner/presentation/cookbook/cookbook_page.dart' as _i2;
import 'package:meal_planner/presentation/create_group/create_group_page.dart'
    as _i3;
import 'package:meal_planner/presentation/detailed_weekplan/detailed_weekplan_page.dart'
    as _i4;
import 'package:meal_planner/presentation/edit_group/edit_group_page.dart'
    as _i5;
import 'package:meal_planner/presentation/group_onboarding/group_onboarding_page.dart'
    as _i6;
import 'package:meal_planner/presentation/groups/groups_page.dart' as _i7;
import 'package:meal_planner/presentation/join_group/join_group_page.dart'
    as _i8;
import 'package:meal_planner/presentation/licenses/licenses_page.dart' as _i9;
import 'package:meal_planner/presentation/login/login_page.dart' as _i10;
import 'package:meal_planner/presentation/profile/profile_page.dart' as _i11;
import 'package:meal_planner/presentation/recipe_suggestion/recipe_suggestion_page.dart'
    as _i12;
import 'package:meal_planner/presentation/registration/registration_page.dart'
    as _i13;
import 'package:meal_planner/presentation/settings/settings_page.dart' as _i14;
import 'package:meal_planner/presentation/shell/shell_page.dart' as _i15;
import 'package:meal_planner/presentation/shopping_list/shopping_list_page.dart'
    as _i16;
import 'package:meal_planner/presentation/show_recipe/show_recipe_page.dart'
    as _i17;
import 'package:meal_planner/presentation/show_single_group/show_single_group_page.dart'
    as _i18;
import 'package:meal_planner/presentation/show_user_groups/show_user_groups_page.dart'
    as _i19;
import 'package:meal_planner/presentation/trash/trash_page.dart' as _i20;
import 'package:meal_planner/presentation/welcome/welcome_page.dart' as _i21;

/// generated route for
/// [_i1.AddEditRecipePage]
class AddEditRecipeRoute extends _i22.PageRouteInfo<AddEditRecipeRouteArgs> {
  AddEditRecipeRoute({
    _i23.Key? key,
    _i24.Recipe? existingRecipe,
    List<_i22.PageRouteInfo>? children,
  }) : super(
          AddEditRecipeRoute.name,
          args:
              AddEditRecipeRouteArgs(key: key, existingRecipe: existingRecipe),
          initialChildren: children,
        );

  static const String name = 'AddEditRecipeRoute';

  static _i22.PageInfo page = _i22.PageInfo(
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

  final _i23.Key? key;

  final _i24.Recipe? existingRecipe;

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
class CookbookRoute extends _i22.PageRouteInfo<void> {
  const CookbookRoute({List<_i22.PageRouteInfo>? children})
      : super(CookbookRoute.name, initialChildren: children);

  static const String name = 'CookbookRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i2.CookbookPage();
    },
  );
}

/// generated route for
/// [_i3.CreateGroupPage]
class CreateGroupRoute extends _i22.PageRouteInfo<void> {
  const CreateGroupRoute({List<_i22.PageRouteInfo>? children})
      : super(CreateGroupRoute.name, initialChildren: children);

  static const String name = 'CreateGroupRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return _i3.CreateGroupPage();
    },
  );
}

/// generated route for
/// [_i4.DetailedWeekplanPage]
class DetailedWeekplanRoute extends _i22.PageRouteInfo<void> {
  const DetailedWeekplanRoute({List<_i22.PageRouteInfo>? children})
      : super(DetailedWeekplanRoute.name, initialChildren: children);

  static const String name = 'DetailedWeekplanRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i4.DetailedWeekplanPage();
    },
  );
}

/// generated route for
/// [_i5.EditGroupPage]
class EditGroupRoute extends _i22.PageRouteInfo<EditGroupRouteArgs> {
  EditGroupRoute({
    _i23.Key? key,
    required _i25.Group group,
    List<_i22.PageRouteInfo>? children,
  }) : super(
          EditGroupRoute.name,
          args: EditGroupRouteArgs(key: key, group: group),
          initialChildren: children,
        );

  static const String name = 'EditGroupRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditGroupRouteArgs>();
      return _i5.EditGroupPage(key: args.key, group: args.group);
    },
  );
}

class EditGroupRouteArgs {
  const EditGroupRouteArgs({this.key, required this.group});

  final _i23.Key? key;

  final _i25.Group group;

  @override
  String toString() {
    return 'EditGroupRouteArgs{key: $key, group: $group}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditGroupRouteArgs) return false;
    return key == other.key && group == other.group;
  }

  @override
  int get hashCode => key.hashCode ^ group.hashCode;
}

/// generated route for
/// [_i6.GroupOnboardingPage]
class GroupOnboardingRoute extends _i22.PageRouteInfo<void> {
  const GroupOnboardingRoute({List<_i22.PageRouteInfo>? children})
      : super(GroupOnboardingRoute.name, initialChildren: children);

  static const String name = 'GroupOnboardingRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return _i6.GroupOnboardingPage();
    },
  );
}

/// generated route for
/// [_i7.GroupsPage]
class GroupsRoute extends _i22.PageRouteInfo<void> {
  const GroupsRoute({List<_i22.PageRouteInfo>? children})
      : super(GroupsRoute.name, initialChildren: children);

  static const String name = 'GroupsRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i7.GroupsPage();
    },
  );
}

/// generated route for
/// [_i8.JoinGroupPage]
class JoinGroupRoute extends _i22.PageRouteInfo<void> {
  const JoinGroupRoute({List<_i22.PageRouteInfo>? children})
      : super(JoinGroupRoute.name, initialChildren: children);

  static const String name = 'JoinGroupRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return _i8.JoinGroupPage();
    },
  );
}

/// generated route for
/// [_i9.LicensesPage]
class LicensesRoute extends _i22.PageRouteInfo<void> {
  const LicensesRoute({List<_i22.PageRouteInfo>? children})
      : super(LicensesRoute.name, initialChildren: children);

  static const String name = 'LicensesRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i9.LicensesPage();
    },
  );
}

/// generated route for
/// [_i10.LoginPage]
class LoginRoute extends _i22.PageRouteInfo<void> {
  const LoginRoute({List<_i22.PageRouteInfo>? children})
      : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i10.LoginPage();
    },
  );
}

/// generated route for
/// [_i11.ProfilePage]
class ProfileRoute extends _i22.PageRouteInfo<void> {
  const ProfileRoute({List<_i22.PageRouteInfo>? children})
      : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i11.ProfilePage();
    },
  );
}

/// generated route for
/// [_i12.RecipeSuggestionPage]
class RecipeSuggestionRoute
    extends _i22.PageRouteInfo<RecipeSuggestionRouteArgs> {
  RecipeSuggestionRoute({
    _i23.Key? key,
    required DateTime referenceDate,
    required _i26.MealType mealType,
    List<String> cookIds = const [],
    List<_i22.PageRouteInfo>? children,
  }) : super(
          RecipeSuggestionRoute.name,
          args: RecipeSuggestionRouteArgs(
            key: key,
            referenceDate: referenceDate,
            mealType: mealType,
            cookIds: cookIds,
          ),
          initialChildren: children,
        );

  static const String name = 'RecipeSuggestionRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RecipeSuggestionRouteArgs>();
      return _i12.RecipeSuggestionPage(
        key: args.key,
        referenceDate: args.referenceDate,
        mealType: args.mealType,
        cookIds: args.cookIds,
      );
    },
  );
}

class RecipeSuggestionRouteArgs {
  const RecipeSuggestionRouteArgs({
    this.key,
    required this.referenceDate,
    required this.mealType,
    this.cookIds = const [],
  });

  final _i23.Key? key;

  final DateTime referenceDate;

  final _i26.MealType mealType;

  final List<String> cookIds;

  @override
  String toString() {
    return 'RecipeSuggestionRouteArgs{key: $key, referenceDate: $referenceDate, mealType: $mealType, cookIds: $cookIds}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RecipeSuggestionRouteArgs) return false;
    return key == other.key &&
        referenceDate == other.referenceDate &&
        mealType == other.mealType &&
        const _i27.ListEquality<String>().equals(cookIds, other.cookIds);
  }

  @override
  int get hashCode =>
      key.hashCode ^
      referenceDate.hashCode ^
      mealType.hashCode ^
      const _i27.ListEquality<String>().hash(cookIds);
}

/// generated route for
/// [_i13.RegistrationPage]
class RegistrationRoute extends _i22.PageRouteInfo<void> {
  const RegistrationRoute({List<_i22.PageRouteInfo>? children})
      : super(RegistrationRoute.name, initialChildren: children);

  static const String name = 'RegistrationRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return _i13.RegistrationPage();
    },
  );
}

/// generated route for
/// [_i14.SettingsPage]
class SettingsRoute extends _i22.PageRouteInfo<void> {
  const SettingsRoute({List<_i22.PageRouteInfo>? children})
      : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i14.SettingsPage();
    },
  );
}

/// generated route for
/// [_i15.ShellPage]
class ShellRoute extends _i22.PageRouteInfo<void> {
  const ShellRoute({List<_i22.PageRouteInfo>? children})
      : super(ShellRoute.name, initialChildren: children);

  static const String name = 'ShellRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i15.ShellPage();
    },
  );
}

/// generated route for
/// [_i16.ShoppingListPage]
class ShoppingListRoute extends _i22.PageRouteInfo<void> {
  const ShoppingListRoute({List<_i22.PageRouteInfo>? children})
      : super(ShoppingListRoute.name, initialChildren: children);

  static const String name = 'ShoppingListRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i16.ShoppingListPage();
    },
  );
}

/// generated route for
/// [_i17.ShowRecipePage]
class ShowRecipeRoute extends _i22.PageRouteInfo<ShowRecipeRouteArgs> {
  ShowRecipeRoute({
    _i23.Key? key,
    _i24.Recipe? recipe,
    _i23.Widget? image,
    String? recipeId,
    int? initialStep,
    List<_i22.PageRouteInfo>? children,
  }) : super(
          ShowRecipeRoute.name,
          args: ShowRecipeRouteArgs(
            key: key,
            recipe: recipe,
            image: image,
            recipeId: recipeId,
            initialStep: initialStep,
          ),
          initialChildren: children,
        );

  static const String name = 'ShowRecipeRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ShowRecipeRouteArgs>(
        orElse: () => const ShowRecipeRouteArgs(),
      );
      return _i17.ShowRecipePage(
        key: args.key,
        recipe: args.recipe,
        image: args.image,
        recipeId: args.recipeId,
        initialStep: args.initialStep,
      );
    },
  );
}

class ShowRecipeRouteArgs {
  const ShowRecipeRouteArgs({
    this.key,
    this.recipe,
    this.image,
    this.recipeId,
    this.initialStep,
  });

  final _i23.Key? key;

  final _i24.Recipe? recipe;

  final _i23.Widget? image;

  final String? recipeId;

  final int? initialStep;

  @override
  String toString() {
    return 'ShowRecipeRouteArgs{key: $key, recipe: $recipe, image: $image, recipeId: $recipeId, initialStep: $initialStep}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ShowRecipeRouteArgs) return false;
    return key == other.key &&
        recipe == other.recipe &&
        image == other.image &&
        recipeId == other.recipeId &&
        initialStep == other.initialStep;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      recipe.hashCode ^
      image.hashCode ^
      recipeId.hashCode ^
      initialStep.hashCode;
}

/// generated route for
/// [_i18.ShowSingleGroupPage]
class ShowSingleGroupRoute
    extends _i22.PageRouteInfo<ShowSingleGroupRouteArgs> {
  ShowSingleGroupRoute({
    _i23.Key? key,
    required _i25.Group group,
    List<_i22.PageRouteInfo>? children,
  }) : super(
          ShowSingleGroupRoute.name,
          args: ShowSingleGroupRouteArgs(key: key, group: group),
          initialChildren: children,
        );

  static const String name = 'ShowSingleGroupRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ShowSingleGroupRouteArgs>();
      return _i18.ShowSingleGroupPage(key: args.key, group: args.group);
    },
  );
}

class ShowSingleGroupRouteArgs {
  const ShowSingleGroupRouteArgs({this.key, required this.group});

  final _i23.Key? key;

  final _i25.Group group;

  @override
  String toString() {
    return 'ShowSingleGroupRouteArgs{key: $key, group: $group}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ShowSingleGroupRouteArgs) return false;
    return key == other.key && group == other.group;
  }

  @override
  int get hashCode => key.hashCode ^ group.hashCode;
}

/// generated route for
/// [_i19.ShowUserGroupsPage]
class ShowUserGroupsRoute extends _i22.PageRouteInfo<void> {
  const ShowUserGroupsRoute({List<_i22.PageRouteInfo>? children})
      : super(ShowUserGroupsRoute.name, initialChildren: children);

  static const String name = 'ShowUserGroupsRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i19.ShowUserGroupsPage();
    },
  );
}

/// generated route for
/// [_i20.TrashPage]
class TrashRoute extends _i22.PageRouteInfo<void> {
  const TrashRoute({List<_i22.PageRouteInfo>? children})
      : super(TrashRoute.name, initialChildren: children);

  static const String name = 'TrashRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return const _i20.TrashPage();
    },
  );
}

/// generated route for
/// [_i21.WelcomePage]
class WelcomeRoute extends _i22.PageRouteInfo<void> {
  const WelcomeRoute({List<_i22.PageRouteInfo>? children})
      : super(WelcomeRoute.name, initialChildren: children);

  static const String name = 'WelcomeRoute';

  static _i22.PageInfo page = _i22.PageInfo(
    name,
    builder: (data) {
      return _i21.WelcomePage();
    },
  );
}
