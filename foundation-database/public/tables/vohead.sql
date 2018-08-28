SELECT xt.create_table('vohead', 'public');

ALTER TABLE public.vohead DISABLE TRIGGER ALL;

SELECT
  xt.add_column('vohead', 'vohead_id',                   'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('vohead', 'vohead_number',                 'TEXT', 'NOT NULL', 'public'),
  xt.add_column('vohead', 'vohead_pohead_id',           'INTEGER', NULL, 'public'),
  xt.add_column('vohead', 'vohead_posted',              'BOOLEAN', NULL, 'public'),
  xt.add_column('vohead', 'vohead_duedate',                'DATE', NULL, 'public'),
  xt.add_column('vohead', 'vohead_invcnumber',             'TEXT', NULL, 'public'),
  xt.add_column('vohead', 'vohead_amount',        'NUMERIC(16,4)', NULL, 'public'),
  xt.add_column('vohead', 'vohead_docdate',                'DATE', NULL, 'public'),
  xt.add_column('vohead', 'vohead_1099',                'BOOLEAN', NULL, 'public'),
  xt.add_column('vohead', 'vohead_distdate',               'DATE', NULL, 'public'),
  xt.add_column('vohead', 'vohead_reference',              'TEXT', NULL, 'public'),
  xt.add_column('vohead', 'vohead_terms_id',            'INTEGER', NULL, 'public'),
  xt.add_column('vohead', 'vohead_vend_id',             'INTEGER', NULL, 'public'),
  xt.add_column('vohead', 'vohead_curr_id',             'INTEGER', 'DEFAULT basecurrid()', 'public'),
  xt.add_column('vohead', 'vohead_adjtaxtype_id',       'INTEGER', NULL, 'public'),
  xt.add_column('vohead', 'vohead_freighttaxtype_id',   'INTEGER', NULL, 'public'),
  xt.add_column('vohead', 'vohead_gldistdate',             'DATE', NULL, 'public'),
  xt.add_column('vohead', 'vohead_misc',                'BOOLEAN', NULL, 'public'),
  xt.add_column('vohead', 'vohead_taxzone_id',          'INTEGER', NULL, 'public'),
  xt.add_column('vohead', 'vohead_taxtype_id',          'INTEGER', NULL, 'public'),
  xt.add_column('vohead', 'vohead_notes',                  'TEXT', NULL, 'public'),
  xt.add_column('vohead', 'vohead_recurring_vohead_id', 'INTEGER', NULL, 'public'),
  xt.add_column('vohead','vohead_freight',              'NUMERIC', NULL, 'public'),
  xt.add_column('vohead','vohead_freight_expcat_id',    'INTEGER', NULL, 'public'),
  xt.add_column('vohead','vohead_freight_distributed',  'NUMERIC', NULL, 'public');

SELECT
  xt.add_constraint('vohead', 'vohead_pkey', 'PRIMARY KEY (vohead_id)', 'public'),
  xt.add_constraint('vohead', 'vohead_vohead_number_key', 'UNIQUE (vohead_number)', 'public'),
  xt.add_constraint('vohead', 'vohead_to_curr_symbol',
                    'FOREIGN KEY (vohead_curr_id) REFERENCES curr_symbol(curr_id)', 'public'),
  xt.add_constraint('vohead', 'vohead_vohead_adjtaxtype_id_fkey',
                    'FOREIGN KEY (vohead_adjtaxtype_id) REFERENCES taxtype(taxtype_id)', 'public'),
  xt.add_constraint('vohead', 'vohead_vohead_freighttaxtype_id_fkey',
                    'FOREIGN KEY (vohead_freighttaxtype_id) REFERENCES taxtype(taxtype_id)', 'public'),
  xt.add_constraint('vohead', 'vohead_vohead_taxtype_id_fkey',
                    'FOREIGN KEY (vohead_taxtype_id) REFERENCES taxtype(taxtype_id)', 'public'),
  xt.add_constraint('vohead', 'vohead_vohead_taxzone_id_fkey',
                    'FOREIGN KEY (vohead_taxzone_id) REFERENCES taxzone(taxzone_id)', 'public'),
  xt.add_constraint('vohead', 'vohead_vohead_vend_id_fkey',
                    'FOREIGN KEY (vohead_vend_id) REFERENCES vendinfo(vend_id)', 'public'),
  xt.add_constraint('vohead', 'vohead_vohead_number_check',
                    $$CHECK (vohead_number <> '')$$, 'public'),
  xt.add_constraint('vohead', 'fk_vohead_expcat_id',
                    'FOREIGN KEY (vohead_freight_expcat_id) REFERENCES expcat(expcat_id)', 'public');

ALTER TABLE public.vohead ENABLE TRIGGER ALL;

COMMENT ON TABLE vohead IS 'Voucher header information';
