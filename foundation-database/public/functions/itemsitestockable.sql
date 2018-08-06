CREATE OR REPLACE FUNCTION itemsitestockable(pItemSite integer)
  RETURNS boolean AS $$
-- Copyright (c) 1999-2016 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.

  SELECT (item_type IN ('P','M','T','B','C','Y')
           AND itemsite_controlmethod <> 'N')
           FROM item
           JOIN itemsite ON (item_id=itemsite_item_id) 
           WHERE itemsite_id = pItemSite;

$$ LANGUAGE SQL STABLE;
