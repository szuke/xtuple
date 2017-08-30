select xt.add_index('ipsass', 'ipsass_cust_id', 'ipsass_cust_id_idx', 'btree', 'public');
select xt.add_index('ipsass', 'ipsass_custtype_id', 'ipsass_custtype_id_idx', 'btree', 'public');
select xt.add_index('ipsass', 'ipsass_custtype_pattern COLLATE pg_catalog."POSIX"', 'ipsass_custtype_pattern_idx', 'btree', 'public');
select xt.add_index('ipsass', 'ipsass_ipshead_id', 'ipsass_ipshead_id_idx', 'btree', 'public');
select xt.add_index('ipsass', 'ipsass_shipto_id', 'ipsass_shipto_id_idx', 'btree', 'public');
select xt.add_index('ipsass', 'ipsass_shipto_pattern COLLATE pg_catalog."POSIX"', 'ipsass_shipto_pattern_idx', 'btree', 'public');