SELECT xt.create_table('itemsite', 'public');

ALTER TABLE public.itemsite DISABLE TRIGGER ALL;

SELECT
  xt.add_column('itemsite', 'itemsite_id',                  'SERIAL', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_item_id',            'INTEGER', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_warehous_id',        'INTEGER', NULL,                     'public'),
  xt.add_column('itemsite', 'itemsite_qtyonhand',    'NUMERIC(18,6)', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_reorderlevel', 'NUMERIC(18,6)', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_ordertoqty',   'NUMERIC(18,6)', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_cyclecountfreq',     'INTEGER', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_datelastcount',         'DATE', NULL,                     'public'),
  xt.add_column('itemsite', 'itemsite_datelastused',          'DATE', NULL,                     'public'),
  xt.add_column('itemsite', 'itemsite_loccntrl',           'BOOLEAN', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_safetystock',  'NUMERIC(18,6)', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_minordqty',    'NUMERIC(18,6)', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_multordqty',   'NUMERIC(18,6)', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_leadtime',           'INTEGER', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_abcclass',      'CHARACTER(1)', NULL,                     'public'),
  xt.add_column('itemsite', 'itemsite_issuemethod',   'CHARACTER(1)', NULL,                     'public'),
  xt.add_column('itemsite', 'itemsite_controlmethod', 'CHARACTER(1)', NULL,                     'public'),
  xt.add_column('itemsite', 'itemsite_active',             'BOOLEAN', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_plancode_id',        'INTEGER', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_costcat_id',         'INTEGER', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_eventfence',         'INTEGER', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_sold',               'BOOLEAN', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_stocked',            'BOOLEAN', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_freeze',             'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('itemsite', 'itemsite_location_id',        'INTEGER', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_useparams',          'BOOLEAN', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_useparamsmanual',    'BOOLEAN', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_soldranking',        'INTEGER', 'DEFAULT 1',              'public'),
  xt.add_column('itemsite', 'itemsite_createpr',           'BOOLEAN', NULL,                     'public'),
  xt.add_column('itemsite', 'itemsite_location',              'TEXT', NULL,                     'public'),
  xt.add_column('itemsite', 'itemsite_location_comments',     'TEXT', NULL,                     'public'),
  xt.add_column('itemsite', 'itemsite_notes',                 'TEXT', NULL,                     'public'),
  xt.add_column('itemsite', 'itemsite_perishable',         'BOOLEAN', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_autoabcclass',       'BOOLEAN', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_ordergroup',         'INTEGER', 'DEFAULT 1 NOT NULL',     'public'),
  xt.add_column('itemsite', 'itemsite_disallowblankwip',   'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('itemsite', 'itemsite_maxordqty',    'NUMERIC(18,6)', 'DEFAULT 0.0 NOT NULL',   'public'),
  xt.add_column('itemsite', 'itemsite_mps_timefence',      'INTEGER', 'DEFAULT 0 NOT NULL',     'public'),
  xt.add_column('itemsite', 'itemsite_createwo',           'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('itemsite', 'itemsite_warrpurc',           'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('itemsite', 'itemsite_autoreg',            'BOOLEAN', 'DEFAULT false',          'public'),
  xt.add_column('itemsite', 'itemsite_costmethod',    'CHARACTER(1)', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_value',        'NUMERIC(12,2)', 'NOT NULL',               'public'),
  xt.add_column('itemsite', 'itemsite_ordergroup_first',   'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('itemsite', 'itemsite_supply_itemsite_id', 'INTEGER', NULL,                     'public'),
  xt.add_column('itemsite', 'itemsite_planning_type', 'CHARACTER(1)', $$DEFAULT 'M' NOT NULL$$, 'public'),
  xt.add_column('itemsite', 'itemsite_wosupply',           'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('itemsite', 'itemsite_posupply',           'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('itemsite', 'itemsite_lsseq_id',           'INTEGER', NULL,                     'public'),
  xt.add_column('itemsite', 'itemsite_cosdefault',    'CHARACTER(1)', NULL,                     'public'),
  xt.add_column('itemsite', 'itemsite_createsopr',         'BOOLEAN', 'DEFAULT false',          'public'),
  xt.add_column('itemsite', 'itemsite_createsopo',         'BOOLEAN', 'DEFAULT false',          'public'),
  xt.add_column('itemsite', 'itemsite_dropship',           'BOOLEAN', 'DEFAULT false',          'public'),
  xt.add_column('itemsite', 'itemsite_recvlocation_id',    'INTEGER', 'DEFAULT -1 NOT NULL',    'public'),
  xt.add_column('itemsite', 'itemsite_issuelocation_id',   'INTEGER', 'DEFAULT -1 NOT NULL',    'public'),
  xt.add_column('itemsite', 'itemsite_location_dist',      'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('itemsite', 'itemsite_recvlocation_dist',  'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('itemsite', 'itemsite_issuelocation_dist', 'BOOLEAN', 'DEFAULT false NOT NULL', 'public'),
  xt.add_column('itemsite', 'itemsite_created',      'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('itemsite', 'itemsite_lastupdated',  'TIMESTAMP WITH TIME ZONE', NULL, 'public'),
  xt.add_column('itemsite', 'itemsite_autoord',          'BOOLEAN', 'NOT NULL DEFAULT TRUE', 'public');

-- incident 23507:change how qoh, qoh available, and qoh netable are determined
do $$
begin
if (compareVersion(fetchMetricText('ServerVersion'), '4.7.0') = -1) then
  update itemsite set itemsite_qtyonhand=(itemsite_qtyonhand + itemsite_nnqoh);
  alter table itemsite drop column itemsite_nnqoh cascade;
end if;
end$$;

SELECT
  xt.add_constraint('itemsite', 'itemsite_pkey', 'PRIMARY KEY (itemsite_id)',   'public'),
  xt.add_constraint('itemsite', 'itemsite_itemsite_abcclass_check',
                    $$CHECK (itemsite_abcclass IN ('A', 'B', 'C', 'T'))$$,      'public'),
  xt.add_constraint('itemsite', 'itemsite_itemsite_controlmethod_check',
                    $$CHECK (itemsite_controlmethod IN ('N', 'R', 'S', 'L'))$$, 'public'),
  xt.add_constraint('itemsite', 'itemsite_itemsite_costmethod_check',
                    $$CHECK (itemsite_costmethod IN ('N', 'A', 'S', 'J'))$$,    'public'),
  xt.add_constraint('itemsite', 'itemsite_itemsite_ordergroup_check',
                    'CHECK (itemsite_ordergroup > 0)',                          'public'),
  xt.add_constraint('itemsite', 'itemsite_itemsite_costcat_id_fkey',
                    'FOREIGN KEY (itemsite_costcat_id) REFERENCES costcat(costcat_id)',    'public'),
  xt.add_constraint('itemsite', 'itemsite_itemsite_item_id_fkey',
                    'FOREIGN KEY (itemsite_item_id) REFERENCES item(item_id)',             'public'),
  xt.add_constraint('itemsite', 'itemsite_itemsite_plancode_id_fkey',
                    'FOREIGN KEY (itemsite_plancode_id) REFERENCES plancode(plancode_id)', 'public'),
  xt.add_constraint('itemsite', 'itemsite_itemsite_warehous_id_fkey',
                    'FOREIGN KEY (itemsite_warehous_id) REFERENCES whsinfo(warehous_id)',  'public');

ALTER TABLE public.itemsite ENABLE TRIGGER ALL;

COMMENT ON TABLE itemsite IS 'Item Site information';

COMMENT ON COLUMN itemsite.itemsite_lsseq_id IS 'Foreign key reference for automatic lot/serial numbering';
COMMENT ON COLUMN itemsite.itemsite_createsopr IS 'Used to flag Sales items that create P/Rs';
COMMENT ON COLUMN itemsite.itemsite_createsopo IS 'Used to flag Sales items that create P/Os';
COMMENT ON COLUMN itemsite.itemsite_dropship IS 'Used to flag Sales items to drop ship';
