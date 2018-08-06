SELECT xt.create_table('curr_rate', 'public');

ALTER TABLE public.curr_rate DISABLE TRIGGER ALL;

SELECT
  xt.add_column('curr_rate', 'curr_rate_id',     'SERIAL',             'NOT NULL', 'public'),
  xt.add_column('curr_rate', 'curr_id',          'INTEGER',            'NOT NULL', 'public'),
  xt.add_column('curr_rate', 'curr_rate',        'NUMERIC(16,8)',      'NOT NULL', 'public'),
  xt.add_column('curr_rate', 'curr_effective',   'DATE',               'NOT NULL', 'public'),
  xt.add_column('curr_rate', 'curr_expires',     'DATE',               'NOT NULL', 'public'),
  xt.add_column('curr_rate', 'curr_created',     'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('curr_rate', 'curr_lastupdated', 'TIMESTAMP WITH TIME ZONE', NULL, 'public');

SELECT
  xt.add_constraint('curr_rate', 'curr_rate_pkey', 'PRIMARY KEY (curr_rate_id)', 'public'),
  xt.add_constraint('curr_rate', 'curr_rate_to_curr_symbol',
                    'FOREIGN KEY (curr_id) REFERENCES curr_symbol(curr_id)', 'public'),
  xt.add_constraint('curr_rate', 'curr_rate_curr_rate_check',
                    'CHECK (curr_rate > (0)::numeric)', 'public'),
  xt.add_constraint('curr_rate', 'curr_rate_curr_id_key',
                    'UNIQUE (curr_id, curr_effective)', 'public');

ALTER TABLE public.curr_rate ENABLE TRIGGER ALL;

COMMENT ON TABLE curr_rate IS 'Exchange Rates Between Base and Foreign Currencies';
