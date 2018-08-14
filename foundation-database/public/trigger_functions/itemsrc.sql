CREATE OR REPLACE FUNCTION _itemsrcTrigger () RETURNS TRIGGER AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN

-- Privilege Checks
   IF (NOT checkPrivilege('MaintainItemSources')) THEN
     RAISE EXCEPTION 'You do not have privileges to maintain Item Sources. [xtuple: _itemsrcTrigger, -1';
   END IF;

-- Duplicate check
   IF EXISTS(SELECT 1
             FROM itemsrc
             WHERE itemsrc_item_id=NEW.itemsrc_item_id
             AND itemsrc_vend_id=NEW.itemsrc_vend_id
             AND itemsrc_vend_item_number=NEW.itemsrc_vend_item_number
             AND ((itemsrc_contrct_id=NEW.itemsrc_contrct_id)
                   OR (itemsrc_contrct_id IS NULL AND NEW.itemsrc_contrct_id IS NULL))
             AND ((NEW.itemsrc_effective between itemsrc_effective and itemsrc_expires)
                   OR (NEW.itemsrc_expires between itemsrc_effective and itemsrc_expires) )
             AND itemsrc_active
             AND itemsrc_id != NEW.itemsrc_id ) THEN
     RAISE EXCEPTION 'An Item Source already exists for this Vendor/Item combination [xtuple: _itemsrcTrigger, -2]';
   END IF;

-- Set defaults
   NEW.itemsrc_invvendoruomratio := COALESCE(NEW.itemsrc_invvendoruomratio,1);
   NEW.itemsrc_minordqty         := COALESCE(NEW.itemsrc_minordqty,0);
   NEW.itemsrc_multordqty        := COALESCE(NEW.itemsrc_multordqty,0);
   NEW.itemsrc_active            := COALESCE(NEW.itemsrc_active,true);
   NEW.itemsrc_leadtime          := COALESCE(NEW.itemsrc_leadtime,0);
   NEW.itemsrc_ranking           := COALESCE(NEW.itemsrc_ranking,1);

   IF (NEW.itemsrc_invvendoruomratio <= 0) THEN
      NEW.itemsrc_invvendoruomratio = 1;
   END IF;

   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS itemsrctrigger ON public.itemsrc;
CREATE TRIGGER itemsrcTrigger BEFORE INSERT OR UPDATE ON itemsrc FOR EACH ROW EXECUTE PROCEDURE _itemsrcTrigger();

CREATE OR REPLACE FUNCTION _itemsrcAfterTrigger () RETURNS TRIGGER AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN

-- Set default to false for other item sources of this item
  IF (COALESCE(NEW.itemsrc_default, FALSE) = TRUE) THEN
    UPDATE itemsrc SET itemsrc_default = FALSE
    WHERE ( (itemsrc_item_id = NEW.itemsrc_item_id)
      AND (itemsrc_id <> NEW.itemsrc_id) );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS itemsrcAfterTrigger  ON public.itemsrc;
CREATE TRIGGER itemsrcAfterTrigger AFTER INSERT OR UPDATE ON itemsrc FOR EACH ROW EXECUTE PROCEDURE _itemsrcAfterTrigger();
