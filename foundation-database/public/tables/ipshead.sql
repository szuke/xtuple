SELECT xt.create_table('ipshead', 'public');

ALTER TABLE public.ipshead DISABLE TRIGGER ALL;

SELECT
  xt.add_column('ipshead', 'ipshead_id',       '  SERIAL', 'NOT NULL', 'public'),
  xt.add_column('ipshead', 'ipshead_name',         'TEXT', 'NOT NULL', 'public'),
  xt.add_column('ipshead', 'ipshead_descrip',      'TEXT', NULL,       'public'),
  xt.add_column('ipshead', 'ipshead_effective',    'DATE', NULL,       'public'),
  xt.add_column('ipshead', 'ipshead_expires',      'DATE', NULL,       'public'),
  xt.add_column('ipshead', 'ipshead_curr_id',   'INTEGER', 'DEFAULT basecurrid() NOT NULL', 'public'),
  xt.add_column('ipshead', 'ipshead_updated',      'DATE', NULL,       'public'),
  xt.add_column('ipshead', 'ipshead_listprice', 'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public');

SELECT
  xt.add_constraint('ipshead', 'ipshead_pkey', 'PRIMARY KEY (ipshead_id)', 'public'),
  xt.add_constraint('ipshead', 'ipshead_pkey', 'PRIMARY KEY (ipshead_id)', 'public'),
  xt.add_constraint('ipshead', 'ipshead_ipshead_name_key',
                    'UNIQUE (ipshead_name)', 'public'),
  xt.add_constraint('ipshead', 'ipshead_ipshead_name_check',
                    $$CHECK (ipshead_name <> '')$$, 'public'),
  xt.add_constraint('ipshead', 'ipshead_to_curr_symbol',
                    'FOREIGN KEY (ipshead_curr_id) REFERENCES curr_symbol(curr_id)', 'public');

ALTER TABLE public.ipshead ENABLE TRIGGER ALL;

COMMENT ON TABLE ipshead IS 'Pricing Schedule header information';

COMMENT ON COLUMN public.ipshead.ipshead_listprice IS 'Indicates if list price schedule.';
