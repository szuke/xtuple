CREATE OR REPLACE FUNCTION _shipheadBeforeTrigger ()
RETURNS TRIGGER AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
  IF ((TG_OP = 'INSERT') OR (TG_OP = 'UPDATE')) THEN

    IF (NEW.shiphead_order_type = 'SO'
        AND EXISTS (SELECT true FROM cohead WHERE cohead_id = NEW.shiphead_order_id)) THEN
      RETURN NEW;
    ELSEIF (NEW.shiphead_order_type = 'TO'
            AND EXISTS (SELECT true FROM tohead WHERE tohead_id = NEW.shiphead_order_id)) THEN
      RETURN NEW;
    END IF;

    RAISE EXCEPTION '% with id % does not exist  [xtuple: _shipheadBeforeTrigger, -1, %, %]',
            NEW.shiphead_order_type, NEW.shiphead_order_id,
            NEW.shiphead_order_type, NEW.shiphead_order_id;
    RETURN OLD;

  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

SELECT dropifexists('trigger', 'shipheadbeforetrigger');
CREATE TRIGGER shipheadBeforeTrigger BEFORE INSERT OR UPDATE ON shiphead FOR EACH ROW EXECUTE PROCEDURE _shipheadBeforeTrigger();
