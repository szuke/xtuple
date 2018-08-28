DROP FUNCTION IF EXISTS createPkgSchema(text, text);
DROP FUNCTION IF EXISTS createPkgSchema(TEXT, TEXT, TEXT, TEXT, TEXT, BOOLEAN);

DROP FUNCTION IF EXISTS createPkgSchema(TEXT, TEXT, TEXT, TEXT, TEXT, BOOLEAN);
CREATE OR REPLACE FUNCTION createPkgSchema(pname      TEXT,
                                           pcomment   TEXT    default '',
                                           pversion   TEXT    default '',
                                           pdescrip   TEXT    default '',
                                           pdeveloper TEXT    default '',
                                           pindev     BOOLEAN default FALSE
                                          ) RETURNS BIGINT AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _namespaceoid BIGINT := -1;
  _tabs         TEXT[] := ARRAY['cmd',  'cmdarg', 'image',  'metasql',
                                'priv', 'report', 'script', 'uiform', 'dict'] ;
  _pkgtab       TEXT;
  _enabled      BOOLEAN := TRUE;

BEGIN
  pname := LOWER(pname);

  IF LENGTH(COALESCE(pname, '')) <= 0 THEN
    RAISE EXCEPTION 'Cannot create a schema for this package without a name [xtuple: createPkgSchema, -1 ]';
  END IF;

  SELECT oid INTO _namespaceoid
    FROM pg_namespace
   WHERE LOWER(nspname) = LOWER(pname);
  IF (NOT FOUND) THEN
    EXECUTE format('CREATE SCHEMA %I;',                       pname);
    EXECUTE format('GRANT ALL ON SCHEMA %I TO GROUP xtrole;', pname);

    SELECT oid INTO _namespaceoid
      FROM pg_namespace
     WHERE LOWER(nspname) = pname;
  END IF;

  IF EXISTS(SELECT 1
              FROM pkghead
             WHERE pkghead_name=pname) THEN
    _enabled := packageIsEnabled(pname);
  END IF;

  FOR i IN ARRAY_LOWER(_tabs,1)..ARRAY_UPPER(_tabs,1) LOOP
    _pkgtab := 'pkg' || _tabs[i];

    IF NOT EXISTS(SELECT 1
                    FROM pg_class
                   WHERE relname = _pkgtab
                     AND relnamespace = _namespaceoid) THEN
      EXECUTE format('CREATE TABLE %I.%I () INHERITS (%I);',
                     pname, _pkgtab, _tabs[i]);

      IF NOT _enabled THEN
        EXECUTE format('ALTER TABLE %I.%I NO INHERIT %I;',
                       pname, _pkgtab, _tabs[i]);
      END IF;

      EXECUTE format($f$ALTER TABLE %I.%I ALTER %s_id SET NOT NULL,
                         ADD PRIMARY KEY (%s_id),
                         ALTER %s_id SET DEFAULT NEXTVAL('%s_%s_id_seq');$f$,
                     pname, _pkgtab, _tabs[i], _tabs[i], _tabs[i], _tabs[i], _tabs[i]);

      EXECUTE format('REVOKE ALL ON %I.%I FROM PUBLIC;',     pname, _pkgtab);
      EXECUTE format('GRANT  ALL ON %I.%I TO GROUP xtrole;', pname, _pkgtab);

      IF (_tabs[i] = 'cmdarg') THEN
        EXECUTE format($f$ALTER TABLE %I.%I ADD FOREIGN KEY (cmdarg_cmd_id)
                          REFERENCES %I.pkgcmd(cmd_id);$f$,
                       pname, _pkgtab, pname);
      END IF;

      EXECUTE format('DROP TRIGGER IF EXISTS %sbeforetrigger ON %I.%I;',
                     _pkgtab, pname, _pkgtab);
      EXECUTE format('CREATE TRIGGER %sbeforetrigger' ||
                     ' BEFORE INSERT OR UPDATE OR DELETE ON %I.%I' ||
                     ' FOR EACH ROW EXECUTE PROCEDURE _%sbeforetrigger();',
                      _pkgtab, pname, _pkgtab, _pkgtab);

      EXECUTE format('DROP TRIGGER IF EXISTS %saltertrigger ON %I.%I;',
                      _pkgtab, pname, _pkgtab);
      EXECUTE format('CREATE TRIGGER %saltertrigger' ||
                     ' BEFORE INSERT OR UPDATE OR DELETE ON %I.%I' ||
                     ' FOR EACH ROW EXECUTE PROCEDURE _%saltertrigger();',
                     _pkgtab, pname, _pkgtab, _pkgtab);

      EXECUTE format('DROP TRIGGER IF EXISTS %saftertrigger ON %I.%I;',
                     _pkgtab, pname, _pkgtab);
      EXECUTE format('CREATE TRIGGER %saftertrigger' ||
                     ' AFTER INSERT OR UPDATE OR DELETE ON %I.%I' ||
                     ' FOR EACH ROW EXECUTE PROCEDURE _%saftertrigger();',
                     _pkgtab, pname, _pkgtab, _pkgtab);

      IF NOT _enabled THEN
        EXECUTE format('ALTER TABLE %I.%I DISABLE TRIGGER ALL;',
                       pname, _pkgtab);
      END IF;

    END IF;
  END LOOP;

  IF (pcomment != '') THEN
    EXECUTE format('COMMENT ON SCHEMA %I IS %L;', pname, pcomment);
  END IF;

  IF NOT EXISTS(SELECT 1 FROM pkghead where pkghead_name = pname) THEN
    INSERT INTO pkghead (pkghead_name,      pkghead_descrip, pkghead_version,
                         pkghead_developer, pkghead_indev,   pkghead_notes
               ) VALUES (pname,             pdescrip,        pversion,
                         pdeveloper,        pindev,          pcomment);
  ELSIF (pversion != '' AND pdescrip != '' AND pdeveloper != '') THEN
    UPDATE pkghead
       SET pkghead_descrip=pdescrip, pkghead_version=pversion,
           pkghead_developer=pdeveloper, pkghead_indev=pindev, pkghead_notes=pcomment
     WHERE pkghead_name=pname;
  END IF;

  RETURN _namespaceoid;
END;
$$
LANGUAGE plpgsql;
