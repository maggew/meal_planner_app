-- Fix categories RLS policies: add group_id check to prevent cross-group access.
-- Previously, any authenticated group member could read/write ALL categories
-- regardless of which group they belonged to.

-- SELECT
DROP POLICY "group members can read categories" ON "public"."categories";
CREATE POLICY "group members can read categories" ON "public"."categories"
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM "public"."group_members" "gm"
      WHERE "gm"."user_id"::text = "public"."supabase_uid"()
        AND "gm"."group_id" = "categories"."group_id"
    )
  );

-- INSERT
DROP POLICY "group members can insert categories" ON "public"."categories";
CREATE POLICY "group members can insert categories" ON "public"."categories"
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM "public"."group_members" "gm"
      WHERE "gm"."user_id"::text = "public"."supabase_uid"()
        AND "gm"."group_id" = "categories"."group_id"
    )
  );

-- UPDATE
DROP POLICY "group members can update categories" ON "public"."categories";
CREATE POLICY "group members can update categories" ON "public"."categories"
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM "public"."group_members" "gm"
      WHERE "gm"."user_id"::text = "public"."supabase_uid"()
        AND "gm"."group_id" = "categories"."group_id"
    )
  );

-- DELETE
DROP POLICY "group members can delete categories" ON "public"."categories";
CREATE POLICY "group members can delete categories" ON "public"."categories"
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM "public"."group_members" "gm"
      WHERE "gm"."user_id"::text = "public"."supabase_uid"()
        AND "gm"."group_id" = "categories"."group_id"
    )
  );
