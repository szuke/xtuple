CREATE OR REPLACE FUNCTION accntIsValid(
  pAccntId integer
) RETURNS boolean AS
$BODY$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _isValid boolean := false;

BEGIN

  SELECT accnt_active INTO _isValid
    FROM accnt
   WHERE accnt_id = pAccntId;

  RETURN _isValid;

END;
$BODY$
  LANGUAGE plpgsql STABLE;
ALTER FUNCTION accntIsValid(integer)
  OWNER TO admin;
