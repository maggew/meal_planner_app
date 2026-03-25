-- Allow users to remove themselves from a group
CREATE POLICY "users can leave groups"
  ON group_members FOR DELETE
  USING ((user_id)::text = supabase_uid());
