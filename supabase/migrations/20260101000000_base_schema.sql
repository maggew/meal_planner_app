


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE OR REPLACE FUNCTION "public"."debug_group_members"() RETURNS TABLE("group_id" "uuid", "user_id" "text", "jwt_sub" "text", "user_firebase_uid" "text")
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  SELECT 
    gm.group_id,
    gm.user_id,
    (current_setting('request.jwt.claims', true)::json ->> 'sub')::text,
    u.firebase_uid
  FROM group_members gm
  JOIN users u ON u.id::text = gm.user_id
$$;


ALTER FUNCTION "public"."debug_group_members"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."debug_jwt"() RETURNS json
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  SELECT current_setting('request.jwt.claims', true)::json;
$$;


ALTER FUNCTION "public"."debug_jwt"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_group_ids"() RETURNS SETOF "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT gm.group_id
  FROM group_members gm
  WHERE gm.user_id::text = public.supabase_uid();
$$;


ALTER FUNCTION "public"."get_user_group_ids"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."supabase_uid"() RETURNS "text"
    LANGUAGE "sql" STABLE
    AS $$
  SELECT ((current_setting('request.jwt.claims', true))::json ->> 'supabase_uid');
$$;


ALTER FUNCTION "public"."supabase_uid"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."categories" (
    "id" "uuid" NOT NULL,
    "name" "text",
    "group_id" "uuid" NOT NULL,
    "sort_order" integer DEFAULT 0 NOT NULL,
    "icon_name" "text"
);


ALTER TABLE "public"."categories" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."cleanup_log" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "job_name" "text" NOT NULL,
    "table_name" "text" NOT NULL,
    "row_id" "uuid" NOT NULL,
    "deleted_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."cleanup_log" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."group_members" (
    "group_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "role" "text"
);


ALTER TABLE "public"."group_members" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."groups" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "image_url" "text" DEFAULT ''::"text" NOT NULL,
    "week_start_day" "text" DEFAULT 'monday'::"text" NOT NULL,
    "default_meal_slots" "jsonb" DEFAULT '["breakfast", "lunch", "dinner"]'::"jsonb" NOT NULL,
    "rotation_weight" integer DEFAULT 3 NOT NULL,
    "carb_variety_weight" integer DEFAULT 2 NOT NULL
);


ALTER TABLE "public"."groups" OWNER TO "postgres";


COMMENT ON TABLE "public"."groups" IS 'Holds all the groups which were created by users';



CREATE TABLE IF NOT EXISTS "public"."ingredients" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL
);


ALTER TABLE "public"."ingredients" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."meal_plan_entries" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "group_id" "uuid" NOT NULL,
    "recipe_id" "uuid",
    "date" "date" NOT NULL,
    "meal_type" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "custom_name" "text",
    "cook_ids" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    CONSTRAINT "meal_plan_entries_meal_type_check" CHECK (("meal_type" = ANY (ARRAY['breakfast'::"text", 'lunch'::"text", 'dinner'::"text"])))
);


ALTER TABLE "public"."meal_plan_entries" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."recipe_categories" (
    "recipe_id" "uuid" NOT NULL,
    "category_id" "uuid" NOT NULL
);


ALTER TABLE "public"."recipe_categories" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."recipe_ingredients" (
    "recipe_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "ingredient_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "amount" "text",
    "unit" "text",
    "sort_order" integer DEFAULT 0,
    "group_name" "text" DEFAULT 'Zutaten'::"text" NOT NULL
);


ALTER TABLE "public"."recipe_ingredients" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."recipe_timers" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "recipe_id" "uuid" NOT NULL,
    "step_index" integer NOT NULL,
    "timer_name" "text" DEFAULT ''::"text" NOT NULL,
    "duration_seconds" integer NOT NULL
);


ALTER TABLE "public"."recipe_timers" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."recipes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "group_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "title" "text" DEFAULT ''::"text" NOT NULL,
    "instructions" "text" DEFAULT ''::"text" NOT NULL,
    "image_url" "text" DEFAULT ''::"text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "text",
    "portions" integer DEFAULT 4,
    "deleted_at" timestamp without time zone,
    "times_cooked" integer DEFAULT 0 NOT NULL,
    "carb_tags" "jsonb" DEFAULT '[]'::"jsonb"
);


ALTER TABLE "public"."recipes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."shopping_list_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "group_id" "uuid" NOT NULL,
    "information" "text" DEFAULT ''::"text" NOT NULL,
    "is_checked" boolean DEFAULT false NOT NULL,
    "quantity" "text"
);

ALTER TABLE ONLY "public"."shopping_list_items" REPLICA IDENTITY FULL;


ALTER TABLE "public"."shopping_list_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users" (
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "firebase_uid" "text" NOT NULL,
    "email" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "image_url" "text"
);


