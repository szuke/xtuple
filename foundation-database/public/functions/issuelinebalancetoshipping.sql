CREATE OR REPLACE FUNCTION issueLineBalanceToShipping(INTEGER) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
  RETURN issueLineBalanceToShipping('SO', $1, NULL);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION issueLineBalanceToShipping(TEXT, INTEGER, TIMESTAMP WITH TIME ZONE) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
  RETURN issueLineBalanceToShipping($1, $2, $3, 0, NULL);
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS issueLineBalanceToShipping(TEXT, INTEGER, TIMESTAMP WITH TIME ZONE, INTEGER, INTEGER);
CREATE OR REPLACE FUNCTION issueLineBalanceToShipping(pordertype TEXT,
                                                      pitemid INTEGER,
                                                      ptimestamp TIMESTAMP WITH TIME ZONE,
                                                      pitemlocseries INTEGER,
                                                      pinvhistid INTEGER,
                                                      pPreDistributed BOOLEAN DEFAULT FALSE) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _itemlocSeries	INTEGER := 0;
  _qty			NUMERIC;

BEGIN
  _itemlocSeries := COALESCE(pitemlocseries,0);
  
  IF (pordertype != 'SO' AND pordertype != 'TO') THEN
    RETURN -1;
  ELSE 
    _qty := calcIssueToShippingLineBalance(pordertype, pitemid);
  END IF;

  IF (_qty > 0) THEN
    _itemlocSeries := issueToShipping(pordertype, pitemid, _qty, _itemlocSeries, ptimestamp, pinvhistid, false, pPreDistributed);
  END IF;

  RETURN _itemlocSeries;

END;
$$ LANGUAGE plpgsql;
