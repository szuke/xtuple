SELECT xt.create_table('vodist', 'public');

ALTER TABLE public.vodist DISABLE TRIGGER ALL;

SELECT
  xt.add_column('vodist', 'vodist_id',                 'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('vodist', 'vodist_poitem_id',         'INTEGER', NULL, 'public'),
  xt.add_column('vodist', 'vodist_vohead_id',         'INTEGER', NULL, 'public'),
  xt.add_column('vodist', 'vodist_costelem_id',       'INTEGER', NULL, 'public'),
  xt.add_column('vodist', 'vodist_accnt_id',          'INTEGER', NULL, 'public'),
  xt.add_column('vodist', 'vodist_amount',      'NUMERIC(18,6)', NULL, 'public'),
  xt.add_column('vodist', 'vodist_qty',         'NUMERIC(18,6)', NULL, 'public'),
  xt.add_column('vodist', 'vodist_expcat_id',         'INTEGER', 'DEFAULT -1', 'public'),
  xt.add_column('vodist', 'vodist_tax_id',            'INTEGER', 'DEFAULT -1', 'public'),
  xt.add_column('vodist', 'vodist_discountable',      'BOOLEAN', 'DEFAULT true NOT NULL', 'public'),
  xt.add_column('vodist', 'vodist_notes',                'TEXT', NULL, 'public'),
  xt.add_column('vodist', 'vodist_taxtype_id',        'INTEGER', NULL, 'public'),
  xt.add_column('vodist', 'vodist_freight_vohead_id', 'INTEGER', NULL, 'public'),
  xt.add_column('vodist', 'vodist_freight_dist_method',  'TEXT', NULL, 'public');

SELECT
  xt.add_constraint('vodist', 'vodist_pkey', 'PRIMARY KEY (vodist_id)', 'public'),
  xt.add_constraint('vodist','vodist_taxtype_id_fkey',
                    'FOREIGN KEY (vodist_taxtype_id) REFERENCES taxtype(taxtype_id)', 'public'),
  xt.add_constraint('vodist','vodist_freight_vohead_id_fkey',
                    'FOREIGN KEY (vodist_freight_vohead_id) REFERENCES vohead(vohead_id)', 'public'),
  xt.add_constraint('vodist','vodist_freight_dist_method_check',
                    $$CHECK (vodist_freight_dist_method IN ('Q', 'V', 'W'))$$, 'public');

ALTER TABLE public.vodist ENABLE TRIGGER ALL;

COMMENT ON TABLE vodist IS 'Voucher distribution information';

COMMENT ON COLUMN public.vodist.vodist_freight_vohead_id
  IS 'The original Voucher to determine the items freight will be distributed to';
COMMENT ON COLUMN public.vodist.vodist_freight_dist_method
  IS 'The Freight distribution method';

