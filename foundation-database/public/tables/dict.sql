select dropIfExists('TABLE', 'qm');
select xt.create_table('dict', 'public');

ALTER TABLE public.dict DISABLE TRIGGER ALL;

select xt.add_column('dict', 'dict_id', 'SERIAL', 'PRIMARY KEY', 'public');
select xt.add_column('dict', 'dict_lang_id', 'INTEGER', 'NOT NULL', 'public');
select xt.add_column('dict', 'dict_country_id', 'INTEGER', 'NULL', 'public');
select xt.add_column('dict', 'dict_version', 'TEXT', 'NOT NULL', 'public');
select xt.add_column('dict', 'dict_data', 'BYTEA', 'NOT NULL', 'public');
select xt.add_column('dict', 'dict_created', 'TIMESTAMP WITH TIME ZONE', 'NOT NULL DEFAULT now()', 'public');

select xt.add_constraint('dict', 'dict_lang_id_fkey', 'FOREIGN KEY (dict_lang_id) REFERENCES lang (lang_id)', 'public');
select xt.add_constraint('dict', 'dict_country_id_fkey', 'FOREIGN KEY (dict_country_id) REFERENCES country (country_id)', 'public');
select xt.add_constraint('dict', 'dict_dict_version_check', $$CHECK (trim(dict_version) != '')$$, 'public');

ALTER TABLE public.dict ENABLE TRIGGER ALL;
