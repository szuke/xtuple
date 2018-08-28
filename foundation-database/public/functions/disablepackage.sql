DROP FUNCTION IF EXISTS disablePackage(TEXT);
DROP FUNCTION IF EXISTS disablePackage(INTEGER);

CREATE OR REPLACE FUNCTION disablePackage(pName TEXT) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
  SELECT _setPackageIsEnabled(pName, false);
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION disablePackage(pId INTEGER) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
  SELECT _setPackageIsEnabled(pId, false);
$$ LANGUAGE sql;
