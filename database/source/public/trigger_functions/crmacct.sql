CREATE OR REPLACE FUNCTION xt._crmacctUsrliteAfterUpdateTrigger()
  RETURNS trigger AS
$BODY$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _matchingUsrNew TEXT;
  _matchingUsrOld TEXT;
BEGIN

  IF NEW.crmacct_usr_username IS NOT NULL
    AND OLD.crmacct_usr_username IS NOT NULL
    AND NEW.crmacct_usr_username != OLD.crmacct_usr_username
  THEN
    SELECT
      usr_username INTO _matchingUsrNew
      FROM xt.usrlite
     WHERE usr_username = NEW.crmacct_usr_username;

    IF _matchingUsrNew IS NOT NULL THEN
      DELETE FROM xt.usrlite
       WHERE usr_username = OLD.crmacct_usr_username;
    ELSE
      UPDATE xt.usrlite SET
        usr_username = NEW.crmacct_usr_username
       WHERE usr_username = (
         SELECT
          usr_username
          FROM xt.usrlite
         WHERE usr_username = OLD.crmacct_usr_username
       ) RETURNING usr_username INTO _matchingUsrOld;
    END IF;
  END IF;

  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

DROP TRIGGER IF EXISTS crmacctUsrliteAfterUpdateTrigger ON public.crmacct;
CREATE TRIGGER crmacctUsrliteAfterUpdateTrigger
  AFTER UPDATE ON public.crmacct
  FOR EACH ROW
  EXECUTE PROCEDURE xt._crmacctUsrliteAfterUpdateTrigger();
