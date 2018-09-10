SELECT xt.create_table('file', 'public');

ALTER TABLE public.file DISABLE TRIGGER ALL;

SELECT
   xt.add_column('file', 'file_id',        'SERIAL', 'PRIMARY KEY', 'public'),
   xt.add_column('file', 'file_title',     'TEXT', '     NOT NULL', 'public'),
   xt.add_column('file', 'file_stream',    'BYTEA',             '', 'public'),
   xt.add_column('file', 'file_descrip',   'TEXT',      'NOT NULL', 'public'),
   xt.add_column('file', 'file_mime_type', 'TEXT', 'NOT NULL DEFAULT ''application/octet-stream''', 'public');

SELECT
  xt.add_constraint('file', 'file_pkey', 'PRIMARY KEY (file_id)', 'public');

ALTER TABLE public.file ENABLE TRIGGER ALL;

COMMENT ON TABLE file IS 'File and Document Storage';
