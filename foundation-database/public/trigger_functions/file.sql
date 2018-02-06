CREATE OR REPLACE FUNCTION _filedeletetrigger() RETURNS TRIGGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
  IF (TG_OP = 'DELETE') THEN
    DELETE FROM docass WHERE docass_target_type = 'FILE' AND docass_target_id = OLD.file_id;
  END IF;

  RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropifexists('TRIGGER' ,'fileDeleteTrigger');
CREATE TRIGGER fileDeleteTrigger AFTER DELETE ON file FOR EACH ROW EXECUTE PROCEDURE _filedeletetrigger();
