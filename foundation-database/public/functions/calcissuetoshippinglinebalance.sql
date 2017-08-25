CREATE OR REPLACE FUNCTION calcIssueToShippingLineBalance(pOrderType TEXT,
                                                          pOrderitemId INTEGER) 
RETURNS NUMERIC AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _qty			NUMERIC;

BEGIN
  IF (pOrderType = 'SO') THEN
    SELECT CASE WHEN (fetchMetricBool('RequireSOReservations'))
                THEN itemuomtouom(itemsite_item_id, NULL, coitem_qty_uom_id, coitem_qtyreserved)
                ELSE noNeg( coitem_qtyord - coitem_qtyshipped + coitem_qtyreturned - qtyAtShipping('SO', coitem_id) )
           END INTO _qty
    FROM coitem JOIN itemsite ON (itemsite_id=coitem_itemsite_id)
    WHERE (coitem_id=pOrderitemId);
  ELSEIF (pordertype = 'TO') THEN
    SELECT noNeg( toitem_qty_ordered - toitem_qty_shipped - qtyAtShipping('TO', toitem_id) ) INTO _qty
    FROM toitem
    WHERE (toitem_id=pOrderitemId);
  ELSE
    RAISE EXCEPTION 'Order type % is not eligible for issue to shipping 
      [xtuple: calcIssueToShippingLineBalance, -1, %]', pOrderType, pOrderType;
  END IF;

  RETURN _qty;

END;
$$ LANGUAGE plpgsql;
