// Elimina un profilo dipendente: cancella l'utente Auth, la riga
// `employees` sparisce da sola per via del FK on delete cascade (vedi
// app_timbratura.md, sezione "Creazione ed eliminazione profilo
// dipendente (Edge Function)"). Isolamento multi-tenant: il lookup del
// dipendente da cancellare passa da `ctx.supabase` (RLS), quindi un
// Admin non vede né può cancellare dipendenti di un altro client_id.

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
      .select("role")
      .eq("id", userId)
      .single();
    if (callerErr || caller?.role !== "admin") {
      return Response.json({ error: "Forbidden" }, { status: 403 });
    }

    const { id } = await req.json();
    if (!id) {
      return Response.json({ error: "Invalid payload" }, { status: 400 });
    }

    const { data: target, error: targetErr } = await ctx.supabase
      .from("employees")
      .select("id")
      .eq("id", id)
      .single();
    if (targetErr || !target) {
      return Response.json({ error: "Not found" }, { status: 404 });
    }

    const supabaseAdmin = adminClient();
    const { error: deleteErr } = await supabaseAdmin.auth.admin.deleteUser(id);
    if (deleteErr) {
      return Response.json({ error: deleteErr.message }, { status: 400 });
    }

    return Response.json({ deleted: id });
  }),
};
