SELECT xt.create_table('bankaccnt', 'public');

ALTER TABLE public.bankaccnt DISABLE TRIGGER ALL;

SELECT
  xt.add_column('bankaccnt', 'bankaccnt_id',                   'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_name',                   'TEXT', 'NOT NULL', 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_descrip',                'TEXT', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_bankname',               'TEXT', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_accntnumber',            'TEXT', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_ar',                  'BOOLEAN', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_ap',                  'BOOLEAN', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_nextchknum',          'INTEGER', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_type',           'CHARACTER(1)', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_accnt_id',            'INTEGER', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_check_form_id',       'INTEGER', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_userec',              'BOOLEAN', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_rec_accnt_id',        'INTEGER', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_curr_id',             'INTEGER', 'DEFAULT basecurrid()',   'public'),
  xt.add_column('bankaccnt', 'bankaccnt_notes',                  'TEXT', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_routing',                'TEXT', $$DEFAULT '' NOT NULL$$,  'public'),
  xt.add_column('bankaccnt', 'bankaccnt_ach_enabled',         'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_ach_origin',             'TEXT', $$DEFAULT '' NOT NULL$$,  'public'),
  xt.add_column('bankaccnt', 'bankaccnt_ach_genchecknum',     'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_ach_leadtime',        'INTEGER', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_ach_lastdate',           'DATE', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_ach_lastfileid', 'CHARACTER(1)', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_ach_origintype',         'TEXT', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_ach_originname',         'TEXT', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_ach_desttype',           'TEXT', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_ach_fed_dest',           'TEXT', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_ach_destname',           'TEXT', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_ach_dest',               'TEXT', NULL, 'public'),
  xt.add_column('bankaccnt', 'bankaccnt_ach_prefix',             'TEXT', '',   'public'),
  xt.add_column('bankaccnt','bankaccnt_prnt_check',           'BOOLEAN', 'NOT NULL DEFAULT TRUE', 'public');

SELECT
  xt.add_constraint('bankaccnt', 'bankaccnt_pkey',
                    'PRIMARY KEY (bankaccnt_id)', 'public'),
  xt.add_constraint('bankaccnt', 'bankaccnt_bankaccnt_name_check',
                    $$CHECK bankaccnt_name <> ''$$, 'public'),
  xt.add_constraint('bankaccnt', 'bankaccnt_bankaccnt_name_key',
                    'UNIQUE (bankaccnt_name)', 'public'),
  xt.add_constraint('bankaccnt', 'bankaccnt_to_curr_symbol',
                    'FOREIGN KEY (bankaccnt_curr_id) REFERENCES curr_symbol(curr_id)', 'public');

ALTER TABLE public.bankaccnt ENABLE TRIGGER ALL;

COMMENT ON TABLE bankaccnt IS 'Bank Account information';
