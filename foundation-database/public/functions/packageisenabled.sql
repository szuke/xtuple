CREATE OR REPLACE FUNCTION packageIsEnabled(pName TEXT) RETURNS BOOLEAN AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
  SELECT EXISTS(SELECT 1
                 FROM pg_inherits
                 JOIN pg_class child ON inhrelid = child.oid
                 JOIN pg_namespace   ON child.relnamespace = pg_namespace.oid
                WHERE nspname = pName
                  AND child.relkind = 'r'
                  AND relname IN ('pkgcmd',  'pkgcmdarg', 'pkgimage',  'pkgmetasql',
                                  'pkgpriv', 'pkgreport', 'pkgscript', 'pkguiform',
                                  'pkgdict'));
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION packageIsEnabled(pId INTEGER) RETURNS BOOLEAN AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
  SELECT packageIsEnabled(pkghead_name)
    FROM pkghead
   WHERE pkghead_id = pId;
$$ LANGUAGE sql STABLE;
