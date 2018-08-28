select xt.create_table('file', 'public');

select xt.add_column('file', 'file_id', 'SERIAL', 'PRIMARY KEY', 'public');
select xt.add_column('file', 'file_title', 'TEXT', 'NOT NULL', 'public');
select xt.add_column('file', 'file_stream', 'BYTEA', '', 'public');
select xt.add_column('file', 'file_descrip', 'TEXT', 'NOT NULL', 'public');
select xt.add_column('file', 'file_mime_type', 'TEXT', 'NOT NULL DEFAULT ''application/octet-stream''', 'public');
