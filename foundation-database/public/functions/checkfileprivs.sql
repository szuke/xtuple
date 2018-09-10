DROP FUNCTION IF EXISTS checkfileprivs(INTEGER, TEXT) CASCADE;

CREATE OR REPLACE FUNCTION checkfileprivs(pFileid INTEGER, 
                           pUsername TEXT DEFAULT getEffectiveXtUser()) 
                           RETURNS BOOLEAN STABLE AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _roles    INTEGER[];
  _hasPriv  INTEGER;

BEGIN

  _roles := (SELECT array_agg(filegrp_grp_id)
               FROM filegrp
              WHERE filegrp_file_id = pFileid);

  IF (_roles IS NULL) THEN
    RETURN true;
  END IF;

  _hasPriv := (SELECT count(*)
                 FROM usrgrp
                WHERE usrgrp_username = pUsername
                  AND usrgrp_grp_id = ANY(_roles));

  IF (_hasPriv > 0) THEN
    RETURN true;
  END IF;

  RETURN false;
END;
$$ LANGUAGE plpgsql;
