select xt.create_table('obj');
select xt.add_column('obj','obj_uuid', 'uuid');

comment on table xt.obj is 'Base table for xTuple table inheritance';
