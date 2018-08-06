SELECT xt.create_table('grp', 'public');

ALTER TABLE public.grp DISABLE TRIGGER ALL;

SELECT
  xt.add_column('grp', 'grp_id',    'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('grp', 'grp_name',    'TEXT', 'NOT NULL', 'public'),
  xt.add_column('grp', 'grp_descrip', 'TEXT', NULL,       'public');

select xt.add_column('grp', 'grp_showimmenu', 'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public');
select xt.add_column('grp', 'grp_showpdmenu', 'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public');
select xt.add_column('grp', 'grp_showmsmenu', 'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public');
select xt.add_column('grp', 'grp_showwomenu', 'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public');
select xt.add_column('grp', 'grp_showcrmmenu', 'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public');
select xt.add_column('grp', 'grp_showpomenu', 'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public');
select xt.add_column('grp', 'grp_showsomenu', 'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public');
select xt.add_column('grp', 'grp_showglmenu', 'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public');
select xt.add_column('grp', 'grp_showimtoolbar', 'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public');
select xt.add_column('grp', 'grp_showpdtoolbar', 'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public');
select xt.add_column('grp', 'grp_showmstoolbar', 'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public');
select xt.add_column('grp', 'grp_showwotoolbar', 'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public');
select xt.add_column('grp', 'grp_showcrmtoolbar', 'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public');
select xt.add_column('grp', 'grp_showpotoolbar', 'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public');
select xt.add_column('grp', 'grp_showsotoolbar', 'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public');
select xt.add_column('grp', 'grp_showgltoolbar', 'BOOLEAN', 'NOT NULL DEFAULT FALSE', 'public');

SELECT
  xt.add_constraint('grp', 'grp_pkey',         'PRIMARY KEY (grp_id)',       'public'),
  xt.add_constraint('grp', 'grp_grp_name_key', 'UNIQUE (grp_name)',          'public'),
  xt.add_constraint('grp', 'grp_grp_name_check', $$CHECK (grp_name <> '')$$, 'public');

ALTER TABLE public.grp ENABLE TRIGGER ALL;
