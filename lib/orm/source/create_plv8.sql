-- dummy function avoids forward reference bug with some plv8 versions
CREATE OR REPLACE FUNCTION xt.js_init(debug BOOLEAN DEFAULT false, initialize BOOLEAN DEFAULT false)
RETURNS VOID AS $$ BEGIN RETURN; END; $$ LANGUAGE plpgsql;

CREATE EXTENSION IF NOT EXISTS plv8;
