class FirebaseConstants {
  FirebaseConstants._();

  // Collections
  static const String usersCollection = 'users';
  static const String groupsCollection = 'groups';
  static const String recipesCollection = 'recipes';
  static const String fridgeCollection = 'refrigerator';

  // Storage paths
  static const String imagePathRecipe = 'images/recipes';
  static const String imagePathGroups = 'images/groups';

  // User
  static const String userCurrentGroup = 'current_group';
  static const String userGroupIds = 'groups';
  static const String userName = 'name';

  // Group
  static const String groupId = 'groupID';
  static const String groupImageUrl = 'imageUrl';
  static const String groupMembers = 'members';
  static const String groupName = 'name';

  // Recipe
  static const String recipesInGroups = 'recipes';
  static const String recipeCategory = 'category';
  static const String recipeName = 'name';
  static const String recipePortions = 'portions';
  static const String recipeIngredients = 'ingredients';
  static const String recipeInstructions = 'instructions';
  static const String recipeImage = 'imageUrl';
  static const String recipeCreatedAt = 'createdAt';
}
