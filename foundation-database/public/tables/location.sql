SELECT xt.create_table('location', 'public');

ALTER TABLE public.location DISABLE TRIGGER ALL;

SELECT
  xt.add_column('location', 'location_id',           'SERIAL', 'NOT NULL', 'public'),
  xt.add_column('location', 'location_warehous_id', 'INTEGER', 'NOT NULL', 'public'),
  xt.add_column('location', 'location_name',           'TEXT', 'NOT NULL', 'public'),
  xt.add_column('location', 'location_descrip',        'TEXT', NULL, 'public'),
  xt.add_column('location', 'location_restrict',    'BOOLEAN', NULL, 'public'),
  xt.add_column('location', 'location_netable',     'BOOLEAN', NULL, 'public'),
  xt.add_column('location', 'location_whsezone_id', 'INTEGER', NULL, 'public'),
  xt.add_column('location', 'location_aisle',          'TEXT', NULL, 'public'),
  xt.add_column('location', 'location_rack',           'TEXT', NULL, 'public'),
  xt.add_column('location', 'location_bin',            'TEXT', NULL, 'public'),

  xt.add_column('location','location_formatname',      'TEXT', NULL, 'public'),
  xt.add_column('location','location_usable',       'BOOLEAN', NULL, 'public'),
  xt.add_column('location','location_active',       'BOOLEAN', 'NOT NULL DEFAULT TRUE', 'public');

SELECT
  xt.add_constraint('location', 'location_pkey', 'PRIMARY KEY (location_id)', 'public');

do $$
begin
if (compareVersion(fetchMetricText('ServerVersion'), '4.7.0') = -1) then
  update location set location_usable=true;
end if;
end$$;

UPDATE location
   SET location_formatname = formatLocationName(location_id)
 WHERE location_formatname IS NULL;

ALTER TABLE public.location ENABLE TRIGGER ALL;

select xt.add_index('location', 'location_formatname', 'location_location_formatname_idx', 'btree', 'public');

COMMENT ON TABLE location IS 'Warehouse Location information';
