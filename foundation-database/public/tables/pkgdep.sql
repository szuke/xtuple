SELECT xt.create_table('pkgdep', 'public');

ALTER TABLE public.pkgdep DISABLE TRIGGER ALL;

SELECT
  xt.add_column('pkgdep', 'pkgdep_id',                'SERIAL',  'PRIMARY KEY NOT NULL',                    'public'),
  xt.add_column('pkgdep', 'pkgdep_pkghead_id',        'INTEGER', 'NOT NULL REFERENCES pkghead(pkghead_id)', 'public'),
  xt.add_column('pkgdep', 'pkgdep_parent_pkghead_id', 'INTEGER', 'NOT NULL REFERENCES pkghead(pkghead_id)', 'public');

ALTER TABLE public.pkgdep ENABLE TRIGGER ALL;

COMMENT ON TABLE pkgdep IS 'Package Dependencies list describing which packages are dependent on which other packages.';

COMMENT ON COLUMN pkgdep.pkgdep_pkghead_id IS 'This is the internal ID of a package which requires at least one other package to be installed first to operate successfully';
COMMENT ON COLUMN pkgdep.pkgdep_parent_pkghead_id IS 'This is the internal ID of a package which must be installed for the package pointed to by pkgdep_pkghead_id to operate successfully.';
