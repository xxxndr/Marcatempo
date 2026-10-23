// Disattiva o riattiva un dipendente (Blocco 3.6): l'app non espone mai una
// cancellazione, perché lo storico va conservato e un tap sbagliato da mobile
// non deve poter distruggere dati — vedi app_timbratura.md, sezione
// "Creazione ed eliminazione profilo dipendente (Edge Function)".
// Due effetti: `employees.active` (barriera vera, tutte le policy RLS ne
// dipendono) e il ban lato Auth, che blocca anche il login. L'ordine non è
// casuale: si scrive prima `active`, così se il secondo passo fallisce
// l'accesso ai dati è comunque già tagliato.
// Isolamento multi-tenant: il lookup del target passa da `ctx.supabase`
// (RLS), quindi un Admin non tocca dipendenti di un altro client_id.

import { withSupabase } from "npm:@supabase/server@^1";
import { createClient } from "npm:@supabase/supabase-js@^2";

const PERMANENT_BAN = "876000h";
const NO_BAN = "none";

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

    const { id, active } = await req.json();
    if (!id || typeof active !== "boolean") {
      return Response.json({ error: "Invalid payload" }, { status: 400 });
    }

    if (!active && id === userId) {
      return Response.json({ error: "Cannot deactivate self" }, { status: 409 });
    }

    const { data: updated, error: updateErr } = await ctx.supabase
      .from("employees")
      .update({ active })
      .eq("id", id)
      .select("id, active")
      .maybeSingle();
    if (updateErr) {
      return Response.json({ error: updateErr.message }, { status: 400 });
    }
    if (!updated) {
      return Response.json({ error: "Not found" }, { status: 404 });
    }

    const supabaseAdmin = adminClient();
    const { error: banErr } = await supabaseAdmin.auth.admin.updateUserById(id, {
      ban_duration: active ? NO_BAN : PERMANENT_BAN,
    });
    if (banErr) {
      return Response.json({ error: banErr.message }, { status: 400 });
    }

    return Response.json({ employee: updated });
  }),
};
