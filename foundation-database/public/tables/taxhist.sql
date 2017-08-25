SELECT xt.create_table('taxhist', 'public');

ALTER TABLE public.taxhist DISABLE TRIGGER ALL;

SELECT
  xt.add_column('taxhist', 'taxhist_id',              'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('taxhist', 'taxhist_parent_id',      'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('taxhist', 'taxhist_taxtype_id',     'INTEGER', NULL,       'public'),
  xt.add_column('taxhist', 'taxhist_tax_id',         'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('taxhist', 'taxhist_basis',    'NUMERIC(16,2)', 'NOT NULL', 'public'),
  xt.add_column('taxhist', 'taxhist_basis_tax_id',   'INTEGER', NULL,       'public'),
  xt.add_column('taxhist', 'taxhist_sequence',       'INTEGER', NULL,       'public'),
  xt.add_column('taxhist', 'taxhist_percent',  'NUMERIC(10,6)', 'NOT NULL', 'public'),
  xt.add_column('taxhist', 'taxhist_amount',   'NUMERIC(16,2)', 'NOT NULL', 'public'),
  xt.add_column('taxhist', 'taxhist_tax',      'NUMERIC(16,6)', 'NOT NULL', 'public'),
  xt.add_column('taxhist', 'taxhist_docdate',           'DATE', 'NOT NULL', 'public'),
  xt.add_column('taxhist', 'taxhist_distdate',          'DATE', NULL,       'public'),
  xt.add_column('taxhist', 'taxhist_curr_id',        'INTEGER', NULL,       'public'),
  xt.add_column('taxhist', 'taxhist_curr_rate',      'NUMERIC', NULL,       'public'),
  xt.add_column('taxhist', 'taxhist_journalnumber',  'INTEGER', NULL,       'public'),
  xt.add_column('taxhist', 'taxhist_doctype',           'TEXT', NULL,       'public'),
  xt.add_column('taxhist', 'taxhist_reverse_charge', 'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public');

SELECT
  xt.add_constraint('taxhist', 'taxhist_pkey', 'PRIMARY KEY (taxhist_id)', 'public'),
  xt.add_constraint('taxhist', 'taxhist_taxhist_curr_id_fkey',
                    'FOREIGN KEY (taxhist_curr_id) REFERENCES curr_symbol(curr_id)', 'public'),
  xt.add_constraint('taxhist', 'taxhist_taxhist_tax_id_fkey',
                    'FOREIGN KEY (taxhist_tax_id) REFERENCES tax(tax_id)', 'public'),
  xt.add_constraint('taxhist', 'taxhist_taxhist_taxtype_id_fkey',
                    'FOREIGN KEY (taxhist_taxtype_id) REFERENCES taxtype(taxtype_id)', 'public');

ALTER TABLE public.taxhist ENABLE TRIGGER ALL;

COMMENT ON TABLE taxhist IS 'A table type to record tax transaction history. Inherited by other tables that actually record history. As the parent, queries can be run against it that will join all child tables. ';

COMMENT ON COLUMN taxhist.taxhist_id IS 'Primary key';
COMMENT ON COLUMN taxhist.taxhist_parent_id IS 'Source parent id.';
COMMENT ON COLUMN taxhist.taxhist_taxtype_id IS 'Tax type id';
COMMENT ON COLUMN taxhist.taxhist_tax_id IS 'Tax code id.';
COMMENT ON COLUMN taxhist.taxhist_basis IS 'Base price amount on which the tax calculation is based.';
COMMENT ON COLUMN taxhist.taxhist_basis_tax_id IS 'Tax rate calculation basis.  If null, then the amount of the parent document, otherwise calculated on the result amount of the tax code id referenced.';
COMMENT ON COLUMN taxhist.taxhist_amount IS 'Flat tax amount.';
COMMENT ON COLUMN taxhist.taxhist_tax IS 'Calculated tax amount.';
COMMENT ON COLUMN taxhist.taxhist_docdate IS 'The date of the parent document.';
COMMENT ON COLUMN taxhist.taxhist_distdate IS 'The G/L distribution date of the parent document.';
