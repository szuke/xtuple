SELECT xt.create_table('bomhead', 'public');

ALTER TABLE public.bomhead DISABLE TRIGGER ALL;

SELECT
  xt.add_column('bomhead', 'bomhead_id',                    'SERIAL', 'NOT NULL',   'public'),
  xt.add_column('bomhead', 'bomhead_item_id',              'INTEGER', 'NOT NULL',   'public'),
  xt.add_column('bomhead', 'bomhead_serial',               'INTEGER', NULL,         'public'),
  xt.add_column('bomhead', 'bomhead_docnum',                  'TEXT', NULL,         'public'),
  xt.add_column('bomhead', 'bomhead_revision',                'TEXT', NULL,         'public'),
  xt.add_column('bomhead', 'bomhead_revisiondate',            'DATE', NULL,         'public'),
  xt.add_column('bomhead', 'bomhead_batchsize',      'NUMERIC(18,6)', NULL,         'public'),
  xt.add_column('bomhead', 'bomhead_requiredqtyper', 'NUMERIC(20,8)', NULL,         'public'),
  xt.add_column('bomhead', 'bomhead_rev_id',               'INTEGER', 'DEFAULT -1', 'public'),
  xt.add_column('bomhead', 'bomhead_created',     'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('bomhead', 'bomhead_lastupdated', 'TIMESTAMP WITH TIME ZONE', NULL, 'public');

SELECT
  xt.add_constraint('bomhead', 'bomhead_pkey', 'PRIMARY KEY (bomhead_id)', 'public'),
  xt.add_constraint('bomhead', 'bomhead_bomhead_item_id_fkey',
                    'FOREIGN KEY (bomhead_item_id) REFERENCES item(item_id) ON UPDATE RESTRICT ON DELETE CASCADE', 'public'),
  xt.add_constraint('bomhead', 'bomhead_bomhead_batchsize_check',
                    'CHECK ((bomhead_batchsize > (0)::numeric))', 'public');

ALTER TABLE public.bomhead ENABLE TRIGGER ALL;

COMMENT ON TABLE bomhead IS 'Bill of Materials (BOM) header information';
