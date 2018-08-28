CREATE OR REPLACE FUNCTION _invcitemBeforeTrigger() RETURNS "trigger" AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _itemfractional BOOLEAN;

BEGIN
  IF (TG_OP = 'DELETE') THEN
    DELETE FROM invcitemtax
    WHERE (taxhist_parent_id=OLD.invcitem_id);

    RETURN OLD;
  END IF;

  IF (TG_OP IN ('UPDATE','DELETE')) THEN
    IF (SELECT COUNT(invchead_id) > 0
        FROM invchead
        WHERE ((invchead_id=OLD.invcitem_invchead_id)
          AND (invchead_posted))) THEN
      RAISE EXCEPTION 'Edit not allowed on Posted Invoices.';
    END IF;
  END IF;

  -- If regular Item then enforce item_fractional
  IF (COALESCE(NEW.invcitem_item_id, -1) <> -1) THEN
    SELECT itemuomfractionalbyuom(NEW.invcitem_item_id, NEW.invcitem_qty_uom_id) INTO _itemfractional;
    IF (NOT _itemfractional) THEN
      IF (TRUNC(NEW.invcitem_ordered) <> NEW.invcitem_ordered) THEN
        RAISE EXCEPTION 'Item does not support fractional quantities';
      END IF;
      IF (TRUNC(NEW.invcitem_billed) <> NEW.invcitem_billed) THEN
        RAISE EXCEPTION 'Item does not support fractional quantities';
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'invcitemBeforeTrigger');
CREATE TRIGGER invcitemBeforeTrigger
  BEFORE INSERT OR UPDATE OR DELETE
  ON invcitem
  FOR EACH ROW
  EXECUTE PROCEDURE _invcitemBeforeTrigger();

CREATE OR REPLACE FUNCTION _invcitemTrigger() RETURNS trigger AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r RECORD;

BEGIN
  IF (TG_OP = 'DELETE') THEN
    RETURN OLD;
  END IF;

-- Cache Invoice Head
  SELECT * INTO _r
  FROM invchead
  WHERE (invchead_id=NEW.invcitem_invchead_id);
  IF (NOT FOUND) THEN
    RAISE EXCEPTION 'Invoice head not found';
  END IF;

-- Insert new row
  IF (TG_OP = 'INSERT') THEN
      PERFORM postComment('ChangeLog', 'INVI', NEW.invcitem_id, 'Created');
  -- Calculate Tax
      PERFORM calculateTaxHist( 'invcitemtax',
                                NEW.invcitem_id,
                                COALESCE(_r.invchead_taxzone_id, -1),
                                NEW.invcitem_taxtype_id,
                                COALESCE(_r.invchead_invcdate, CURRENT_DATE),
                                COALESCE(_r.invchead_curr_id, -1),
                                (NEW.invcitem_billed * NEW.invcitem_qty_invuomratio) *
                                (NEW.invcitem_price / NEW.invcitem_price_invuomratio) );
  END IF;

-- Update row
  IF (TG_OP = 'UPDATE') THEN

  -- Calculate Tax
    IF ( (NEW.invcitem_billed <> OLD.invcitem_billed) OR
         (NEW.invcitem_qty_invuomratio <> OLD.invcitem_qty_invuomratio) OR
         (NEW.invcitem_price <> OLD.invcitem_price) OR
         (NEW.invcitem_price_invuomratio <> OLD.invcitem_price_invuomratio) OR
         (COALESCE(NEW.invcitem_taxtype_id, -1) <> COALESCE(OLD.invcitem_taxtype_id, -1)) ) THEN
      PERFORM calculateTaxHist( 'invcitemtax',
                                NEW.invcitem_id,
                                COALESCE(_r.invchead_taxzone_id, -1),
                                NEW.invcitem_taxtype_id,
                                COALESCE(_r.invchead_invcdate, CURRENT_DATE),
                                COALESCE(_r.invchead_curr_id, -1),
                                (NEW.invcitem_billed * NEW.invcitem_qty_invuomratio) *
                                (NEW.invcitem_price / NEW.invcitem_price_invuomratio) );
    END IF;

  -- Record Changes
    IF (NEW.invcitem_billed <> OLD.invcitem_billed) THEN
       PERFORM postComment('ChangeLog', 'INVI', NEW.invcitem_id, 'Billed Qty',
                            formatQty(OLD.invcitem_billed), formatQty(NEW.invcitem_billed));
    END IF;
    IF (NEW.invcitem_price <> OLD.invcitem_price) THEN
      PERFORM postComment('ChangeLog', 'INVI', NEW.invcitem_id, 'Price',
                           formatPrice(OLD.invcitem_price), formatPrice(NEW.invcitem_price));
    END IF;
    IF (NEW.invcitem_taxtype_id <> OLD.invcitem_taxtype_id) THEN
      PERFORM postComment('ChangeLog', 'INVI', NEW.invcitem_id, 'Tax Type',
                          (SELECT taxtype_name FROM taxtype WHERE taxtype_id=OLD.invcitem_taxtype_id),
                          (SELECT taxtype_name FROM taxtype WHERE taxtype_id=NEW.invcitem_taxtype_id));
    END IF;
    IF (NEW.invcitem_rev_accnt_id <> OLD.invcitem_rev_accnt_id) THEN
      PERFORM postComment('ChangeLog', 'INVI', NEW.invcitem_id, 'Revenue Account',
                          (SELECT accnt_name FROM accnt WHERE accnt_id=OLD.invcitem_rev_accnt_id),
                          (SELECT accnt_name FROM accnt WHERE accnt_id=NEW.invcitem_rev_accnt_id));
    END IF;
    IF (OLD.invcitem_item_id <> -1 AND NEW.invcitem_salescat_id > 0) THEN
      PERFORM postComment('ChangeLog', 'INVI', NEW.invcitem_id, 'Switched Item to Misc:',
                          (SELECT item_number FROM item WHERE item_id=OLD.invcitem_item_id),
                          (SELECT salescat_name FROM salescat WHERE salescat_id=NEW.invcitem_salescat_id));
    END IF;
    IF (OLD.invcitem_salescat_id > 0 AND NEW.invcitem_item_id <> -1) THEN
      PERFORM postComment('ChangeLog', 'INVI', NEW.invcitem_id, 'Switched Misc to Item:',
                          (SELECT salescat_name FROM salescat WHERE salescat_id=OLD.invcitem_salescat_id),
                          (SELECT item_number FROM item WHERE item_id=NEW.invcitem_item_id));
    END IF;
    IF (OLD.invcitem_salescat_id > 0 AND NEW.invcitem_salescat_id <> OLD.invcitem_salescat_id) THEN
      PERFORM postComment('ChangeLog', 'INVI', NEW.invcitem_id, 'Sales Category',
                          (SELECT salescat_name FROM salescat WHERE salescat_id=OLD.invcitem_salescat_id),
                          (SELECT salescat_name FROM salescat WHERE salescat_id=NEW.invcitem_salescat_id));
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

SELECT dropIfExists('TRIGGER', 'invcitemtrigger');
CREATE TRIGGER invcitemtrigger
  AFTER INSERT OR UPDATE OR DELETE
  ON invcitem
  FOR EACH ROW
  EXECUTE PROCEDURE _invcitemTrigger();
