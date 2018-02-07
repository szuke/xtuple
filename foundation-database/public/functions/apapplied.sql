CREATE OR REPLACE FUNCTION apapplied(pApopenid INTEGER, pDate DATE) RETURNS NUMERIC AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _amount NUMERIC;

BEGIN
  -- Return amount applied to an apopen in base currency as of apapply_postdate
  SELECT SUM(currtobase(apapply_curr_id,apapply_amount,apapply_postdate))
    INTO _amount
    FROM apapply
   WHERE pApopenid IN (apapply_target_apopen_id, apapply_source_apopen_id)
     AND ((apapply_journalnumber = 0 AND apapply_postdate <= pDate)
           OR EXISTS(SELECT 1
                       FROM gltrans 
                      WHERE gltrans_journalnumber = apapply_journalnumber
                        AND gltrans_date <= pDate));
  RETURN COALESCE(_amount, 0);
END;
$$ LANGUAGE plpgsql;
