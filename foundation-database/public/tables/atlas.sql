SELECT xt.create_table('atlas', 'public');

ALTER TABLE public.atlas DISABLE TRIGGER ALL;

SELECT
  xt.add_column('atlas', 'atlas_id',        'SERIAL', 'NOT NULL PRIMARY KEY', 'public'),
  xt.add_column('atlas', 'atlas_name',      'TEXT', NULL, 'public'),
  xt.add_column('atlas', 'atlas_atlasmap',  'TEXT', NULL, 'public');

ALTER TABLE public.atlas ENABLE TRIGGER ALL;

COMMENT ON TABLE atlas IS 'CSVImp Atlas Maps';
COMMENT ON COLUMN atlas.atlas_atlasmap IS 'Atlas Map XML definition';
