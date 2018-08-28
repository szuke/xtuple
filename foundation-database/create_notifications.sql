CREATE OR REPLACE FUNCTION _notifyDataChanged() RETURNS TRIGGER AS $$
DECLARE
  _q TEXT;
BEGIN
  _q := format($f$NOTIFY %2$I, '{ "schema": "%1$s", "table": "%2$s" }';$f$,
                 TG_TABLE_SCHEMA, TG_TABLE_NAME, TG_OP);
  EXECUTE _q;
  RETURN NULL;
END
$$ LANGUAGE plpgsql;

DO $$
  DECLARE
    _r RECORD;
  BEGIN
    FOR _r IN SELECT nspname, relname
                FROM pg_namespace n
                JOIN pg_class     c ON n.oid = relnamespace
               WHERE relkind = 'r'
                 AND (nspname IN (SELECT pkghead_name FROM pkghead)
                      OR nspname IN ('public', 'api'))
                 AND c.oid NOT IN (SELECT tgrelid FROM pg_trigger
                                    WHERE tgname = 'notifydatachanged')
    LOOP
      EXECUTE format($f$CREATE TRIGGER notifydatachanged AFTER INSERT OR UPDATE OR DELETE
                            ON %I.%I
                            FOR EACH STATEMENT EXECUTE PROCEDURE _notifyDataChanged();$f$,
                     _r.nspname, _r.relname);
    END LOOP;
  END;
$$ LANGUAGE plpgsql;
