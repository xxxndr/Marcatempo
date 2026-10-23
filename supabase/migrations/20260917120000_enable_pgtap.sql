-- Estensione per scrivere test automatici in SQL (pgTAP), usata dai file in
-- test/supabase/. Test lanciati sul DB locale (supabase start), mai in
-- produzione: vedi notes/test/tests.md.

create extension if not exists pgtap with schema extensions;
