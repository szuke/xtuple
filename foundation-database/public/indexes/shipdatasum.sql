select xt.add_index('shipdatasum', 'shipdata_cohead_number', 'shipdatasum_cohead_number_idx', 'btree', 'public');
select xt.add_index('shipdatasum', 'shipdatasum_cosmisc_tracknum', 'shipdatasum_cosmisc_tracknum_idx', 'btree', 'public');
