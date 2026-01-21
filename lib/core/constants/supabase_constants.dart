class SupabaseConstants {
  SupabaseConstants._();

  // Tables
  static const String groupsTable = 'groups';
  static const String groupMembersTable = 'group_members';
  static const String recipesTable = 'recipes';
  static const String ingredientsTable = 'ingredients';
  static const String recipeIngredientsTable = 'recipe_ingredients';
  static const String usersTable = 'users';
  static const String categoriesTable = 'categories';
  static const String recipeCategoriesTable = 'recipe_categories';

  // Columns: Groups
  static const String groupId = 'id';
  static const String groupName = 'name';
  static const String groupImageUrl = 'image_url';

  // Columns: Group Members
  static const String memberGroupId = 'group_id';
  static const String memberUserId = 'user_id';
  static const String memberRole = 'role';

  // Columns: Users
  static const String userId = 'id';
  static const String userName = 'name';
  static const String userCurrentGroup = 'current_group';

  // Columns: Roles
  static const String roleAdmin = 'admin';
  static const String roleMember = 'member';

  // Columns: Recipes
  static const String recipeId = 'id';
  static const String recipeGroupId = 'group_id';
  static const String recipeTitle = 'title';
  static const String recipeCategory = 'category';
  static const String recipePortions = 'portions';
  static const String recipeInstructions = 'instructions';
  static const String recipeCreatedBy = 'created_by';
  static const String recipeImageUrl = 'image_url';
  static const String recipeCreatedAt = 'created_at';

  // Columns: Ingredients
  static const String ingredientId = 'id';
  static const String ingredientName = 'name';

  // Columns: Recipe Ingredients
  static const String recipeIngredientRecipeId = 'recipe_id';
  static const String recipeIngredientIngredientId = 'ingredient_id';
  static const String recipeIngredientAmount = 'amount';
  static const String recipeIngredientUnit = 'unit';
  static const String recipeIngredientSortOrder = 'sort_order';
  static const String recipeIngredientGroupName = 'group_name';

  // Columns: Categories
  static const String categoryId = 'id';
  static const String categoryName = 'name';

  // Columns: Recipe Categories
  static const String recipeCategoryRecipeId = 'recipe_id';
  static const String recipeCategoryCategoryId = 'category_id';
}
