select xt.add_index('cohead', 'cohead_status', 'cohead_cohead_status_idx', 'btree', 'public');
select xt.add_index('cohead', 'cohead_cust_id', 'cohead_cust_id_key', 'btree', 'public');
select xt.add_index('cohead', 'cohead_custponumber', 'cohead_custponumber_idx', 'btree', 'public');
select xt.add_index('cohead', 'cohead_shipto_id', 'cohead_shipto_id', 'btree', 'public');
