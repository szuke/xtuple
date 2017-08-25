select xt.create_table('cmnttypesource', 'public');

ALTER TABLE public.cmnttypesource DISABLE TRIGGER ALL;

select xt.add_column('cmnttypesource', 'cmnttypesource_id', 'serial', 'primary key', 'public');
select xt.add_column('cmnttypesource', 'cmnttypesource_cmnttype_id', 'integer', NULL, 'public');
select xt.add_column('cmnttypesource', 'cmnttypesource_source_id', 'integer', NULL, 'public');

ALTER SEQUENCE public.cmnttypesource_cmnttypesource_id_seq OWNED BY cmnttypesource.cmnttypesource_id;
ALTER TABLE public.cmnttypesource_cmnttypesource_id_seq OWNER TO admin;

ALTER TABLE public.cmnttypesource ALTER cmnttypesource_cmnttype_id set not null;
ALTER TABLE public.cmnttypesource ALTER cmnttypesource_source_id set not null;

SELECT
  xt.add_constraint('cmnttypesource', 'cmnttypesource_pkey',
                    'PRIMARY KEY (cmnttypesource_id)', 'public'),
  xt.add_constraint('cmnttypesource', 'cmnttypesource_cmnttypesource_cmnttype_id_fkey',
                    'FOREIGN KEY (cmnttypesource_cmnttype_id) REFERENCES cmnttype(cmnttype_id)', 'public'),
  xt.add_constraint('cmnttypesource', 'cmnttypesource_cmnttypesource_source_id_fkey',
                    'FOREIGN KEY (cmnttypesource_source_id) REFERENCES source(source_id)', 'public');

ALTER TABLE public.cmnttypesource ENABLE TRIGGER ALL;

COMMENT ON TABLE cmnttypesource IS 'Description of which types of comment the user should be allowed to select for various types of document (source).';
