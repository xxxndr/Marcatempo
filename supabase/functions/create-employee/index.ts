// Crea un profilo dipendente: utente Auth + riga `employees` in un solo
// passaggio. Vedi app_timbratura.md, sezione "Creazione ed eliminazione
// profilo dipendente (Edge Function)" per l'architettura, e
// ambiente_sviluppo.md per il pattern withSupabase/ctx.supabaseAdmin.

import { withSupabase } from "npm:@supabase/server@^1";
import { createClient } from "npm:@supabase/supabase-js@^2";

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

    const { data: caller, error: callerErr } = await ctx.supabase
      .from("employees")
      .select("role, client_id")
      .eq("id", userId)
      .single();
    if (callerErr || caller?.role !== "admin") {
      return Response.json({ error: "Forbidden" }, { status: 403 });
    }

    const { email, password, first_name, last_name } = await req.json();
    if (!email || !password || !first_name || !last_name) {
      return Response.json({ error: "Invalid payload" }, { status: 400 });
    }

    const supabaseAdmin = adminClient();
    const { data: authUser, error: authErr } =
      await supabaseAdmin.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
      });
    if (authErr || !authUser?.user) {
      return Response.json({ error: authErr?.message }, { status: 400 });
    }

    const { data: employee, error: employeeErr } = await ctx.supabase
      .from("employees")
      .insert({
        id: authUser.user.id,
        client_id: caller.client_id,
        first_name,
        last_name,
        role: "employee",
      })
      .select()
      .single();
    if (employeeErr) {
      await supabaseAdmin.auth.admin.deleteUser(authUser.user.id);
      return Response.json({ error: employeeErr.message }, { status: 400 });
    }

    return Response.json({ employee });
  }),
};
