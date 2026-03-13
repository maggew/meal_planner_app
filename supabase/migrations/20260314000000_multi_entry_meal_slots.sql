-- Allow multiple meal plan entries per (group_id, date, meal_type) slot.
ALTER TABLE meal_plan_entries
  DROP CONSTRAINT meal_plan_entries_group_id_date_meal_type_key;
