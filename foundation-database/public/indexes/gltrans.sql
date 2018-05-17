select xt.add_index('gltrans', 'gltrans_accnt_id', 'gltrans_gltrans_accnt_id_idx', 'btree', 'public');
select xt.add_index('gltrans', 'gltrans_date', 'gltrans_gltrans_date_idx', 'btree', 'public');
select xt.add_index('gltrans', 'gltrans_journalnumber', 'gltrans_gltrans_journalnumber_idx', 'btree', 'public');
select xt.add_index('gltrans', 'gltrans_sequence', 'gltrans_sequence_idx', 'btree', 'public');
