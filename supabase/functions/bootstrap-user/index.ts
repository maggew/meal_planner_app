import "@supabase/functions-js/edge-runtime.d.ts";
import { decode } from "https://deno.land/x/djwt@v3.0.1/mod.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("SERVICE_ROLE_KEY")!;
const supabase = createClient(supabaseUrl, serviceRoleKey);

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID")!;
const FIREBASE_ISSUER = `https://securetoken.google.com/${FIREBASE_PROJECT_ID}`;

function decodeJwtPayload(token: string) {
  const payload = token.split(".")[1];
  return JSON.parse(atob(payload));
}

Deno.serve(async (req) => {
  try {
    const auth = req.headers.get("authorization");
    
    if (!auth) {
      return new Response("No auth header", { status: 400 });
    }
    if (!auth.startsWith("Bearer ")) {
      return new Response("Missing Authorization header", { status: 401 });
    }

    // Request Body lesen (für name)
    let bodyName: string | null = null;
    try {
      const body = await req.json();
      bodyName = body.name ?? null;
    } catch {
      // Kein Body oder kein JSON – ist okay
    }

    const token = auth.replace("Bearer ", "");
    const payloadBase64 = token.split(".")[1];
    const payloadJson = atob(payloadBase64);
    const payload = JSON.parse(payloadJson);

    if (!payload?.sub) {
      return new Response("Invalid Firebase token", { status: 401 });
    }

    const firebaseUid = payload.sub;
    const email = payload.email ?? null;
    // Name aus Body bevorzugen, sonst aus Token (für Google Sign-In)
    const name = bodyName ?? payload.name ?? null;

    // User suchen
    const { data: existingUser, error: selectError } = await supabase
      .from("users")
      .select("id, image_url")
      .eq("firebase_uid", firebaseUid)
      .maybeSingle();

    if (selectError) throw selectError;

    if (existingUser) {
      return Response.json({ 
				user_id: existingUser.id,
				image_url: existingUser.image_url ?? null,
			});
    }

    // User anlegen
    const { data: newUser, error: insertError } = await supabase
      .from("users")
      .insert({
        firebase_uid: firebaseUid,
        email,
        name,
      })
      .select("id")
      .single();

    if (insertError) throw insertError;

    return Response.json({ user_id: newUser.id });
  } catch (err) {
    console.error("Full error:", err);
    return new Response(JSON.stringify({ error: err.message }), { 
      status: 401,
      headers: { "Content-Type": "application/json" }
    });
  }
});

