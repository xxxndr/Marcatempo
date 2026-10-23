// Completa la registrazione di un dipendente dopo il sign-up Supabase
// Auth: risolve il signup_code del locale al client_id e crea la riga
// `employees` corrispondente. Vedi app_timbratura.md, sezione "Ordine di
// creazione degli accessi" e "Creazione ed eliminazione profilo
// dipendente (Edge Function)".
// Limite tentativi falliti anti brute-force sul codice: vedi migration
// signup_code_attempts_table.

import { withSupabase } from "npm:@supabase/server@^1";
import { createClient } from "npm:@supabase/supabase-js@^2";

const MAX_SIGNUP_CODE_ATTEMPTS = 5;

function adminClient() {
  const url = Deno.env.get("SUPABASE_URL")!;
  const secretKeys = JSON.parse(Deno.env.get("SUPABASE_SECRET_KEYS")!);
  return createClient(url, secretKeys["default"]);
}

export default {
  fetch: withSupabase({ auth: "user" }, async (req, ctx) => {
    const userId = ctx.userClaims?.id;
    if (!userId) {
      return Response.json({ error: "Unauthorized" }, { status: 401 });
    }

    const { signup_code, first_name, last_name } = await req.json();
    if (!signup_code || !first_name || !last_name) {
      return Response.json({ error: "Invalid payload" }, { status: 400 });
    }

    const supabaseAdmin = adminClient();

    const { data: attempt } = await supabaseAdmin
      .from("signup_code_attempts")
      .select("failed_count, blocked_at")
      .eq("user_id", userId)
      .maybeSingle();
    if (attempt && attempt.failed_count >= MAX_SIGNUP_CODE_ATTEMPTS - 1) {
      if (!attempt.blocked_at) {
        await supabaseAdmin.from("signup_code_attempts").update({
          blocked_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        }).eq("user_id", userId);
      }
      return Response.json({ error: "Too many attempts" }, { status: 403 });
    }

    const { data: clientId, error: resolveErr } = await ctx.supabase
      .rpc("resolve_signup_code", { code: signup_code.trim().toUpperCase() });
    if (resolveErr || !clientId) {
      const failedCount = (attempt?.failed_count ?? 0) + 1;
      await supabaseAdmin.from("signup_code_attempts").upsert({
        user_id: userId,
        failed_count: failedCount,
        updated_at: new Date().toISOString(),
      });
      return Response.json({ error: "Invalid signup code" }, { status: 404 });
    }

    const { data: employee, error: employeeErr } = await supabaseAdmin
      .from("employees")
      .insert({
        id: userId,
        client_id: clientId,
        first_name,
        last_name,
        role: "employee",
      })
      .select()
      .single();
    if (employeeErr) {
      if (employeeErr.code === "23505") {
        return Response.json({ error: "Profile already exists" }, { status: 409 });
      }
      return Response.json({ error: employeeErr.message }, { status: 400 });
    }

    return Response.json({ employee });
  }),
};
