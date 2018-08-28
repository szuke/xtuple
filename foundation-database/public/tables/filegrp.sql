SELECT xt.create_table('filegrp', 'public');

ALTER TABLE public.filegrp DISABLE TRIGGER ALL;

SELECT
   xt.add_column('filegrp', 'filegrp_file_id',  'INTEGER', 'NOT NULL', 'public'),
   xt.add_column('filegrp', 'filegrp_grp_id',   'INTEGER', 'NOT NULL', 'public');

SELECT
  xt.add_constraint('filegrp', 'filegrp_pkey', 'PRIMARY KEY (filegrp_file_id, filegrp_grp_id)', 'public'),
  xt.add_constraint('filegrp', 'filegrp_grp_id_fk', 
                    'FOREIGN KEY (filegrp_grp_id) REFERENCES grp(grp_id) ON DELETE CASCADE', 'public');

ALTER TABLE public.filegrp ENABLE TRIGGER ALL;

COMMENT ON TABLE filegrp IS 'File and Document permissions';
