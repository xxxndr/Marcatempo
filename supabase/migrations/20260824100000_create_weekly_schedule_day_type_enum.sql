-- Definisce i tre tipi di giornata ammessi nel template settimanale fisso
-- di un dipendente (Blocco 1.6/10): riposo, turno continuativo, turno
-- spezzato con due fasce orarie (mattina/sera)

create type weekly_schedule_day_type as enum ('rest', 'continuous', 'split');
