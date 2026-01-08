class SupabaseConstants {
  SupabaseConstants._();

  // Tables
  static const String groupsTable = 'groups';
  static const String groupMembersTable = 'group_members';
  static const String recipesTable = 'recipes';
  static const String ingredientsTable = 'ingredients';
  static const String recipeIngredientsTable = 'recipe_ingredients';

  // Columns: Groups
  static const String groupId = 'id';
  static const String groupName = 'name';
  static const String groupImageUrl = 'image_url';

  // Columns: Group Members
  static const String memberGroupId = 'group_id';
  static const String memberUserId = 'user_id';
  static const String memberRole = 'role';

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleMember = 'member';
}
