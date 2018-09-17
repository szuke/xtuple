SELECT xt.create_table('urlinfo', 'public');

ALTER TABLE public.urlinfo DISABLE TRIGGER ALL;

SELECT
  xt.add_column('urlinfo', 'url_id',      'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('urlinfo', 'url_title',     'TEXT', 'NOT NULL', 'public'),
  xt.add_column('urlinfo', 'url_url',       'TEXT',       NULL, 'public'),
  xt.add_column('urlinfo', 'url_grp',     'TEXT[]',       NULL, 'public');

SELECT
  xt.add_constraint('urlinfo', 'urlinfo_pkey', 'PRIMARY KEY (url_id)', 'public');

ALTER TABLE public.urlinfo ENABLE TRIGGER ALL;

COMMENT ON TABLE urlinfo IS 'Website links and File links';
COMMENT ON COLUMN public.urlinfo.url_grp IS 'Role permissions to access the file/document link.  No entry means all access';


/* Migrate URLINFO sequence to use FILE sequence to ensure uniqueness across both */
DO $$
DECLARE
  _maxid INTEGER;
  _row   RECORD;
  _id    INTEGER;
  _fk    RECORD;
  _pk    TEXT[];
BEGIN

  IF (pg_get_serial_sequence('urlinfo', 'url_id') = 'public.urlinfo_url_id_seq') THEN

    _maxid := GREATEST(nextval('urlinfo_url_id_seq'), nextval('file_file_id_seq'));

    PERFORM setval('file_file_id_seq', _maxid + 1, true);

    ALTER TABLE urlinfo ALTER COLUMN url_id SET DEFAULT NEXTVAL('file_file_id_seq');

    -- Defer foreign key checks till this function is committed
    SET CONSTRAINTS ALL DEFERRED;

    -- Migrate the URL table to use the new FILE sequence including related tables
    FOR _row IN
      SELECT url_id FROM urlinfo
    LOOP
      UPDATE urlinfo SET url_id=DEFAULT
      WHERE url_id = _row.url_id
      RETURNING url_id INTO _id;

      UPDATE docass SET docass_target_id=_id
       WHERE docass_target_type = 'URL'
         AND docass_target_id = _row.url_id;

      -- Update all tables using urlinfo as FK
      FOR _fk IN
        EXECUTE $_$SELECT fkeyns.nspname AS schemaname, fkeytab.relname AS tablename,
                        conkey, attname, typname
                 FROM pg_constraint
                 JOIN pg_class     basetab ON (confrelid=basetab.oid)
                 JOIN pg_namespace basens  ON (basetab.relnamespace=basens.oid)
                 JOIN pg_class     fkeytab ON (conrelid=fkeytab.oid)
                 JOIN pg_namespace fkeyns  ON (fkeytab.relnamespace=fkeyns.oid)
                 JOIN pg_attribute         ON (attrelid=conrelid AND attnum=conkey[1])
                 JOIN pg_type              ON (atttypid=pg_type.oid)
                WHERE basetab.relname = 'urlinfo'
                AND basens.nspname  = 'public'$_$
      LOOP
      IF (ARRAY_UPPER(_fk.conkey, 1) > 1) THEN
        RAISE EXCEPTION 'Cannot change the foreign key in %.% that refers to public.urlinfo because the foreign key constraint has multiple columns. [xtuple: changefkeypointers, -1, %.%]',
          _fk.schemaname, _fk.tablename,
          _fk.schemaname, _fk.tablename;
      END IF;

    -- actually change the foreign keys to point to the desired base table record
      EXECUTE 'UPDATE '  || _fk.schemaname || '.' || _fk.tablename ||
                ' SET '  || _fk.attname    || '=' || _id ||
              ' WHERE (' || _fk.attname    || '=' || _row.url_id || ');';
      END LOOP;
    END LOOP;
  END IF;
END; $$;
