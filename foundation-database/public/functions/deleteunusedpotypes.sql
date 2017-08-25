DROP FUNCTION IF EXISTS xt.deleteUnusedPOTypes();

CREATE OR REPLACE FUNCTION deleteUnusedPOTypes() RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/EULA for the full text of the software license.
BEGIN

  DELETE FROM potype
  WHERE (potype_id NOT IN (SELECT DISTINCT COALESCE(vend_potype_id, -1) FROM vendinfo))
    AND (potype_id NOT IN (SELECT DISTINCT COALESCE(pohead_potype_id, -1) FROM pohead));

  RETURN 0;

END;
$$ LANGUAGE plpgsql;
