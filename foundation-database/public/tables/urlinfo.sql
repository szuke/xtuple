SELECT xt.create_table('urlinfo', 'public');

ALTER TABLE public.urlinfo DISABLE TRIGGER ALL;

SELECT
  xt.add_column('urlinfo', 'url_id',      'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('urlinfo', 'url_title',     'TEXT', 'NOT NULL', 'public'),
  xt.add_column('urlinfo', 'url_url',       'TEXT',       NULL, 'public');

SELECT
  xt.add_constraint('urlinfo', 'urlinfo_pkey', 'PRIMARY KEY (url_id)', 'public');

ALTER TABLE public.urlinfo ENABLE TRIGGER ALL;

COMMENT ON TABLE urlinfo IS 'Website links and File links';


/* Migrate URLINFO sequence to use FILE sequence to ensure uniqueness across both */
DO $$
DECLARE
  _maxid INTEGER;
  _row   RECORD;
  _id    INTEGER;
BEGIN

  IF (pg_get_serial_sequence('urlinfo', 'url_id') = 'public.urlinfo_url_id_seq') THEN

    _maxid := GREATEST(nextval('urlinfo_url_id_seq'), nextval('file_file_id_seq'));

    PERFORM setval('file_file_id_seq', _maxid + 1, true);

    ALTER TABLE urlinfo ALTER COLUMN url_id SET DEFAULT NEXTVAL('file_file_id_seq');

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

    END LOOP;
  END IF;
END; $$
