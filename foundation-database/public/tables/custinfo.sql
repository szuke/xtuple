SELECT xt.create_table('custinfo', 'public');

ALTER TABLE public.custinfo DISABLE TRIGGER ALL;

SELECT
  xt.add_column('custinfo', 'cust_id',               'SERIAL',        'NOT NULL',        'public'),
  xt.add_column('custinfo', 'cust_active',           'BOOLEAN',       'NOT NULL',        'public'),
  xt.add_column('custinfo', 'cust_custtype_id',      'INTEGER',       NULL,              'public'),
  xt.add_column('custinfo', 'cust_salesrep_id',      'INTEGER',       NULL,              'public'),
  xt.add_column('custinfo', 'cust_commprcnt',        'NUMERIC(10,6)', NULL,              'public'),
  xt.add_column('custinfo', 'cust_name',             'TEXT',          NULL,              'public'),
  xt.add_column('custinfo', 'cust_creditlmt',        'INTEGER',       NULL,              'public'),
  xt.add_column('custinfo', 'cust_creditrating',     'TEXT',          NULL,              'public'),
  xt.add_column('custinfo', 'cust_financecharge',    'BOOLEAN',       NULL,              'public'),
  xt.add_column('custinfo', 'cust_backorder',        'BOOLEAN',       'NOT NULL',        'public'),
  xt.add_column('custinfo', 'cust_partialship',      'BOOLEAN',       'NOT NULL',        'public'),
  xt.add_column('custinfo', 'cust_terms_id',         'INTEGER',       NULL,              'public'),
  xt.add_column('custinfo', 'cust_discntprcnt',      'NUMERIC(10,6)', 'NOT NULL',        'public'),
  xt.add_column('custinfo', 'cust_balmethod',        'CHARACTER(1)',  'NOT NULL',        'public'),
  xt.add_column('custinfo', 'cust_ffshipto',         'BOOLEAN',       'NOT NULL',        'public'),
  xt.add_column('custinfo', 'cust_shipform_id',      'INTEGER',       NULL,              'public'),
  xt.add_column('custinfo', 'cust_shipvia',          'TEXT',          NULL,              'public'),
  xt.add_column('custinfo', 'cust_blanketpos',       'BOOLEAN',       'NOT NULL',        'public'),
  xt.add_column('custinfo', 'cust_shipchrg_id',      'INTEGER',       'NOT NULL',        'public'),
  xt.add_column('custinfo', 'cust_creditstatus',     'CHARACTER(1)',  'NOT NULL',        'public'),
  xt.add_column('custinfo', 'cust_comments',         'TEXT',          NULL,              'public'),
  xt.add_column('custinfo', 'cust_ffbillto',         'BOOLEAN',      'NOT NULL',         'public'),
  xt.add_column('custinfo', 'cust_usespos',          'BOOLEAN',      'NOT NULL',         'public'),
  xt.add_column('custinfo', 'cust_number',           'TEXT',         'NOT NULL',         'public'),
  xt.add_column('custinfo', 'cust_dateadded',        'DATE',          $$DEFAULT ('now'::text)::date$$, 'public'),
  xt.add_column('custinfo', 'cust_exported',         'BOOLEAN',       'DEFAULT false',   'public'),
  xt.add_column('custinfo', 'cust_emaildelivery',    'BOOLEAN',       'DEFAULT false',   'public'),
  xt.add_column('custinfo', 'cust_ediemail',         'TEXT',          NULL,              'public'),
  xt.add_column('custinfo', 'cust_edisubject',       'TEXT',          NULL,              'public'),
  xt.add_column('custinfo', 'cust_edifilename',      'TEXT',          NULL,              'public'),
  xt.add_column('custinfo', 'cust_ediemailbody',     'TEXT',          NULL,              'public'),
  xt.add_column('custinfo', 'cust_autoupdatestatus', 'BOOLEAN',      'NOT NULL',         'public'),
  xt.add_column('custinfo', 'cust_autoholdorders',   'BOOLEAN',      'NOT NULL',         'public'),
  xt.add_column('custinfo', 'cust_edicc',            'TEXT',         NULL,               'public'),
  xt.add_column('custinfo', 'cust_ediprofile_id',    'INTEGER',       NULL,              'public'),
  xt.add_column('custinfo', 'cust_preferred_warehous_id', 'INTEGER', 'DEFAULT -1 NOT NULL',  'public'),
  xt.add_column('custinfo', 'cust_curr_id',               'INTEGER', 'DEFAULT basecurrid()', 'public'),
  xt.add_column('custinfo', 'cust_creditlmt_curr_id',     'INTEGER', 'DEFAULT basecurrid()', 'public'),
  xt.add_column('custinfo', 'cust_cntct_id',         'INTEGER', NULL,                    'public'),
  xt.add_column('custinfo', 'cust_corrcntct_id',     'INTEGER', NULL,                    'public'),
  xt.add_column('custinfo', 'cust_soemaildelivery',  'BOOLEAN', 'DEFAULT false',         'public'),
  xt.add_column('custinfo', 'cust_soediemail',       'TEXT',    NULL,                    'public'),
  xt.add_column('custinfo', 'cust_soedisubject',     'TEXT',    NULL,                    'public'),
  xt.add_column('custinfo', 'cust_soedifilename',    'TEXT',    NULL,                    'public'),
  xt.add_column('custinfo', 'cust_soediemailbody',   'TEXT',    NULL,                    'public'),
  xt.add_column('custinfo', 'cust_soedicc',          'TEXT',    NULL,                    'public'),
  xt.add_column('custinfo', 'cust_soediprofile_id',  'INTEGER', NULL,                    'public'),
  xt.add_column('custinfo', 'cust_gracedays',        'INTEGER', NULL,                    'public'),
  xt.add_column('custinfo', 'cust_ediemailhtml',     'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('custinfo', 'cust_soediemailhtml',   'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('custinfo', 'cust_taxzone_id',       'INTEGER', NULL,                     'public'),
  xt.add_column('custinfo', 'cust_statementcycle',   'TEXT',    NULL,                     'public'),
  xt.add_column('custinfo', 'cust_created',      'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('custinfo', 'cust_lastupdated',  'TIMESTAMP WITH TIME ZONE', NULL, 'public');

SELECT
  xt.add_constraint('custinfo', 'cust_pkey', 'PRIMARY KEY (cust_id)', 'public'),
  xt.add_constraint('custinfo', 'custinfo_balmethod_check',
                    $$CHECK (cust_balmethod IN ('B', 'O'))$$, 'public'),
  xt.add_constraint('custinfo', 'custinfo_creditstatus_check',
                    $$CHECK (cust_creditstatus IN ('G', 'W', 'H'))$$, 'public'),
  xt.add_constraint('custinfo', 'custinfo_cust_number_check',
                    $$CHECK (cust_number <> ''::text)$$, 'public'),
  xt.add_constraint('custinfo', 'custinfo_cust_number_key', 'UNIQUE (cust_number)', 'public'),
  xt.add_constraint('custinfo', 'custinfo_cust_terms_fkey',
                    'FOREIGN KEY (cust_terms_id) REFERENCES terms(terms_id)
                     ON UPDATE RESTRICT ON DELETE RESTRICT', 'public'),
  xt.add_constraint('custinfo', 'custinfo_cust_taxzone_id_fkey',
                    'FOREIGN KEY (cust_taxzone_id) REFERENCES taxzone(taxzone_id)', 'public'),
  xt.add_constraint('custinfo', 'custinfo_cust_shipform_fkey',
                    'FOREIGN KEY (cust_shipform_id) REFERENCES shipform(shipform_id)
                     ON UPDATE RESTRICT ON DELETE RESTRICT', 'public'),
  xt.add_constraint('custinfo', 'cust_creditlmt_to_curr_symbol',
                    'FOREIGN KEY (cust_creditlmt_curr_id) REFERENCES curr_symbol(curr_id)', 'public'),
  xt.add_constraint('custinfo', 'cust_to_curr_symbol',
                    'FOREIGN KEY (cust_curr_id) REFERENCES curr_symbol(curr_id)', 'public'),
  xt.add_constraint('custinfo', 'custinfo_cust_cntct_id_fkey',
                    'FOREIGN KEY (cust_cntct_id) REFERENCES cntct(cntct_id)', 'public'),
  xt.add_constraint('custinfo', 'custinfo_cust_corrcntct_id_fkey',
                    'FOREIGN KEY (cust_corrcntct_id) REFERENCES cntct(cntct_id)', 'public'),
  xt.add_constraint('custinfo', 'custinfo_cust_custtype_fkey',
                    'FOREIGN KEY (cust_custtype_id) REFERENCES custtype(custtype_id)
                     ON UPDATE RESTRICT ON DELETE RESTRICT', 'public'),
  xt.add_constraint('custinfo', 'custinfo_cust_salesrep_fkey',
                    'FOREIGN KEY (cust_salesrep_id) REFERENCES salesrep(salesrep_id)
                     ON UPDATE RESTRICT ON DELETE RESTRICT', 'public');

ALTER TABLE public.custinfo ENABLE TRIGGER ALL;

COMMENT ON TABLE custinfo IS 'Customer information';

COMMENT ON COLUMN custinfo.cust_ediemail IS 'Deprecated column - DO NOT USE';
COMMENT ON COLUMN custinfo.cust_edisubject IS 'Deprecated column - DO NOT USE';
COMMENT ON COLUMN custinfo.cust_edifilename IS 'Deprecated column - DO NOT USE';
COMMENT ON COLUMN custinfo.cust_ediemailbody IS 'Deprecated column - DO NOT USE';
COMMENT ON COLUMN custinfo.cust_edicc IS 'Deprecated column - DO NOT USE';
COMMENT ON COLUMN custinfo.cust_ediprofile_id IS 'Deprecated column - DO NOT USE';
COMMENT ON COLUMN custinfo.cust_soediemail IS 'Deprecated column - DO NOT USE';
COMMENT ON COLUMN custinfo.cust_soedisubject IS 'Deprecated column - DO NOT USE';
COMMENT ON COLUMN custinfo.cust_soedifilename IS 'Deprecated column - DO NOT USE';
COMMENT ON COLUMN custinfo.cust_soediemailbody IS 'Deprecated column - DO NOT USE';
COMMENT ON COLUMN custinfo.cust_soedicc IS 'Deprecated column - DO NOT USE';
COMMENT ON COLUMN custinfo.cust_soediprofile_id IS 'Deprecated column - DO NOT USE';
COMMENT ON COLUMN custinfo.cust_ediemailhtml IS 'Deprecated column - DO NOT USE';
COMMENT ON COLUMN custinfo.cust_soediemailhtml IS 'Deprecated column - DO NOT USE';