ALTER TABLE "public"."users" OWNER TO "postgres";


ALTER TABLE ONLY "public"."categories"
    ADD CONSTRAINT "categories_group_name_key" UNIQUE ("group_id", "name");



ALTER TABLE ONLY "public"."categories"
    ADD CONSTRAINT "categories_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."cleanup_log"
    ADD CONSTRAINT "cleanup_log_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."group_members"
    ADD CONSTRAINT "group_members_pkey" PRIMARY KEY ("group_id", "user_id");



ALTER TABLE ONLY "public"."groups"
    ADD CONSTRAINT "groups_id_key" UNIQUE ("id");



ALTER TABLE ONLY "public"."groups"
    ADD CONSTRAINT "groups_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ingredients"
    ADD CONSTRAINT "ingredients_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."ingredients"
    ADD CONSTRAINT "ingredients_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."meal_plan_entries"
    ADD CONSTRAINT "meal_plan_entries_group_id_date_meal_type_key" UNIQUE ("group_id", "date", "meal_type");



ALTER TABLE ONLY "public"."meal_plan_entries"
    ADD CONSTRAINT "meal_plan_entries_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."recipe_categories"
    ADD CONSTRAINT "recipe_categories_pkey" PRIMARY KEY ("recipe_id", "category_id");



ALTER TABLE ONLY "public"."recipe_timers"
    ADD CONSTRAINT "recipe_timers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."recipe_timers"
    ADD CONSTRAINT "recipe_timers_recipe_id_step_index_key" UNIQUE ("recipe_id", "step_index");



ALTER TABLE ONLY "public"."recipes"
    ADD CONSTRAINT "recipes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."shopping_list_items"
    ADD CONSTRAINT "shopping_list_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_firebase_uid_key" UNIQUE ("firebase_uid");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



CREATE INDEX "categories_group_id_idx" ON "public"."categories" USING "btree" ("group_id");



CREATE INDEX "idx_group_members_user_id" ON "public"."group_members" USING "btree" ("user_id");



CREATE INDEX "idx_recipes_group_id" ON "public"."recipes" USING "btree" ("group_id");



CREATE INDEX "idx_shopping_list_items_group_id" ON "public"."shopping_list_items" USING "btree" ("group_id");



ALTER TABLE ONLY "public"."categories"
    ADD CONSTRAINT "categories_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."recipe_categories"
    ADD CONSTRAINT "fk_recipe_categories_category" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id");



ALTER TABLE ONLY "public"."recipe_categories"
    ADD CONSTRAINT "fk_recipe_categories_recipe" FOREIGN KEY ("recipe_id") REFERENCES "public"."recipes"("id");



ALTER TABLE ONLY "public"."recipe_ingredients"
    ADD CONSTRAINT "fk_recipe_ingredients_ingredient" FOREIGN KEY ("ingredient_id") REFERENCES "public"."ingredients"("id");



ALTER TABLE ONLY "public"."recipe_ingredients"
    ADD CONSTRAINT "fk_recipe_ingredients_recipe" FOREIGN KEY ("recipe_id") REFERENCES "public"."recipes"("id");



ALTER TABLE ONLY "public"."group_members"
    ADD CONSTRAINT "group_members_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."group_members"
    ADD CONSTRAINT "group_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."meal_plan_entries"
    ADD CONSTRAINT "meal_plan_entries_recipe_id_fkey" FOREIGN KEY ("recipe_id") REFERENCES "public"."recipes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."recipe_timers"
    ADD CONSTRAINT "recipe_timers_recipe_id_fkey" FOREIGN KEY ("recipe_id") REFERENCES "public"."recipes"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."recipes"
    ADD CONSTRAINT "recipes_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."shopping_list_items"
    ADD CONSTRAINT "shopping_list_items_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id");



CREATE POLICY "authenticated users can create groups" ON "public"."groups" FOR INSERT WITH CHECK (("public"."supabase_uid"() IS NOT NULL));



CREATE POLICY "authenticated users can join groups" ON "public"."group_members" FOR INSERT WITH CHECK ((("user_id")::"text" = "public"."supabase_uid"()));



CREATE POLICY "authenticated users can read users" ON "public"."users" FOR SELECT USING (("public"."supabase_uid"() IS NOT NULL));



ALTER TABLE "public"."categories" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "group admins can update their group" ON "public"."groups" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."group_id" = "groups"."id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"()) AND ("gm"."role" = 'admin'::"text")))));



CREATE POLICY "group admins hard delete recipes" ON "public"."recipes" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."group_id" = "recipes"."group_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"()) AND ("gm"."role" = 'admin'::"text")))));



CREATE POLICY "group members can delete categories" ON "public"."categories" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."user_id")::"text" = "public"."supabase_uid"()))));



