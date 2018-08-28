select xt.create_table('charuse', 'public');

ALTER TABLE public.charuse DISABLE TRIGGER ALL;

select xt.add_column('charuse', 'charuse_id',           'SERIAL',  'PRIMARY KEY',                                         'public'),
       xt.add_column('charuse', 'charuse_char_id',      'INTEGER', 'REFERENCES "char"(char_id) ON DELETE CASCADE',        'public'),
       xt.add_column('charuse', 'charuse_target_type',  'TEXT',    $$NOT NULL DEFAULT ''$$,                               'public'),
       xt.add_column('charuse', 'charuse_created',      'TIMESTAMP WITH TIME ZONE', 'NOT NULL DEFAULT CURRENT_TIMESTAMP', 'public'),
       xt.add_column('charuse', 'charuse_last_modified','TIMESTAMP WITH TIME ZONE', 'NOT NULL DEFAULT CURRENT_TIMESTAMP', 'public');

ALTER TABLE public.charuse ENABLE TRIGGER ALL;

COMMENT ON TABLE public.charuse IS 'This table maps the set of characteristics to the types of record to which they apply. A number of columns in the char table are deprecated and represented as a set of rows here in charuse.';

COMMENT ON COLUMN public.charuse.charuse_id IS 'Internal ID of this charuse record.';
COMMENT ON COLUMN public.charuse.charuse_target_type IS 'If a row exists in the charuse table for a given target type, characteristic assignments can be used';
