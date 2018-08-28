SELECT xt.create_table('pack', 'public');

ALTER TABLE public.pack DISABLE TRIGGER ALL;

SELECT
  xt.add_column('pack', 'pack_id',           'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('pack', 'pack_head_id',     'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('pack', 'pack_head_type',      'TEXT', 'NOT NULL', 'public'),
  xt.add_column('pack', 'pack_shiphead_id', 'INTEGER', NULL,       'public'),
  xt.add_column('pack', 'pack_printed',     'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('pack', 'pack_created',      'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('pack', 'pack_lastupdated',  'TIMESTAMP WITH TIME ZONE', NULL, 'public');

SELECT
  xt.add_constraint('pack', 'pack_pkey', 'PRIMARY KEY (pack_id)', 'public'),
  xt.add_constraint('pack', 'pack_pack_head_type_check',
                    $$CHECK (pack_head_type IN ('SO', 'TO'))$$, 'public'),
  xt.add_constraint('pack', 'pack_pack_shiphead_id_fkey',
                    'FOREIGN KEY (pack_shiphead_id) REFERENCES shiphead(shiphead_id)', 'public');

ALTER TABLE public.pack ENABLE TRIGGER ALL;

COMMENT ON TABLE pack IS 'Temporary table for storing information about Orders added to the Packing List Batch';
