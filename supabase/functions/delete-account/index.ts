import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function getDefaultKey(variable: string): string | undefined {
  const raw = Deno.env.get(variable);
  if (!raw) return undefined;

  try {
    const keys: unknown = JSON.parse(raw);
    if (
      typeof keys === "object" &&
      keys !== null &&
      "default" in keys &&
      typeof keys.default === "string"
    ) {
      return keys.default;
    }
  } catch (error) {
    console.error(`Could not read the default key from ${variable}:`, error);
  }

  return undefined;
}

Deno.serve(async (request: Request): Promise<Response> => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return jsonResponse({ error: "Method not allowed." }, 405);
  }

  const authorization = request.headers.get("Authorization");
  const token = authorization?.match(/^Bearer\s+(.+)$/i)?.[1];
  if (!token) {
    return jsonResponse({ error: "Sign in to delete your account." }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey =
    Deno.env.get("SUPABASE_ANON_KEY") ??
    getDefaultKey("SUPABASE_PUBLISHABLE_KEYS");
  const serviceRoleKey =
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
    getDefaultKey("SUPABASE_SECRET_KEYS");
  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    console.error("Required Supabase function keys are missing.");
    return jsonResponse(
      {
        error: "Account deletion is not configured.",
        code: "function_not_configured",
      },
      500,
    );
  }

  const userClient = createClient(supabaseUrl, anonKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const { data, error: userError } = await userClient.auth.getUser(token);
  if (userError || !data.user) {
    return jsonResponse(
      {
        error: "Your session is invalid or expired.",
        code: "invalid_session",
      },
      401,
    );
  }

  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const { error: deleteError } = await adminClient.auth.admin.deleteUser(
    data.user.id,
  );
  if (deleteError) {
    console.error("Could not delete the authenticated user:", {
      code: deleteError.code,
      message: deleteError.message,
      status: deleteError.status,
    });
    return jsonResponse(
      {
        error: "Account deletion failed.",
        code: "delete_rejected",
      },
      500,
    );
  }

  return jsonResponse({ success: true }, 200);
});
