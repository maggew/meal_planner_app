-- Remove debug functions that expose JWT claims and group membership data.
-- These were accessible to anon and authenticated users via SECURITY DEFINER.

DROP FUNCTION IF EXISTS "public"."debug_group_members"();
DROP FUNCTION IF EXISTS "public"."debug_jwt"();
