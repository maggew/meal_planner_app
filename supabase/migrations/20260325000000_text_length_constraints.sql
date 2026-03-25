-- Add CHECK constraints to enforce maximum text lengths on all user-facing
-- text columns.  These are the server-side counterpart to the client-side
-- LengthLimitingTextInputFormatter limits added in the Flutter app.

-- recipes
ALTER TABLE recipes
  ADD CONSTRAINT chk_recipes_title_len       CHECK (char_length(title)        <= 200),
  ADD CONSTRAINT chk_recipes_instructions_len CHECK (char_length(instructions) <= 10000);

-- ingredients
ALTER TABLE ingredients
  ADD CONSTRAINT chk_ingredients_name_len CHECK (char_length(name) <= 200);

-- recipe_ingredients
ALTER TABLE recipe_ingredients
  ADD CONSTRAINT chk_ri_amount_len     CHECK (char_length(amount)     <= 20),
  ADD CONSTRAINT chk_ri_unit_len       CHECK (char_length(unit)       <= 50),
  ADD CONSTRAINT chk_ri_group_name_len CHECK (char_length(group_name) <= 100);

-- recipe_timers
ALTER TABLE recipe_timers
  ADD CONSTRAINT chk_rt_timer_name_len CHECK (char_length(timer_name) <= 100);

-- groups
ALTER TABLE groups
  ADD CONSTRAINT chk_groups_name_len CHECK (char_length(name) <= 100);

-- users
ALTER TABLE users
  ADD CONSTRAINT chk_users_name_len CHECK (char_length(name) <= 100);

-- categories
ALTER TABLE categories
  ADD CONSTRAINT chk_categories_name_len CHECK (char_length(name) <= 50);

-- shopping_list_items
ALTER TABLE shopping_list_items
  ADD CONSTRAINT chk_sli_information_len CHECK (char_length(information) <= 300),
  ADD CONSTRAINT chk_sli_quantity_len    CHECK (char_length(quantity)    <= 20);

-- meal_plan_entries
ALTER TABLE meal_plan_entries
  ADD CONSTRAINT chk_mpe_custom_name_len CHECK (char_length(custom_name) <= 200);
