DROP FUNCTION IF EXISTS enablePackage(TEXT);
DROP FUNCTION IF EXISTS enablePackage(INTEGER);

CREATE OR REPLACE FUNCTION enablePackage(pName TEXT) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
  SELECT _setPackageIsEnabled(pName, true);
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION enablePackage(pId INTEGER) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
  SELECT _setPackageIsEnabled(pId, true);
$$ LANGUAGE sql;
