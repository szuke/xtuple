CREATE OR REPLACE FUNCTION itemstockable(pItem integer)
  RETURNS boolean AS $$
-- Copyright (c) 1999-2016 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.

  SELECT item_type IN ('P','M','T','B','C','Y')
           FROM item
           WHERE item_id = pItem;

$$ LANGUAGE SQL STABLE;
