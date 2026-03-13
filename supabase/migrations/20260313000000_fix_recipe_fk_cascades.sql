-- Add ON DELETE CASCADE to recipe_ingredients and recipe_categories FKs to recipes.
-- Without this, deleting a group (which cascades to recipes) fails because these
-- tables still reference the recipes being deleted.

ALTER TABLE recipe_ingredients
  DROP CONSTRAINT fk_recipe_ingredients_recipe,
  ADD CONSTRAINT fk_recipe_ingredients_recipe
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE;

ALTER TABLE recipe_categories
  DROP CONSTRAINT fk_recipe_categories_recipe,
  ADD CONSTRAINT fk_recipe_categories_recipe
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE;

ALTER TABLE shopping_list_items
  DROP CONSTRAINT shopping_list_items_group_id_fkey,
  ADD CONSTRAINT shopping_list_items_group_id_fkey
    FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE;
