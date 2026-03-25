-- Group invitation links: time-limited, code-based, one active per group
CREATE TABLE IF NOT EXISTS group_invitations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id uuid NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  code text NOT NULL UNIQUE,
  created_by uuid NOT NULL REFERENCES users(id),
  expires_at timestamptz NOT NULL,
  use_count integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT chk_code_length CHECK (char_length(code) = 8)
);

-- One invitation per group (old one is deleted before creating a new one)
CREATE UNIQUE INDEX idx_group_invitations_group ON group_invitations (group_id);

-- RLS
ALTER TABLE group_invitations ENABLE ROW LEVEL SECURITY;

-- Group admins can create invitations
CREATE POLICY "group admins can insert invitations"
  ON group_invitations FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM group_members gm
      WHERE gm.group_id = group_invitations.group_id
        AND (gm.user_id)::text = supabase_uid()
        AND gm.role = 'admin'
    )
  );

-- Group members can read their group's invitations
CREATE POLICY "group members can read invitations"
  ON group_invitations FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM group_members gm
      WHERE gm.group_id = group_invitations.group_id
        AND (gm.user_id)::text = supabase_uid()
    )
  );

-- Group admins can delete (revoke) invitations
CREATE POLICY "group admins can delete invitations"
  ON group_invitations FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM group_members gm
      WHERE gm.group_id = group_invitations.group_id
        AND (gm.user_id)::text = supabase_uid()
        AND gm.role = 'admin'
    )
  );

-- RPC: join group via invite code (validates + inserts atomically)
CREATE OR REPLACE FUNCTION join_group_via_invite(invite_code text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_invitation record;
  v_user_id text;
BEGIN
  v_user_id := supabase_uid();

  IF v_user_id IS NULL THEN
    RETURN json_build_object('error', 'NOT_AUTHENTICATED');
  END IF;

  -- Find valid invitation
  SELECT * INTO v_invitation
  FROM group_invitations
  WHERE code = upper(invite_code)
    AND expires_at > now();

  IF NOT FOUND THEN
    RETURN json_build_object('error', 'INVALID_OR_EXPIRED');
  END IF;

  -- Check if already a member
  IF EXISTS (
    SELECT 1 FROM group_members
    WHERE group_id = v_invitation.group_id
      AND (user_id)::text = v_user_id
  ) THEN
    RETURN json_build_object('error', 'ALREADY_MEMBER', 'group_id', v_invitation.group_id);
  END IF;

  -- Add member
  INSERT INTO group_members (group_id, user_id, role)
  VALUES (v_invitation.group_id, v_user_id::uuid, 'member');

  -- Increment use count
  UPDATE group_invitations
  SET use_count = use_count + 1
  WHERE id = v_invitation.id;

  RETURN json_build_object('success', true, 'group_id', v_invitation.group_id);
END;
$$;
