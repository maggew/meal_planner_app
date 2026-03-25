-- Rate limits for shopping_list_items (200/min), meal_plan_entries (15/min),
-- categories (10/min), and join_group_via_invite RPC (5/min).
--
-- Uses a lightweight tracking table since not all tables have created_at.

-- ============================================================
-- 1. Rate limit tracking table
-- ============================================================

CREATE TABLE public.rate_limit_events (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id text NOT NULL,
  action text NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL
);

CREATE INDEX idx_rate_limit_events_lookup
  ON public.rate_limit_events (user_id, action, created_at);

ALTER TABLE public.rate_limit_events ENABLE ROW LEVEL SECURITY;

-- No RLS policies needed — only accessed via SECURITY DEFINER functions.

-- ============================================================
-- 2. Generic rate limit check function
-- ============================================================

CREATE OR REPLACE FUNCTION public.check_rate_limit(
  p_action text,
  p_max_count integer
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  recent_count integer;
  v_uid text := public.supabase_uid();
BEGIN
  -- Purge stale events (older than 2 minutes)
  DELETE FROM public.rate_limit_events
  WHERE created_at < now() - interval '2 minutes';

  -- Count events in the current window
  SELECT count(*) INTO recent_count
  FROM public.rate_limit_events
  WHERE user_id = v_uid
    AND action = p_action
    AND created_at > now() - interval '1 minute';

  IF recent_count >= p_max_count THEN
    RAISE EXCEPTION 'Rate limit exceeded: max % % per minute', p_max_count, p_action
      USING ERRCODE = 'P0429';
  END IF;

  -- Track this event
  INSERT INTO public.rate_limit_events (user_id, action)
  VALUES (v_uid, p_action);
END;
$$;

-- ============================================================
-- 3. Shopping list items — 200 inserts / minute / user
-- ============================================================

CREATE OR REPLACE FUNCTION public.rate_limit_shopping_list_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  PERFORM public.check_rate_limit('shopping_list_insert', 200);
  RETURN NEW;
END;
$$;

CREATE TRIGGER shopping_list_insert_rate_limit
  BEFORE INSERT ON public.shopping_list_items
  FOR EACH ROW
  EXECUTE FUNCTION public.rate_limit_shopping_list_insert();

-- ============================================================
-- 4. Meal plan entries — 15 inserts / minute / user
-- ============================================================

CREATE OR REPLACE FUNCTION public.rate_limit_meal_plan_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  PERFORM public.check_rate_limit('meal_plan_insert', 15);
  RETURN NEW;
END;
$$;

CREATE TRIGGER meal_plan_insert_rate_limit
  BEFORE INSERT ON public.meal_plan_entries
  FOR EACH ROW
  EXECUTE FUNCTION public.rate_limit_meal_plan_insert();

-- ============================================================
-- 5. Categories — 10 inserts / minute / user
-- ============================================================

CREATE OR REPLACE FUNCTION public.rate_limit_category_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  PERFORM public.check_rate_limit('category_insert', 10);
  RETURN NEW;
END;
$$;

CREATE TRIGGER category_insert_rate_limit
  BEFORE INSERT ON public.categories
  FOR EACH ROW
  EXECUTE FUNCTION public.rate_limit_category_insert();

-- ============================================================
-- 6. join_group_via_invite RPC — 5 calls / minute / user
-- ============================================================

CREATE OR REPLACE FUNCTION join_group_via_invite(invite_code text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_invitation record;
  v_user_id text;
  v_recent_count integer;
BEGIN
  v_user_id := supabase_uid();

  IF v_user_id IS NULL THEN
    RETURN json_build_object('error', 'NOT_AUTHENTICATED');
  END IF;

  -- Rate limit: 5 attempts per minute
  PERFORM public.check_rate_limit('join_group_invite', 5);

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
