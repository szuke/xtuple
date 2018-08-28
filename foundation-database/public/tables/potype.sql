-- Migrate POTYPE table from original xt extension into public
DO $$
DECLARE
  _hasXtTable     BOOLEAN;
  _hasPublicTable BOOLEAN;
  _publicCols     TEXT;
BEGIN
  _hasXtTable := EXISTS(SELECT 1
                          FROM information_schema.tables
                         WHERE table_schema = 'xt'
                           AND table_name   = 'potype');
  _hasPublicTable := EXISTS(SELECT 1
                          FROM information_schema.tables
                         WHERE table_schema = 'public'
                           AND table_name   = 'potype');

  IF _hasXtTable AND NOT _hasPublicTable THEN
    ALTER TABLE xt.potype SET SCHEMA public;
    _hasXtTable := FALSE;  -- don't try to copy from it later
  END IF;

  PERFORM xt.create_table('potype', 'public');

  PERFORM xt.add_column('potype','potype_id',             'SERIAL', 'PRIMARY KEY',            'public'),
          xt.add_column('potype','potype_code',             'TEXT', null,                     'public'),
          xt.add_column('potype','potype_descr',            'TEXT', null,                     'public'),
          xt.add_column('potype','potype_active',        'BOOLEAN', 'NOT NULL DEFAULT TRUE',  'public'),
          xt.add_column('potype','potype_default',       'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public'),
          xt.add_column('potype','potype_emlprofile_id', 'INTEGER', null,                     'public');

  SELECT string_agg(column_name, ' ') INTO _publicCols
    FROM information_schema.columns
   WHERE table_schema = 'public'
     AND table_name   = 'potype';

  ALTER TABLE public.potype DISABLE TRIGGER ALL;

  IF _publicCols ~ 'potype_name' THEN
    UPDATE public.potype SET potype_code = potype_name
      WHERE COALESCE(potype_code, '') = '';
    ALTER TABLE public.potype DROP COLUMN potype_name;
  END IF;

  IF _publicCols ~ 'potype_descrip' THEN
    UPDATE public.potype SET potype_descr = potype_descrip
      WHERE COALESCE(potype_descr, '') = '';
    ALTER TABLE public.potype DROP COLUMN potype_descrip;
  END IF;

  CREATE TEMPORARY TABLE upgrade_potype (LIKE public.potype) ON COMMIT DROP;
  INSERT INTO upgrade_potype SELECT * FROM public.potype;
  DELETE FROM public.potype;

  IF _hasXtTable THEN
    INSERT INTO public.potype (
      potype_id, potype_code, potype_descr,
      potype_active, potype_emlprofile_id
     ) SELECT potype_id, potype_code, potype_descr,
              potype_active, potype_emlprofile_id
         FROM xt.potype;
    
    DROP TABLE xt.potype CASCADE;
  END IF;

  -- copy unique old public.potypes, changing their ids if necessary
  IF _publicCols IS NOT NULL THEN
    INSERT INTO public.potype (potype_id, potype_code, potype_descr)
                        SELECT potype_id, potype_code, potype_descr
                          FROM upgrade_potype u
                         WHERE NOT EXISTS (SELECT 1
                                             FROM potype p
                                           WHERE p.potype_id   = u.potype_id
                                              OR p.potype_code = u.potype_code);
    INSERT INTO public.potype (potype_code, potype_descr)
                        SELECT potype_code, potype_descr
                          FROM upgrade_potype
                         WHERE potype_code NOT IN (SELECT potype_code
                                                     FROM public.potype);
    DROP TABLE IF EXISTS upgrade_potype;
  END IF;
END
$$ LANGUAGE plpgsql;

SELECT xt.add_constraint('potype', 'potype_pkey',            'PRIMARY KEY (potype_id)', 'public'),
       xt.add_constraint('potype', 'potype_potype_code_key', 'UNIQUE (potype_code)',    'public');

ALTER TABLE public.potype ENABLE TRIGGER ALL;

COMMENT ON table public.potype IS 'Purchase Order Type table';
