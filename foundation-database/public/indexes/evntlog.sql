select xt.add_index('evntlog', 'evntlog_dispatched', 'evntlog_dispatched_idx', 'btree', 'public');
select xt.add_index('evntlog', 'evntlog_username', 'evntlog_evntlog_username_idx', 'btree', 'public');
