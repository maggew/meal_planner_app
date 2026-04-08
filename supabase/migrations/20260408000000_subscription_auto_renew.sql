-- Add auto_renew flag to subscriptions.
-- Defaults to true so existing premium rows keep behaving as before.
ALTER TABLE subscriptions
  ADD COLUMN IF NOT EXISTS auto_renew boolean NOT NULL DEFAULT true;
