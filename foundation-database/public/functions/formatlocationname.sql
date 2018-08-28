
CREATE OR REPLACE FUNCTION formatLocationName(pLocationid INTEGER) RETURNS TEXT IMMUTABLE AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _name TEXT;

BEGIN
  SELECT COALESCE(location_aisle, '') || COALESCE(location_rack, '')
      || COALESCE(location_bin,   '') || COALESCE(location_name, '')
    INTO _name
    FROM location
   WHERE location_id = pLocationid;

  RETURN COALESCE(_name, 'N/A');

END;
$$ LANGUAGE plpgsql;

