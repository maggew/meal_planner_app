-- Subscriptions table (one row per group)
CREATE TABLE IF NOT EXISTS subscriptions (
  group_id uuid PRIMARY KEY REFERENCES groups(id) ON DELETE CASCADE,
  status text NOT NULL DEFAULT 'free' CHECK (status IN ('free', 'premium')),
  subscriber_user_id uuid REFERENCES users(id),
  product_id text,
  expires_at timestamptz,
  updated_at timestamptz DEFAULT now()
);

-- RLS: group members can read (uses supabase_uid() for Firebase JWT auth)
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Group members can read subscription"
  ON subscriptions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM group_members gm
      WHERE gm.group_id = subscriptions.group_id
        AND (gm.user_id)::text = supabase_uid()
    )
  );

-- Enable realtime
ALTER PUBLICATION supabase_realtime ADD TABLE subscriptions;

-- Suggestion usage table (tracks weekly usage per group)
CREATE TABLE IF NOT EXISTS suggestion_usage (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id uuid NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  week_year integer NOT NULL,
  week_number integer NOT NULL,
  usage_count integer NOT NULL DEFAULT 0,
  UNIQUE (group_id, week_year, week_number)
);

-- RLS: group members can read and upsert
ALTER TABLE suggestion_usage ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Group members can read suggestion usage"
  ON suggestion_usage FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM group_members gm
      WHERE gm.group_id = suggestion_usage.group_id
        AND (gm.user_id)::text = supabase_uid()
    )
  );

CREATE POLICY "Group members can insert suggestion usage"
  ON suggestion_usage FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM group_members gm
      WHERE gm.group_id = suggestion_usage.group_id
        AND (gm.user_id)::text = supabase_uid()
    )
  );

CREATE POLICY "Group members can update suggestion usage"
  ON suggestion_usage FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM group_members gm
      WHERE gm.group_id = suggestion_usage.group_id
        AND (gm.user_id)::text = supabase_uid()
    )
  );
