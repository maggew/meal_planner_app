-- 1. Neue Spalten hinzufügen
ALTER TABLE categories ADD COLUMN group_id uuid REFERENCES groups(id) ON DELETE CASCADE;
ALTER TABLE categories ADD COLUMN sort_order int NOT NULL DEFAULT 0;

-- 2. Altes UNIQUE Constraint entfernen, BEVOR wir Daten duplizieren
--    (sonst scheitert INSERT wegen Duplicate Key auf "name")
ALTER TABLE categories DROP CONSTRAINT IF EXISTS categories_name_key;

-- 3. Bestehende Kategorien pro Gruppe duplizieren
-- Für jede Gruppe: Kopie jeder globalen Kategorie erstellen, recipe_categories updaten
DO $$
DECLARE
  grp RECORD;
  old_cat RECORD;
  new_cat_id uuid;
BEGIN
  FOR grp IN SELECT id FROM groups LOOP
    FOR old_cat IN
      SELECT DISTINCT c.id, c.name
      FROM categories c
      JOIN recipe_categories rc ON rc.category_id = c.id
      JOIN recipes r ON r.id = rc.recipe_id
      WHERE r.group_id = grp.id
        AND c.group_id IS NULL
    LOOP
      new_cat_id := gen_random_uuid();
      INSERT INTO categories (id, name, group_id, sort_order)
      VALUES (new_cat_id, old_cat.name, grp.id, 0);

      UPDATE recipe_categories
      SET category_id = new_cat_id
      FROM recipes
      WHERE recipe_categories.recipe_id = recipes.id
        AND recipes.group_id = grp.id
        AND recipe_categories.category_id = old_cat.id;
    END LOOP;
  END LOOP;
END $$;

-- 4. Bestehende englische Namen auf deutsch umbenennen
UPDATE categories SET name = 'suppen' WHERE name = 'soups';
UPDATE categories SET name = 'salate' WHERE name = 'salads';
UPDATE categories SET name = 'saucen, dips' WHERE name = 'sauces_dips';
UPDATE categories SET name = 'hauptgerichte' WHERE name = 'maindishes';
-- desserts bleibt gleich
UPDATE categories SET name = 'gebäck' WHERE name = 'bakery';
UPDATE categories SET name = 'sonstiges' WHERE name = 'others';

-- 5. Alte globale Kategorien löschen (die ohne group_id)
DELETE FROM categories WHERE group_id IS NULL;

-- 6. group_id NOT NULL machen
ALTER TABLE categories ALTER COLUMN group_id SET NOT NULL;

-- 7. Neues Unique Constraint: (group_id, name)
ALTER TABLE categories ADD CONSTRAINT categories_group_name_key UNIQUE (group_id, name);

-- 8. Index auf group_id für schnelle Abfragen pro Gruppe
CREATE INDEX categories_group_id_idx ON categories (group_id);
