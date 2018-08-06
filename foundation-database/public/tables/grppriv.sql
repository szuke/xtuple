SELECT xt.create_table('grppriv', 'public');

SELECT xt.add_column('grppriv', 'grppriv_id', 'SERIAL', 'PRIMARY KEY', 'public');
SELECT xt.add_column('grppriv', 'grppriv_grp_id', 'INTEGER', 'NOT NULL', 'public');
SELECT xt.add_column('grppriv', 'grppriv_priv_id', 'INTEGER', 'NOT NULL', 'public');

ALTER TABLE grppriv DROP CONSTRAINT IF EXISTS grppriv_grppriv_grp_id_fkey;

SELECT xt.add_constraint('grppriv', 'grppriv_grppriv_grp_id_fkey', 'FOREIGN KEY (grppriv_grp_id) REFERENCES grp(grp_id) ON DELETE CASCADE', 'public');
