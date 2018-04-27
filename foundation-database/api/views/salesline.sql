-- Sales Order Line
CREATE OR REPLACE VIEW api.salesline
AS 
  SELECT 
     cohead_number::VARCHAR AS order_number,
     formatsolinenumber(coitem_id)::VARCHAR AS line_number,
     l.item_number AS item_number,
     coitem_custpn AS customer_pn,
     s.item_number AS substitute_for,
     warehous_code AS sold_from_site,
     coitem_status AS status,
     coitem_qtyord AS qty_ordered,
     q.uom_name AS qty_uom,
     coitem_price AS net_unit_price,
     p.uom_name AS price_uom,
     coitem_scheddate AS scheduled_date,
     coitem_promdate AS promise_date,
     coitem_warranty AS warranty,
     COALESCE((
       SELECT taxtype_name
       FROM taxtype
       WHERE (taxtype_id=getItemTaxType(l.item_id, cohead_taxzone_id))),'None') AS tax_type,
     CASE
       WHEN coitem_price = 0 THEN
         '100'
       WHEN coitem_custprice = 0 THEN
         'N/A'
       ELSE
         CAST(ROUND(((1 - coitem_price / coitem_custprice) * 100),4) AS text)
     END AS discount_pct_from_list,
     CASE
       WHEN (coitem_order_id = -1) THEN
         false
       ELSE
         true
     END AS create_order,
     CASE
       WHEN (coitem_order_id = -1) THEN
         ''
       ELSE
         (pohead_number || '-' || poitem_linenumber)
     END AS create_po,
     coitem_prcost AS overwrite_po_price,
     coitem_memo AS notes,
     CASE WHEN (coitem_cos_accnt_id IS NOT NULL) THEN formatglaccount(coitem_cos_accnt_id) 
          ELSE NULL::text
     END AS alternate_cos_account,
     CASE WHEN (coitem_rev_accnt_id IS NOT NULL) THEN formatglaccount(coitem_rev_accnt_id)
          ELSE NULL::text
     END AS alternate_rev_account
  FROM cohead, coitem
    LEFT OUTER JOIN itemsite isb ON (coitem_substitute_item_id=isb.itemsite_id)
    LEFT OUTER JOIN item s ON (isb.itemsite_item_id=s.item_id)
    LEFT OUTER JOIN (poitem JOIN pohead ON (poitem_pohead_id=pohead_id))
      ON (poitem_id=coitem_order_id),
  itemsite il, item l, whsinfo, uom q, uom p
  WHERE ((cohead_id=coitem_cohead_id)
  AND (coitem_itemsite_id=il.itemsite_id)
  AND (il.itemsite_item_id=l.item_id)
  AND (il.itemsite_warehous_id=warehous_id)
  AND (coitem_qty_uom_id=q.uom_id)
  AND (coitem_price_uom_id=p.uom_id))
ORDER BY cohead_number,coitem_linenumber,coitem_subnumber;
    
GRANT ALL ON TABLE api.salesline TO xtrole;
COMMENT ON VIEW api.salesline IS 'Sales Order Line Item';

DROP FUNCTION IF EXISTS public.insertsalesline(api.salesline);

CREATE OR REPLACE FUNCTION api.insertSalesLine(api.salesline) RETURNS boolean AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  pNEW ALIAS FOR $1;
  _r RECORD;

