CREATE OR REPLACE FUNCTION _setPackageIsEnabled(pName TEXT, pEnabled BOOLEAN) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _i      INTEGER := 0;
  _tabs   TEXT[] := ARRAY['cmd',  'cmdarg', 'image',  'metasql',
                          'priv', 'report', 'script', 'uiform', 'dict'];
  _table  TEXT;
  _trigger RECORD;

BEGIN
  IF NOT EXISTS (SELECT 1 FROM pkghead WHERE LOWER(pkghead_name) = LOWER(pName)) THEN
    RAISE EXCEPTION '_setPackageIsEnabled could not find an extension named % [xtuple: _setPackageIsEnabled, -1, %]',
                    pName, pName;
  END IF;

  FOR _i IN ARRAY_LOWER(_tabs,1)..ARRAY_UPPER(_tabs,1) LOOP
    BEGIN
      EXECUTE format('ALTER TABLE IF EXISTS %I.%I %s INHERIT public.%I;',
                     LOWER(pName), 'pkg' || _tabs[_i],
                     CASE WHEN pEnabled THEN '' ELSE 'NO' END, _tabs[_i]);
    EXCEPTION WHEN duplicate_table OR undefined_table THEN -- ignore the error
    END;
  END LOOP;

  FOR _trigger IN
    SELECT tabn.nspname, relname, tgname
      FROM pg_trigger   t
      JOIN pg_class     c    ON tgrelid      = c.oid AND relkind = 'r'
      JOIN pg_namespace tabn ON relnamespace = tabn.oid
      JOIN pg_proc      p    ON tgfoid       = p.oid
      JOIN pg_namespace trin ON pronamespace = trin.oid
     WHERE LOWER(trin.nspname) = LOWER(pName)
  LOOP
    EXECUTE format('ALTER TABLE %I.%I %s TRIGGER %I;',
                   _trigger.nspname, _trigger.relname,
                   CASE WHEN pEnabled THEN 'ENABLE' ELSE 'DISABLE' END,
                   _trigger.tgname);
  END LOOP;

  FOR _table IN
     SELECT DISTINCT relname
       FROM pg_class
       JOIN pg_namespace n ON relnamespace = n.oid
      WHERE relkind = 'r'
        AND nspname = LOWER(pName)
  LOOP
    EXECUTE format('ALTER TABLE %I.%I %s TRIGGER ALL;', LOWER(pName), _table,
                   CASE WHEN pEnabled THEN 'ENABLE' ELSE 'DISABLE' END);
  END LOOP;

  RETURN 0;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION _setPackageIsEnabled(pId INTEGER, pEnabled BOOLEAN)
  RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _pkgname TEXT;

BEGIN
  SELECT pkghead_name INTO _pkgname
    FROM pkghead
   WHERE pkghead_id = pId;
  IF _pkgname IS NULL THEN
    RAISE EXCEPTION '_setPackageIsEnabled could not find an extension with id % [xtuple: _setPackageIsEnabled, -2, %]',
                    pId, pId;
  END IF;

  RETURN _setPackageIsEnabled(_pkgname, pEnabled);
END;
$$ LANGUAGE plpgsql;
