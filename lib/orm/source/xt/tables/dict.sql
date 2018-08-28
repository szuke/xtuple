-- table definition

select xt.create_table('dictobsolete');
select xt.add_column('dictobsolete','dict_id', 'serial', 'primary key');
select xt.add_column('dictobsolete','dict_language_name', 'text');
select xt.add_column('dictobsolete','dict_ext_id', 'integer', 'references xt.ext (ext_id)');
select xt.add_column('dictobsolete','dict_is_database', 'boolean');
select xt.add_column('dictobsolete','dict_is_framework', 'boolean');
select xt.add_column('dictobsolete','dict_usr_username', 'text');
select xt.add_column('dictobsolete','dict_date', 'date');
select xt.add_column('dictobsolete','dict_strings', 'text');

comment on table xt.dictobsolete is 'Dictionary for linguist';
