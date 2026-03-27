import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SERVICE_ROLE_KEY")!
);

Deno.serve(async (req) => {
  try {
    const auth = req.headers.get("authorization");
    if (!auth?.startsWith("Bearer ")) {
      return new Response("Missing Authorization header", { status: 401 });
    }

    const token = auth.replace("Bearer ", "");
    const payload = JSON.parse(atob(token.split(".")[1]));
    const supabaseUid = payload.supabase_uid as string;

    if (!supabaseUid) {
      return new Response("Missing supabase_uid in token", { status: 401 });
    }

    // 1. Nullify created_by on the user's recipes so they remain in shared groups
    await supabase
      .from("recipes")
      .update({ created_by: null })
      .eq("created_by", supabaseUid);

    // 2. Delete groups where the user is the sole member (cascade removes all content)
    const { data: memberships } = await supabase
      .from("group_members")
      .select("group_id")
      .eq("user_id", supabaseUid);

    for (const { group_id } of memberships ?? []) {
      const { count } = await supabase
        .from("group_members")
        .select("*", { count: "exact", head: true })
        .eq("group_id", group_id);

      if (count === 1) {
        await supabase.from("groups").delete().eq("id", group_id);
      }
    }

    // 3. Delete the user row — cascades to group_members entries in remaining groups
    await supabase.from("users").delete().eq("id", supabaseUid);

    return Response.json({ success: true });
  } catch (err) {
    console.error("delete-account error:", err);
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
