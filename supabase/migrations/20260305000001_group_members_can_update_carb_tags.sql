-- Allow all group members (not just admins) to update show_carb_tags
DROP POLICY IF EXISTS "group admins can update their group" ON groups;

CREATE POLICY "group admins can update their group" ON groups
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM group_members gm
      WHERE gm.group_id = groups.id
        AND gm.user_id::text = supabase_uid()
        AND gm.role = 'admin'
    )
  );

CREATE POLICY "group members can update carb tags" ON groups
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM group_members gm
      WHERE gm.group_id = groups.id
        AND gm.user_id::text = supabase_uid()
    )
  )
  WITH CHECK (true);
