SELECT xt.create_table('docass', 'public');

ALTER TABLE public.docass DISABLE TRIGGER ALL;

SELECT
  xt.add_column('docass', 'docass_id',          'SERIAL',       'NOT NULL', 'public'),
  xt.add_column('docass', 'docass_source_id',   'INTEGER',      'NOT NULL', 'public'),
  xt.add_column('docass', 'docass_source_type', 'TEXT',         'NOT NULL', 'public'),
  xt.add_column('docass', 'docass_target_id',   'INTEGER',      'NOT NULL', 'public'),
  xt.add_column('docass', 'docass_notes',       'TEXT',               NULL, 'public'),
  xt.add_column('docass', 'docass_target_type', 'TEXT',         $$DEFAULT 'URL' NOT NULL$$, 'public'),
  xt.add_column('docass', 'docass_purpose',     'CHARACTER(1)', $$DEFAULT 'S'   NOT NULL$$, 'public'),
  xt.add_column('docass', 'docass_username',    'TEXT',                     NULL, 'public'),
  xt.add_column('docass', 'docass_created',     'TIMESTAMP WITH TIME ZONE', NULL, 'public');

SELECT
  xt.add_constraint('docass', 'docass_pkey', 'PRIMARY KEY (docass_id)', 'public'),
  xt.add_constraint('docass', 'docass_docass_purpose_check',
                    $$CHECK (docass_purpose IN ('I', 'E', 'M', 'P', 'A', 'C', 'S', 'D'))$$, 'public');

ALTER TABLE public.docass ENABLE TRIGGER ALL;

COMMENT ON TABLE docass IS 'Document Assignment References';
