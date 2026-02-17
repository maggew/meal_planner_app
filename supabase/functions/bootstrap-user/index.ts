import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ─── Supabase Setup ───
const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("SERVICE_ROLE_KEY")!;
const supabase = createClient(supabaseUrl, serviceRoleKey);

// ─── Firebase Service Account Setup ───
const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID")!;
const FIREBASE_CLIENT_EMAIL = Deno.env.get("FIREBASE_CLIENT_EMAIL")!;
const FIREBASE_PRIVATE_KEY = Deno.env.get("FIREBASE_PRIVATE_KEY")!.replace(
  /\\n/g,
  "\n"
);

// ─── Crypto Helpers für Google JWT ───

/** Base64url-Encode (ohne Padding) */
function base64url(data: Uint8Array): string {
  return btoa(String.fromCharCode(...data))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");
}

function base64urlEncodeString(str: string): string {
  return base64url(new TextEncoder().encode(str));
}

/** PEM Private Key → CryptoKey importieren */
async function importPrivateKey(pem: string): Promise<CryptoKey> {
  const pemContents = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");

  const binaryDer = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0));

  return crypto.subtle.importKey(
    "pkcs8",
    binaryDer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );
}

/** Google OAuth2 Access Token via Service Account JWT holen */
async function getGoogleAccessToken(): Promise<string> {
  const now = Math.floor(Date.now() / 1000);

  const header = base64urlEncodeString(
    JSON.stringify({ alg: "RS256", typ: "JWT" })
  );

  const claimSet = base64urlEncodeString(
    JSON.stringify({
      iss: FIREBASE_CLIENT_EMAIL,
      sub: FIREBASE_CLIENT_EMAIL,
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
      scope:
        "https://www.googleapis.com/auth/identitytoolkit https://www.googleapis.com/auth/firebase.database",
    })
  );

  const unsignedJwt = `${header}.${claimSet}`;

  // Signieren mit dem Private Key
  const key = await importPrivateKey(FIREBASE_PRIVATE_KEY);
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsignedJwt)
  );

  const signedJwt = `${unsignedJwt}.${base64url(new Uint8Array(signature))}`;

  // Access Token anfordern
  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: signedJwt,
    }),
  });

  if (!tokenResponse.ok) {
    const errText = await tokenResponse.text();
    throw new Error(`Google token error: ${errText}`);
  }

  const tokenData = await tokenResponse.json();
  return tokenData.access_token;
}

/** Firebase Custom Claims auf einen User setzen */
async function setFirebaseCustomClaims(
  firebaseUid: string,
  claims: Record<string, unknown>
): Promise<void> {
  const accessToken = await getGoogleAccessToken();

  const url = `https://identitytoolkit.googleapis.com/v1/accounts:update?key=`;

  // Wir nutzen die REST API mit OAuth2 Bearer Token (nicht API Key)
  const response = await fetch(
    `https://identitytoolkit.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/accounts:update`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        localId: firebaseUid,
        customAttributes: JSON.stringify(claims),
      }),
    }
  );

  if (!response.ok) {
    const errText = await response.text();
    throw new Error(`Custom claims error: ${errText}`);
  }
}

// ─── Main Handler ───

Deno.serve(async (req) => {
  try {
    const auth = req.headers.get("authorization");

    if (!auth || !auth.startsWith("Bearer ")) {
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

    // Firebase JWT Payload decodieren (Supabase hat Third-party Auth aktiv → Token ist verifiziert)
    const token = auth.replace("Bearer ", "");
    const payloadBase64 = token.split(".")[1];
    const payload = JSON.parse(atob(payloadBase64));

    if (!payload?.sub) {
      return new Response("Invalid Firebase token", { status: 401 });
    }

    const firebaseUid = payload.sub;
    const email = payload.email ?? null;
    const name = bodyName ?? payload.name ?? null;

    // ─── User suchen ───
    const { data: existingUser, error: selectError } = await supabase
      .from("users")
      .select("id, image_url")
      .eq("firebase_uid", firebaseUid)
      .maybeSingle();

    if (selectError) throw selectError;

    if (existingUser) {
      // Custom Claim trotzdem setzen (falls Token abgelaufen war oder Claim fehlte)
      await setFirebaseCustomClaims(firebaseUid, {
        supabase_uid: existingUser.id,
      });

      return Response.json({
        user_id: existingUser.id,
        image_url: existingUser.image_url ?? null,
        claims_set: true,
      });
    }

    // ─── Neuen User anlegen ───
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

    // ─── Custom Claim setzen ───
    await setFirebaseCustomClaims(firebaseUid, {
      supabase_uid: newUser.id,
    });

    return Response.json({
      user_id: newUser.id,
      claims_set: true,
    });
  } catch (err) {
    console.error("Full error:", err);
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
