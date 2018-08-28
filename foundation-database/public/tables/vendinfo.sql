SELECT xt.create_table('vendinfo', 'public');

ALTER TABLE public.vendinfo DISABLE TRIGGER ALL;

SELECT
  xt.add_column('vendinfo', 'vend_id',                'SERIAL', 'NOT NULL',                      'public'),
  xt.add_column('vendinfo', 'vend_name',                'TEXT', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_lastpurchdate',       'DATE', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_active',           'BOOLEAN', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_po',               'BOOLEAN', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_comments',            'TEXT', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_pocomments',          'TEXT', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_number',              'TEXT', 'NOT NULL',                      'public'),
  xt.add_column('vendinfo', 'vend_1099',             'BOOLEAN', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_exported',         'BOOLEAN', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_fobsource',   'CHARACTER(1)', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_fob',                 'TEXT', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_terms_id',         'INTEGER', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_shipvia',             'TEXT', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_vendtype_id',      'INTEGER', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_qualified',        'BOOLEAN', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_ediemail',            'TEXT', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_ediemailbody',        'TEXT', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_edisubject',          'TEXT', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_edifilename',         'TEXT', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_accntnum',            'TEXT', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_emailpodelivery',  'BOOLEAN', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_restrictpurch',    'BOOLEAN', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_edicc',               'TEXT', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_curr_id',          'INTEGER', 'DEFAULT basecurrid()',          'public'),
  xt.add_column('vendinfo', 'vend_cntct1_id',        'INTEGER', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_cntct2_id',        'INTEGER', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_addr_id',          'INTEGER', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_match',            'BOOLEAN', 'DEFAULT false NOT NULL',        'public'),
  xt.add_column('vendinfo', 'vend_ach_enabled',      'BOOLEAN', 'DEFAULT false NOT NULL',        'public'),
  xt.add_column('vendinfo', 'vend_ach_accnttype',       'TEXT', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_ach_use_vendinfo', 'BOOLEAN', 'DEFAULT true NOT NULL',         'public'),
  xt.add_column('vendinfo', 'vend_ach_indiv_number',    'TEXT', $$DEFAULT '' NOT NULL$$,         'public'),
  xt.add_column('vendinfo', 'vend_ach_indiv_name',      'TEXT', $$DEFAULT '' NOT NULL$$,         'public'),
  xt.add_column('vendinfo', 'vend_ediemailhtml',     'BOOLEAN', 'DEFAULT false NOT NULL',        'public'),
  xt.add_column('vendinfo', 'vend_ach_routingnumber',  'BYTEA', $$NOT NULL$$, 'public'),
  xt.add_column('vendinfo', 'vend_ach_accntnumber',    'BYTEA', $$NOT NULL$$, 'public'),
  xt.add_column('vendinfo', 'vend_taxzone_id',       'INTEGER', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_accnt_id',         'INTEGER', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_expcat_id',        'INTEGER', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_tax_id',           'INTEGER', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_taxtype_id',       'INTEGER', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_potype_id',        'INTEGER', NULL,                            'public'),
  xt.add_column('vendinfo', 'vend_created',      'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('vendinfo', 'vend_lastupdated',  'TIMESTAMP WITH TIME ZONE', NULL, 'public');

ALTER TABLE public.vendinfo
  ALTER COLUMN vend_ach_routingnumber SET DEFAULT '\x00'::bytea,
  ALTER COLUMN vend_ach_accntnumber   SET DEFAULT '\x00'::bytea,
  ALTER COLUMN vend_expcat_id DROP DEFAULT,
  ALTER COLUMN vend_tax_id DROP DEFAULT;

UPDATE vendinfo SET vend_accnt_id=NULL WHERE vend_accnt_id=-1;
UPDATE vendinfo SET vend_expcat_id=NULL WHERE vend_expcat_id=-1;
UPDATE vendinfo SET vend_tax_id=NULL WHERE vend_tax_id=-1;

SELECT
  xt.add_constraint('vendinfo', 'vend_pkey', 'PRIMARY KEY (vend_id)', 'public'),
  xt.add_constraint('vendinfo', 'vendinfo_vend_number_key',
                    'UNIQUE (vend_number)', 'public'),
  xt.add_constraint('vendinfo', 'vendinfo_vend_ach_accnttype_check',
                    $$CHECK (vend_ach_accnttype IN ('K', 'C'))$$, 'public'),
  xt.add_constraint('vendinfo', 'vendinfo_vend_number_check',
                    $$CHECK (vend_number <> '')$$, 'public'),
  xt.add_constraint('vendinfo', 'vend_to_curr_symbol',
                    'FOREIGN KEY (vend_curr_id) REFERENCES curr_symbol(curr_id)', 'public'),
  xt.add_constraint('vendinfo', 'vend_vend_cntct1_id_fkey',
                    'FOREIGN KEY (vend_cntct1_id) REFERENCES cntct(cntct_id)', 'public'),
  xt.add_constraint('vendinfo', 'vend_vend_cntct2_id_fkey',
                    'FOREIGN KEY (vend_cntct2_id) REFERENCES cntct(cntct_id)', 'public'),
  xt.add_constraint('vendaddrinfo', 'vendaddrinfo_vendaddr_addr_id_fkey',
                    'FOREIGN KEY (vendaddr_addr_id) REFERENCES addr(addr_id)', 'public'),
  xt.add_constraint('vendinfo', 'vendinfo_vend_addr_id_fkey',
                    'FOREIGN KEY (vend_addr_id) REFERENCES addr(addr_id)', 'public'),
  xt.add_constraint('vendinfo', 'vendinfo_vend_taxzone_id_fkey',
                    'FOREIGN KEY (vend_taxzone_id) REFERENCES taxzone(taxzone_id)', 'public'),
  xt.add_constraint('vendinfo', 'vendinfo_vend_accnt_id_fkey',
                    'FOREIGN KEY (vend_accnt_id) REFERENCES accnt(accnt_id)', 'public'),
  xt.add_constraint('vendinfo', 'vendinfo_vend_expcat_id_fkey',
                    'FOREIGN KEY (vend_expcat_id) REFERENCES expcat(expcat_id)', 'public'),
  xt.add_constraint('vendinfo', 'vendinfo_vend_tax_id_fkey',
                    'FOREIGN KEY (vend_tax_id) REFERENCES tax(tax_id)', 'public'),
  xt.add_constraint('vendinfo', 'vendinfo_vend_taxtype_id_fkey',
                    'FOREIGN KEY (vend_taxtype_id) REFERENCES taxtype(taxtype_id)', 'public'),
  xt.add_constraint('vendinfo', 'vendinfo_vend_vendtype_id_fkey',
                    'FOREIGN KEY (vend_vendtype_id) REFERENCES vendtype(vendtype_id)', 'public'),
  xt.add_constraint('vendinfo', 'vendinfo_potype_id_fkey',
                    'FOREIGN KEY (vend_potype_id) REFERENCES potype (potype_id)', 'public');

DO $$
BEGIN
  IF EXISTS(SELECT 1
              FROM information_schema.tables
             WHERE table_schema = 'xt'
               AND table_name = 'vendinfoext') THEN
    UPDATE vendinfo
       SET vend_potype_id = vendinfoext_potype_id
      FROM xt.vendinfoext
     WHERE vend_id = vendinfoext_id;

    DROP TABLE xt.vendinfoext;
  END IF;
END
$$ LANGUAGE plpgsql;

ALTER TABLE public.vendinfo ENABLE TRIGGER ALL;

COMMENT ON TABLE vendinfo IS 'Vendor information';

COMMENT ON COLUMN vendinfo.vend_ach_accnttype IS 'Type of bank account: K = checKing, C = Cash = savings. These values were chosen to be consistent with bankaccnt_type.';
COMMENT ON COLUMN vendinfo.vend_potype_id     IS 'Vendor default PO type';
COMMENT ON COLUMN vendinfo.vend_taxtype_id    IS 'Vendor default tax type for miscellaneous distributions';
