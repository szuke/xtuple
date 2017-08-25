DROP FUNCTION IF EXISTS xt.deletePOType(INTEGER);

CREATE OR REPLACE FUNCTION deletePOType(pPotypeid INTEGER) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/EULA for the full text of the software license.
BEGIN

  IF (EXISTS(SELECT vend_potype_id
             FROM vendinfo
             WHERE vend_potype_id=pPotypeid)) THEN
    RAISE EXCEPTION 'Cannot delete because this Purchase Type is used as a Vendor default Purchase Type';
  END IF;

  IF (EXISTS(SELECT pohead_potype_id
             FROM pohead
             WHERE pohead_potype_id=pPotypeid)) THEN
    RAISE EXCEPTION 'Cannot delete because this Purchase Type is used on a Purchase Order';
  END IF;

  DELETE FROM potype
  WHERE (potype_id=pPotypeid);

  RETURN 0;

END;
$$ LANGUAGE plpgsql;
