SELECT xt.create_table('ccard', 'public');

ALTER TABLE public.ccard DISABLE TRIGGER ALL;

SELECT
  xt.add_column('ccard', 'ccard_id',                       'serial',                      'NOT NULL',            'public'),
  xt.add_column('ccard', 'ccard_seq',                      'integer',                     'DEFAULT 10 NOT NULL', 'public'),
  xt.add_column('ccard', 'ccard_cust_id',                  'integer',                     'NOT NULL',            'public'),
  xt.add_column('ccard', 'ccard_active',                   'boolean',                     'DEFAULT true',        'public'),
  xt.add_column('ccard', 'ccard_name',                     'bytea',                       '',                    'public'),
  xt.add_column('ccard', 'ccard_address1',                 'bytea',                       '',                    'public'),
  xt.add_column('ccard', 'ccard_address2',                 'bytea',                       '',                    'public'),
  xt.add_column('ccard', 'ccard_city',                     'bytea',                       '',                    'public'),
  xt.add_column('ccard', 'ccard_state',                    'bytea',                       '',                    'public'),
  xt.add_column('ccard', 'ccard_zip',                      'bytea',                       '',                    'public'),
  xt.add_column('ccard', 'ccard_country',                  'bytea',                       '',                    'public'),
  xt.add_column('ccard', 'ccard_number',                   'bytea',                       '',                    'public'),
  xt.add_column('ccard', 'ccard_debit',                    'boolean',                     'DEFAULT false',       'public'),
  xt.add_column('ccard', 'ccard_month_expired',            'bytea',                       '',                    'public'),
  xt.add_column('ccard', 'ccard_year_expired',             'bytea',                       '',                    'public'),
  xt.add_column('ccard', 'ccard_type',                     'character(1)',                'NOT NULL',            'public'),
  xt.add_column('ccard', 'ccard_date_added',               'timestamp without time zone', $$DEFAULT ('now'::text)::timestamp(6) with time zone NOT NULL$$, 'public'),
  xt.add_column('ccard', 'ccard_lastupdated',              'timestamp without time zone', $$DEFAULT ('now'::text)::timestamp(6) with time zone NOT NULL$$, 'public'),
  xt.add_column('ccard', 'ccard_added_by_username',        'text',                        'DEFAULT geteffectivextuser() NOT NULL', 'public'),
  xt.add_column('ccard', 'ccard_last_updated_by_username', 'text',                        'DEFAULT geteffectivextuser() NOT NULL', 'public'),
  xt.add_column('ccard', 'obj_uuid',                       'uuid',                        'DEFAULT uuid_generate_v4()', 'public', 'A UUID for this record.');

SELECT
  xt.add_constraint('ccard', 'ccard_ccard_cust_id_fkey',
                    'FOREIGN KEY (ccard_cust_id) REFERENCES custinfo(cust_id)', 'public'),
  xt.add_constraint('ccard', 'ccard_obj_uuid_id',
                    'UNIQUE (obj_uuid)', 'public'),
  xt.add_constraint('ccard', 'ccard_ccard_type_fkey',
                    'FOREIGN KEY (ccard_type) REFERENCES ccbank(ccbank_ccard_type)', 'public');

ALTER TABLE public.ccard ENABLE TRIGGER ALL;
