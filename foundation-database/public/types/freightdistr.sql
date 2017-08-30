DROP TYPE IF EXISTS freightdistr CASCADE;

CREATE TYPE public.freightdistr AS
   (freightdistr_vohead_id integer,
    freightdistr_poitem_id integer,
    freightdistr_accnt_id integer,
    freightdistr_amount numeric);																																																																																																																																																																																																														
