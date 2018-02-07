CREATE OR REPLACE FUNCTION packageIsEnabled(pId INTEGER) RETURNS BOOLEAN AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _pkgname TEXT;

BEGIN

  SELECT pkghead_name INTO _pkgname
    FROM pkghead
   WHERE pkghead_id=pId;

  RETURN packageIsEnabled(_pkgname);

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION packageIsEnabled(pName TEXT) RETURNS BOOLEAN AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _result BOOLEAN;

BEGIN

  SELECT BOOL_OR(parent.relname IN ('cmd',  'cmdarg', 'image',  'metasql', 'priv', 'report', 'script', 'uiform', 'dict')) INTO _result
    FROM pg_inherits
    JOIN pg_class parent ON inhparent=parent.oid
    JOIN pg_class child ON inhrelid=child.oid
    JOIN pg_namespace ON child.relnamespace=pg_namespace.oid
   WHERE nspname=pName;

   RETURN COALESCE(_result, FALSE);

END;
$$ LANGUAGE plpgsql;
