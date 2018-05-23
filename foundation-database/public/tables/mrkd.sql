SELECT xt.create_table('mrkd', 'public');
SELECT xt.add_column('mrkd', 'mrkd_id', 'SERIAL', 'PRIMARY KEY', 'public');
SELECT xt.add_column('mrkd', 'mrkd_target_type', 'TEXT', 'NOT NULL', 'public');
SELECT xt.add_column('mrkd', 'mrkd_target_id', 'INTEGER', 'NOT NULL', 'public');
SELECT xt.add_column('mrkd', 'mrkd_username', 'TEXT', 'NOT NULL DEFAULT getEffectiveXtUser()', 'public');

SELECT xt.add_constraint('mrkd', 'mrkd_mrkd_target_username_key', 'UNIQUE (mrkd_target_type, mrkd_target_id, mrkd_username)', 'public');
SELECT xt.add_constraint('mrkd', 'mrkd_mrkd_target_type_check', $$CHECK (trim(mrkd_target_type) != '')$$, 'public');
SELECT xt.add_constraint('mrkd', 'mrkd_mrkd_username_check', $$CHECK (trim(mrkd_username) != '')$$, 'public');