CREATE POLICY "group members can delete recipe_categories" ON "public"."recipe_categories" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM ("public"."recipes" "r"
     JOIN "public"."group_members" "gm" ON (("gm"."group_id" = "r"."group_id")))
  WHERE (("r"."id" = "recipe_categories"."recipe_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))));



CREATE POLICY "group members can delete recipe_ingredients" ON "public"."recipe_ingredients" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM ("public"."recipes" "r"
     JOIN "public"."group_members" "gm" ON (("gm"."group_id" = "r"."group_id")))
  WHERE (("r"."id" = "recipe_ingredients"."recipe_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))));



CREATE POLICY "group members can delete shopping_list_items" ON "public"."shopping_list_items" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."group_id" = "shopping_list_items"."group_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))));



CREATE POLICY "group members can insert categories" ON "public"."categories" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."user_id")::"text" = "public"."supabase_uid"()))));



CREATE POLICY "group members can insert ingredients" ON "public"."ingredients" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."user_id")::"text" = "public"."supabase_uid"()))));



CREATE POLICY "group members can insert recipe categories" ON "public"."recipe_categories" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM ("public"."recipes" "r"
     JOIN "public"."group_members" "gm" ON (("gm"."group_id" = "r"."group_id")))
  WHERE (("r"."id" = "recipe_categories"."recipe_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))));



CREATE POLICY "group members can insert recipe_ingredients" ON "public"."recipe_ingredients" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM ("public"."recipes" "r"
     JOIN "public"."group_members" "gm" ON (("gm"."group_id" = "r"."group_id")))
  WHERE (("r"."id" = "recipe_ingredients"."recipe_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))));



CREATE POLICY "group members can insert shopping_list_items" ON "public"."shopping_list_items" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."group_id" = "shopping_list_items"."group_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))));



CREATE POLICY "group members can read categories" ON "public"."categories" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."user_id")::"text" = "public"."supabase_uid"()))));



CREATE POLICY "group members can read ingredients" ON "public"."ingredients" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."user_id")::"text" = "public"."supabase_uid"()))));



CREATE POLICY "group members can read recipe categories" ON "public"."recipe_categories" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."recipes" "r"
     JOIN "public"."group_members" "gm" ON (("gm"."group_id" = "r"."group_id")))
  WHERE (("r"."id" = "recipe_categories"."recipe_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))));



CREATE POLICY "group members can read recipe_ingredients" ON "public"."recipe_ingredients" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."recipes" "r"
     JOIN "public"."group_members" "gm" ON (("gm"."group_id" = "r"."group_id")))
  WHERE (("r"."id" = "recipe_ingredients"."recipe_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))));



CREATE POLICY "group members can read shopping_list_items" ON "public"."shopping_list_items" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."group_id" = "shopping_list_items"."group_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))));



CREATE POLICY "group members can update carb tags" ON "public"."groups" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."group_id" = "groups"."id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"()))))) WITH CHECK (true);



CREATE POLICY "group members can update categories" ON "public"."categories" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."user_id")::"text" = "public"."supabase_uid"()))));



CREATE POLICY "group members can update shopping_list_items" ON "public"."shopping_list_items" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."group_id" = "shopping_list_items"."group_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))));



CREATE POLICY "group members delete recipe timers" ON "public"."recipe_timers" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM ("public"."recipes" "r"
     JOIN "public"."group_members" "gm" ON (("gm"."group_id" = "r"."group_id")))
  WHERE (("r"."id" = "recipe_timers"."recipe_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))));



CREATE POLICY "group members insert recipe timers" ON "public"."recipe_timers" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM ("public"."recipes" "r"
     JOIN "public"."group_members" "gm" ON (("gm"."group_id" = "r"."group_id")))
  WHERE (("r"."id" = "recipe_timers"."recipe_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))));



CREATE POLICY "group members insert recipes" ON "public"."recipes" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."group_id" = "recipes"."group_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))));



CREATE POLICY "group members read active recipes" ON "public"."recipes" FOR SELECT USING ((("deleted_at" IS NULL) AND (EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."group_id" = "recipes"."group_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"()))))));



CREATE POLICY "group members read deleted recipes" ON "public"."recipes" FOR SELECT USING ((("deleted_at" IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."group_id" = "recipes"."group_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"()))))));



