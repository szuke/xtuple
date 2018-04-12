select xt.add_index('sltrans', 'sltrans_sequence', 'sltrans_sequence_idx', 'btree', 'public');
select xt.add_index('sltrans', 'sltrans_accnt_id', 'sltrans_sltrans_accnt_id_idx', 'btree', 'public');
select xt.add_index('sltrans', 'sltrans_date', 'sltrans_sltrans_date_idx', 'btree', 'public');
select xt.add_index('sltrans', 'sltrans_journalnumber', 'sltrans_sltrans_journalnumber_idx', 'btree', 'public');
