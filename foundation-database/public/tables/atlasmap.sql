SELECT xt.create_table('atlasmap', 'public');

ALTER TABLE public.atlasmap DISABLE TRIGGER ALL;

SELECT
  xt.add_column('atlasmap', 'atlasmap_id',              'SERIAL', 'NOT NULL',     'public'),
  xt.add_column('atlasmap', 'atlasmap_name',            'TEXT', 'NOT NULL',       'public'),
  xt.add_column('atlasmap', 'atlasmap_filter',          'TEXT', 'NOT NULL',       'public'),
  xt.add_column('atlasmap', 'atlasmap_filtertype',      'TEXT', 'NOT NULL',       'public'),
  xt.add_column('atlasmap', 'atlasmap_atlas',           'TEXT', 'NOT NULL',       'public'),
  xt.add_column('atlasmap', 'atlasmap_map',             'TEXT', 'NOT NULL',       'public'),
  xt.add_column('atlasmap', 'atlasmap_headerline',      'BOOLEAN', 'NOT NULL',    'public'),
  xt.add_column('atlasmap', 'atlasmap_atlastype',       'CHARACTER(1)', 'NOT NULL DEFAULT ''F'' ', 'public');

ALTER TABLE public.atlasmap ENABLE TRIGGER ALL;

SELECT
   xt.add_constraint('atlasmap', 'atlasmap_pkey', $$PRIMARY KEY (atlasmap_id)$$, 'public'),
   xt.add_constraint('atlasmap', 'atlasmap_atlasmap_name_key', $$UNIQUE (atlasmap_name)$$, 'public'),
   xt.add_constraint('atlasmap', 'atlasmap_atlasmap_name_check', $$CHECK (atlasmap_name <> ''::text)$$, 'public'),
   xt.add_constraint('atlasmap', 'atlasmap_atlasmap_atlastype_check', $$CHECK (atlasmap_atlastype IN ('F', 'D'))$$, 'public');

COMMENT ON TABLE atlasmap IS 'Describes heuristics for finding a CSVImp atlas for a given CSV file. 
When looking for a CSV Atlas to use when importing a CSV file, the first atlasmap record found that matches 
the CSV file is used to select the Atlas file and Map in that Atlas to import the CSV file.';
COMMENT ON COLUMN public.atlasmap.atlasmap_id IS 'The internal id of this CSVImp atlas mapping.';
COMMENT ON COLUMN public.atlasmap.atlasmap_name IS 'The human-readable name of this atlas mapping.';
COMMENT ON COLUMN public.atlasmap.atlasmap_filter IS 'A regular expression that should match the CSV file. Which part of the file that matches is determined by the filter type.';
COMMENT ON COLUMN public.atlasmap.atlasmap_filtertype IS 'A description of what aspect of the CSV file the filter should be compared with. Handled values are: ''filename'' - the filter is matched against the name of the file; and ''firstline'' - the filter is matched against the first line of the file contents.';
COMMENT ON COLUMN public.atlasmap.atlasmap_atlas IS 'The name of the CSVImp Atlas file. This should be a simple pathname, not an absolute or relative name if possible. The full path will be determined by concatenating the operating-system-specific CSV Atlas default directory with the value here unless this is an absolute pathname.';
COMMENT ON COLUMN public.atlasmap.atlasmap_map IS 'The name of the Map inside the Atlas to use if the filter and filter type match the CVS file.';
COMMENT ON COLUMN public.atlasmap.atlasmap_headerline IS 'An indicator of whether the first line of the CSV file should be treated as a header line or as data.';
COMMENT ON COLUMN public.atlasmap.atlasmap_atlastype IS 'An indicator of whether to load the atlas from a file (F) or the database (D).';

