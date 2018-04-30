select xt.add_index('salesaccnt', 'salesaccnt_prodcat_id', 'salesaccnt_prodcat_id_idx', 'btree', 'public');
select xt.add_index('salesaccnt', 'salesaccnt_warehous_id', 'salesaccnt_warehous_id_idx', 'btree', 'public');
