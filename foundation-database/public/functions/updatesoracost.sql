DROP FUNCTION IF EXISTS updateSorACost(INTEGER, TEXT, BOOLEAN, NUMERIC, BOOLEAN);

CREATE OR REPLACE FUNCTION updateSorACost(pItemid INTEGER, pCosttype TEXT, pLevel BOOLEAN, pCost NUMERIC, pUpdateActual BOOLEAN) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
    IF (pUpdateActual) THEN
	RETURN updateCost(pItemid, pCosttype, pLevel, pCost);
    ELSE
	RETURN updateStdCost(pItemid, pCosttype, pLevel, pCost);
    END IF;
END;
$$ LANGUAGE plpgsql;