CREATE POLICY "group members read recipe timers" ON "public"."recipe_timers" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM ("public"."recipes" "r"
     JOIN "public"."group_members" "gm" ON (("gm"."group_id" = "r"."group_id")))
  WHERE (("r"."id" = "recipe_timers"."recipe_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))));



CREATE POLICY "group members update recipe timers" ON "public"."recipe_timers" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM ("public"."recipes" "r"
     JOIN "public"."group_members" "gm" ON (("gm"."group_id" = "r"."group_id")))
  WHERE (("r"."id" = "recipe_timers"."recipe_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))));



CREATE POLICY "group members update recipes" ON "public"."recipes" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."group_id" = "recipes"."group_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))));



ALTER TABLE "public"."group_members" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."groups" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."ingredients" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "meal_plan_delete_policy" ON "public"."meal_plan_entries" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."group_id" = "meal_plan_entries"."group_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))));



ALTER TABLE "public"."meal_plan_entries" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "meal_plan_insert_policy" ON "public"."meal_plan_entries" FOR INSERT WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."group_id" = "meal_plan_entries"."group_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))));



CREATE POLICY "meal_plan_select_policy" ON "public"."meal_plan_entries" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."group_id" = "meal_plan_entries"."group_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))));



CREATE POLICY "meal_plan_update_policy" ON "public"."meal_plan_entries" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."group_id" = "meal_plan_entries"."group_id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))));



CREATE POLICY "members can read group" ON "public"."groups" FOR SELECT USING (((EXISTS ( SELECT 1
   FROM "public"."group_members" "gm"
  WHERE (("gm"."group_id" = "groups"."id") AND (("gm"."user_id")::"text" = "public"."supabase_uid"())))) OR ("public"."supabase_uid"() IS NOT NULL)));



CREATE POLICY "members can see same group members" ON "public"."group_members" FOR SELECT USING (("group_id" IN ( SELECT "public"."get_user_group_ids"() AS "get_user_group_ids")));



ALTER TABLE "public"."recipe_categories" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."recipe_ingredients" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."recipe_timers" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."recipes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."shopping_list_items" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "users can update own profile" ON "public"."users" FOR UPDATE USING ((("id")::"text" = "public"."supabase_uid"())) WITH CHECK ((("id")::"text" = "public"."supabase_uid"()));



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."debug_group_members"() TO "anon";
GRANT ALL ON FUNCTION "public"."debug_group_members"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."debug_group_members"() TO "service_role";



GRANT ALL ON FUNCTION "public"."debug_jwt"() TO "anon";
GRANT ALL ON FUNCTION "public"."debug_jwt"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."debug_jwt"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_group_ids"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_group_ids"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_group_ids"() TO "service_role";



GRANT ALL ON FUNCTION "public"."supabase_uid"() TO "anon";
GRANT ALL ON FUNCTION "public"."supabase_uid"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."supabase_uid"() TO "service_role";



GRANT ALL ON TABLE "public"."categories" TO "anon";
GRANT ALL ON TABLE "public"."categories" TO "authenticated";
GRANT ALL ON TABLE "public"."categories" TO "service_role";



GRANT ALL ON TABLE "public"."cleanup_log" TO "anon";
GRANT ALL ON TABLE "public"."cleanup_log" TO "authenticated";
GRANT ALL ON TABLE "public"."cleanup_log" TO "service_role";



GRANT ALL ON TABLE "public"."group_members" TO "anon";
GRANT ALL ON TABLE "public"."group_members" TO "authenticated";
GRANT ALL ON TABLE "public"."group_members" TO "service_role";



GRANT ALL ON TABLE "public"."groups" TO "anon";
GRANT ALL ON TABLE "public"."groups" TO "authenticated";
GRANT ALL ON TABLE "public"."groups" TO "service_role";



GRANT ALL ON TABLE "public"."ingredients" TO "anon";
GRANT ALL ON TABLE "public"."ingredients" TO "authenticated";
GRANT ALL ON TABLE "public"."ingredients" TO "service_role";



GRANT ALL ON TABLE "public"."meal_plan_entries" TO "anon";
GRANT ALL ON TABLE "public"."meal_plan_entries" TO "authenticated";
GRANT ALL ON TABLE "public"."meal_plan_entries" TO "service_role";



GRANT ALL ON TABLE "public"."recipe_categories" TO "anon";
GRANT ALL ON TABLE "public"."recipe_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."recipe_categories" TO "service_role";



GRANT ALL ON TABLE "public"."recipe_ingredients" TO "anon";
GRANT ALL ON TABLE "public"."recipe_ingredients" TO "authenticated";
GRANT ALL ON TABLE "public"."recipe_ingredients" TO "service_role";



GRANT ALL ON TABLE "public"."recipe_timers" TO "anon";
GRANT ALL ON TABLE "public"."recipe_timers" TO "authenticated";
GRANT ALL ON TABLE "public"."recipe_timers" TO "service_role";



GRANT ALL ON TABLE "public"."recipes" TO "anon";
GRANT ALL ON TABLE "public"."recipes" TO "authenticated";
GRANT ALL ON TABLE "public"."recipes" TO "service_role";



GRANT ALL ON TABLE "public"."shopping_list_items" TO "anon";
GRANT ALL ON TABLE "public"."shopping_list_items" TO "authenticated";
GRANT ALL ON TABLE "public"."shopping_list_items" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";







