SELECT xt.create_table('taxass', 'public');

ALTER TABLE public.taxass DISABLE TRIGGER ALL;

SELECT
  xt.add_column('taxass', 'taxass_id',           'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('taxass', 'taxass_taxzone_id',  'INTEGER', NULL,       'public'),
  xt.add_column('taxass', 'taxass_taxtype_id',  'INTEGER', NULL,       'public'),
  xt.add_column('taxass', 'taxass_tax_id',      'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('taxass', 'taxass_reverse_tax', 'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public'),
  xt.add_column('taxass', 'taxass_memo_apply',  'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public');

SELECT
  xt.add_constraint('taxass', 'taxass_pkey', 'PRIMARY KEY (taxass_id)', 'public'),
  xt.add_constraint('taxass', 'taxass_taxass_taxzone_id_key',
                    'UNIQUE (taxass_taxzone_id, taxass_taxtype_id, taxass_tax_id)', 'public'),
  xt.add_constraint('taxass', 'taxass_taxass_tax_id_fkey',
                    'FOREIGN KEY (taxass_tax_id) REFERENCES tax(tax_id)', 'public'),
  xt.add_constraint('taxass', 'taxass_taxass_taxtype_id_fkey',
                    'FOREIGN KEY (taxass_taxtype_id) REFERENCES taxtype(taxtype_id)', 'public'),
  xt.add_constraint('taxass', 'taxass_taxass_taxzone_id_fkey',
                    'FOREIGN KEY (taxass_taxzone_id) REFERENCES taxzone(taxzone_id)', 'public');

ALTER TABLE public.taxass ENABLE TRIGGER ALL;

COMMENT ON TABLE taxass IS 'The tax assignment table associates different tax zones and tax types to a given set of tax codes.';

COMMENT ON COLUMN taxass.taxass_taxzone_id IS 'The id of the tax zone. If NULL any tax zone will apply.';
COMMENT ON COLUMN taxass.taxass_taxtype_id IS 'The id of the tax type. If NULL any tax type will apply.';
COMMENT ON COLUMN taxass.taxass_tax_id IS 'The id of the tax code.';
COMMENT ON COLUMN taxass.taxass_reverse_tax    IS 'Tax Assignment Reverse Charge Tax applicable';
COMMENT ON COLUMN taxass.taxass_memo_apply     IS 'Tax Assignment Automatically apply to AR/AP memos';
