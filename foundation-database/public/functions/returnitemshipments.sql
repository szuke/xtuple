CREATE OR REPLACE FUNCTION returnItemShipments(INTEGER) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
  RETURN returnItemShipments('SO', $1, 0, CURRENT_TIMESTAMP);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION returnItemShipments(INTEGER, INTEGER) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
  RETURN returnItemShipments('SO', $1, $2, CURRENT_TIMESTAMP);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION returnItemShipments(pordertype TEXT, 
                                               pitemid INTEGER, 
                                               pItemlocSeries INTEGER, 
                                               pTimestamp TIMESTAMP WITH TIME ZONE)
RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _itemlocSeries	INTEGER := pItemlocSeries;
  _invhistid INTEGER;
  _r RECORD;

BEGIN

  IF (COALESCE(_itemlocSeries,0) = 0 ) THEN
    _itemlocSeries := NEXTVAL('itemloc_series_seq');
  END IF;

  FOR _r IN 
    SELECT shipitem_id
    FROM shipitem
      JOIN shiphead ON (shiphead_id=shipitem_shiphead_id)
    WHERE ((NOT shiphead_shipped)
      AND  (shiphead_order_type=pordertype)
      AND  (shipitem_orderitem_id=pitemid))
  LOOP

    PERFORM returnShipmentTransaction(_r.shipitem_id, _itemlocSeries, pTimestamp);

  END LOOP;

  RETURN _itemlocSeries;

END;
$$ LANGUAGE plpgsql;