BEGIN

  IF (NOT EXISTS (SELECT cohead_id FROM cohead WHERE cohead_number=pNEW.order_number)) THEN
    RAISE EXCEPTION 'Function insertSalesLine failed because Sales Order % not found', pNEW.order_number;
  END IF;

  IF (NOT EXISTS (SELECT item_id FROM item WHERE item_number=pNEW.item_number)) THEN
    RAISE EXCEPTION 'Function insertSalesLine failed because Item Number % not found', pNEW.item_number;
  END IF;

  SELECT cohead_id, cohead_cust_id, cohead_shipto_id, cohead_curr_id,
         cohead_orderdate, cohead_taxzone_id,
         itemsite_id, itemsite_createwo, itemsite_stocked, itemsite_createsopr,
         itemsite_createsopo,
         item_id, item_inv_uom_id, item_price_uom_id, item_type,
         warehous_id
    INTO _r
  FROM cohead, itemsite, item, whsinfo
  WHERE ((cohead_number=pNEW.order_number)
  AND (itemsite_warehous_id=warehous_id)
  AND (itemsite_item_id=item_id)
  AND (itemsite_active)
  AND (item_number=pNEW.item_number)
  AND (warehous_active)
  AND (warehous_id=COALESCE(getWarehousId(pNEW.sold_from_site,'ALL'),cohead_warehous_id,fetchprefwarehousid())));

  IF (NOT FOUND) THEN
    RAISE EXCEPTION 'Function insertSalesLine failed with unknown failure to retrieve Sales Order';
  END IF;

  INSERT INTO coitem (
    coitem_cohead_id,
    coitem_linenumber,
    coitem_itemsite_id,
    coitem_status,
    coitem_scheddate,
    coitem_promdate,
    coitem_qtyord,
    coitem_qty_uom_id,
    coitem_qty_invuomratio,
    coitem_qtyshipped,
    coitem_unitcost,
    coitem_price,
    coitem_price_uom_id,
    coitem_price_invuomratio,
    coitem_custprice,
    coitem_listprice,
    coitem_order_id,
    coitem_memo,
    coitem_imported,
    coitem_qtyreturned,
    coitem_custpn,
    coitem_order_type,
    coitem_substitute_item_id,
    coitem_prcost,
    coitem_taxtype_id,
    coitem_warranty,
    coitem_cos_accnt_id,
    coitem_rev_accnt_id)
  VALUES (
    _r.cohead_id,
    pNEW.line_number::INTEGER,
    _r.itemsite_id,
    pNEW.status,
    pNEW.scheduled_date,
    pNEW.promise_date,
    pNEW.qty_ordered,
    COALESCE(getUomId(pNEW.qty_uom),_r.item_inv_uom_id),
    itemuomtouomratio(_r.item_id,COALESCE(getUomId(pNEW.qty_uom),_r.item_inv_uom_id),_r.item_inv_uom_id),
    0,
    stdCost(_r.item_id),
    COALESCE(pNEW.net_unit_price,itemPrice(_r.item_id,_r.cohead_cust_id,
             _r.cohead_shipto_id,pNEW.qty_ordered,_r.cohead_curr_id,_r.cohead_orderdate)),
    COALESCE(getUomId(pNEW.price_uom),_r.item_price_uom_id),
    itemuomtouomratio(_r.item_id,COALESCE(getUomId(pNEW.price_uom),_r.item_price_uom_id),_r.item_price_uom_id),
    itemPrice(_r.item_id, _r.cohead_cust_id, _r.cohead_shipto_id,
              pNEW.qty_ordered, _r.item_inv_uom_id, _r.item_price_uom_id,
              _r.cohead_curr_id,_r.cohead_orderdate,
              CASE WHEN (fetchMetricText('soPriceEffective') = 'ScheduleDate') THEN pNEW.scheduled_date
                   WHEN (fetchMetricText('soPriceEffective') = 'OrderDate') THEN _r.cohead_orderdate
                   ELSE CURRENT_DATE END,
              NULL),
    listPrice(_r.item_id, _r.cohead_cust_id, _r.cohead_shipto_id, _r.warehous_id),
    -1,
    pNEW.notes,
    true,
    0,
    pNEW.customer_pn,
    CASE
      WHEN ((pNEW.create_order  AND (_r.item_type = 'M')) OR
           ((pNEW.create_order IS NULL) AND _r.itemsite_createwo) AND (NOT _r.itemsite_stocked)) THEN
        'W'
      WHEN ((pNEW.create_order AND (_r.item_type = 'P')) OR
           ((pNEW.create_order IS NULL) AND _r.itemsite_createsopr) AND (NOT _r.itemsite_stocked)) THEN
        'R'
      WHEN ((pNEW.create_order AND (_r.item_type = 'P') AND (_r.itemsite_createsopo)) OR
           ((pNEW.create_order IS NULL) AND _r.itemsite_createsopo) AND (NOT _r.itemsite_stocked)) THEN
        'P'
    END,
    getitemid(pNEW.substitute_for),
    pNEW.overwrite_po_price,
    COALESCE(getTaxTypeId(pNEW.tax_type), getItemTaxType(_r.item_id, _r.cohead_taxzone_id)),
    pNEW.warranty,
    getGlAccntId(pNEW.alternate_cos_account),
    getGlAccntId(pNEW.alternate_rev_account)
    );

  RETURN TRUE;
END;
$$ LANGUAGE 'plpgsql';

--Rules

CREATE OR REPLACE RULE "_INSERT" AS
    ON INSERT TO api.salesline DO INSTEAD  SELECT api.insertsalesline(new.*) AS insertsalesline;

CREATE OR REPLACE RULE "_UPDATE" AS 
    ON UPDATE TO api.salesline DO INSTEAD

  UPDATE coitem SET
    coitem_status=NEW.status,
    coitem_scheddate=NEW.scheduled_date,
    coitem_promdate=NEW.promise_date,
    coitem_qtyord=NEW.qty_ordered,
    coitem_qty_uom_id=getUomId(NEW.qty_uom),
    coitem_qty_invuomratio=itemuomtouomratio(item_id,getUomId(NEW.qty_uom),item_inv_uom_id),
    coitem_price=NEW.net_unit_price,
    coitem_price_uom_id=getUomId(NEW.price_uom),
    coitem_price_invuomratio=itemuomtouomratio(item_id,getUomId(NEW.price_uom),item_price_uom_id),
    coitem_memo=NEW.notes,
    coitem_order_type=
    CASE
      WHEN (NOT OLD.create_order AND NEW.create_order  AND (item_type = 'M')) THEN
        'W'
      WHEN (NOT OLD.create_order AND NEW.create_order AND (item_type = 'P') AND (itemsite_createsopo)) THEN
        'P' 
      WHEN (NOT OLD.create_order AND NEW.create_order AND (item_type = 'P')) THEN
        'R'     
    END,
    coitem_substitute_item_id = getitemid(NEW.substitute_for),
    coitem_prcost=NEW.overwrite_po_price,
    coitem_taxtype_id=
    CASE
      WHEN (NEW.tax_type='None') THEN
        NULL
      ELSE getTaxTypeId(NEW.tax_type)
    END,
    coitem_warranty=NEW.warranty,
    coitem_cos_accnt_id=getGlAccntId(NEW.alternate_cos_account),
    coitem_rev_accnt_id=getGlAccntId(NEW.alternate_rev_account)
   FROM item JOIN itemsite ON (item_id=itemsite_item_id)
   WHERE ((item_number=OLD.item_number)
   AND (coitem_cohead_id=getCoheadId(OLD.order_number))
   AND (coitem_id=getCoitemId(OLD.order_number,OLD.line_number))
   AND (coitem_subnumber=0));

CREATE OR REPLACE RULE "_DELETE" AS 
    ON DELETE TO api.salesline DO INSTEAD

  DELETE FROM coitem
  WHERE ((coitem_cohead_id=getCoheadId(OLD.order_number))
  AND (coitem_linenumber::varchar=OLD.line_number)
  AND (coitem_subnumber=0));
