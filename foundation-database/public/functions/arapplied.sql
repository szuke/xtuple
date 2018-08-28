CREATE OR REPLACE FUNCTION arapplied(pAropenid INTEGER, pDate DATE) RETURNS NUMERIC AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _amount NUMERIC;

BEGIN
  -- Return amount applied to an aropen in base currency item as of the parameter date
  SELECT SUM(currtobase(arapply_curr_id,arapply_applied,pDate)) INTO _amount
    FROM arapply
   WHERE pAropenid IN (arapply_target_aropen_id, arapply_source_aropen_id)
     AND ((arapply_journalnumber::INTEGER = 0 AND arapply_postdate <= pDate)
           OR EXISTS(SELECT 1
                       FROM gltrans 
                      WHERE gltrans_journalnumber = arapply_journalnumber::INTEGER
                        AND gltrans_date <= pDate));

  RETURN COALESCE(_amount, 0);
END;
$$ LANGUAGE plpgsql;
