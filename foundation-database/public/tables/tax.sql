SELECT xt.create_table('tax', 'public');

ALTER TABLE public.tax DISABLE TRIGGER ALL;

SELECT
  xt.add_column('tax', 'tax_id',              'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('tax', 'tax_code',              'TEXT', 'NOT NULL', 'public'),
  xt.add_column('tax', 'tax_descrip',           'TEXT', NULL, 'public'),
  xt.add_column('tax', 'tax_sales_accnt_id', 'INTEGER', NULL, 'public'),
  xt.add_column('tax', 'tax_taxclass_id',    'INTEGER', NULL, 'public'),
  xt.add_column('tax', 'tax_taxauth_id',     'INTEGER', NULL, 'public'),
  xt.add_column('tax', 'tax_basis_tax_id',   'INTEGER', NULL, 'public'),
  xt.add_column('tax','tax_dist_accnt_id',   'INTEGER', NULL, 'public');

ALTER TABLE tax DROP COLUMN IF EXISTS tax_armemo;
ALTER TABLE tax DROP COLUMN IF EXISTS tax_apmemo;

SELECT
  xt.add_constraint('tax', 'tax_pkey', 'PRIMARY KEY (tax_id)', 'public'),
  xt.add_constraint('tax', 'tax_tax_code_check', $$CHECK (tax_code <> '')$$, 'public'),
  xt.add_constraint('tax', 'tax_tax_basis_tax_id_fkey',
                    'FOREIGN KEY (tax_basis_tax_id) REFERENCES tax(tax_id)
                     ON DELETE CASCADE', 'public'),
  xt.add_constraint('tax', 'tax_tax_sales_accnt_id_fkey',
                    'FOREIGN KEY (tax_sales_accnt_id) REFERENCES accnt(accnt_id)', 'public'),
  xt.add_constraint('tax', 'tax_tax_taxauth_id_fkey',
                    'FOREIGN KEY (tax_taxauth_id) REFERENCES taxauth(taxauth_id)', 'public'),
  xt.add_constraint('tax', 'tax_tax_taxclass_id_fkey',
                    'FOREIGN KEY (tax_taxclass_id) REFERENCES taxclass(taxclass_id)', 'public');

ALTER TABLE public.tax ENABLE TRIGGER ALL;

COMMENT ON TABLE tax IS 'Tax information';

COMMENT ON COLUMN tax.tax_sales_accnt_id IS 'Deprecated column - DO NOT USE';
