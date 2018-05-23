select xt.add_index('aropen', 'aropen_cust_id', 'aropen_aropen_cust_id_idx', 'btree', 'public');
select xt.add_index('aropen', 'aropen_docnumber', 'aropen_aropen_docnumber_idx', 'btree', 'public');
select xt.add_index('aropen', 'aropen_doctype', 'aropen_aropen_doctype_idx', 'btree', 'public');
select xt.add_index('aropen', 'aropen_open', 'aropen_aropen_open_idx', 'btree', 'public');
select xt.add_index('aropen', 'aropen_posted', 'aropen_posted_idx', 'btree', 'public');
