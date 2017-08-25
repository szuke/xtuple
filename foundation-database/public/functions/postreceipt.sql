DROP FUNCTION IF EXISTS postreceipt(INTEGER, INTEGER);
CREATE OR REPLACE FUNCTION postreceipt(precvId INTEGER, 
                                       pItemlocSeries INTEGER,
                                       pPreDistributed BOOLEAN DEFAULT FALSE)
  RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _itemlocSeries	INTEGER := COALESCE(pItemlocSeries, NEXTVAL('itemloc_series_seq'));
  _glDate	TIMESTAMP WITH TIME ZONE;
  _o RECORD;
  _ordertypeabbr TEXT;
  _r RECORD;
  _ra	RECORD;
  _recvinvqty NUMERIC := 0.00;
  _recvvalue NUMERIC := 0.00;
  _pricevar NUMERIC := 0.00;
  _tmp INTEGER;
  _coheadid INTEGER;
  _coitemid	 INTEGER;
  _linenumber  INTEGER;
  _invhistid	 INTEGER;
  _ship  BOOLEAN;
  _sourceItemsiteControlled BOOLEAN;
  _i RECORD;

BEGIN
  IF (pPreDistributed AND COALESCE(pItemlocSeries, 0) = 0) THEN 
    RAISE EXCEPTION 'pItemlocSeries is Required when pPreDistributed [xtuple: postReceipt, -7]';
  -- TODO - find why/how passing 0 instead of null for pItemlocSeries
  ELSIF (_itemlocSeries = 0) THEN
    _itemlocSeries := NEXTVAL('itemloc_series_seq');
  END IF;

  SELECT recv_id, recv_order_type, recv_orderitem_id, recv_qty, 
    round(currToBase(recv_freight_curr_id, recv_freight, recv_date::DATE), 2) AS recv_freight_base,
	  recv_freight, recv_freight_curr_id, recv_date, recv_gldistdate, recv_purchcost, recv_order_number,
	  itemsite_id, itemsite_item_id, item_inv_uom_id, itemsite_costmethod, 
    itemsite_controlmethod, vend_name, item_number, item_fractional, isControlledItemsite(itemsite_id) AS controlled,
    orderitem_id, orderitem_orderhead_id, orderitem_linenumber, orderitem_qty_invuomratio INTO _r
  FROM recv 
    JOIN orderitem ON recv_orderitem_id = orderitem_id AND orderitem_orderhead_type = recv_order_type
    LEFT OUTER JOIN itemsite ON recv_itemsite_id = itemsite_id
    LEFT OUTER JOIN item ON itemsite_item_id = item_id
    LEFT OUTER JOIN vendinfo ON recv_vend_id=vend_id
  WHERE recv_id = precvid
    AND NOT recv_posted;

  IF (NOT FOUND) THEN
    RAISE EXCEPTION 'This receipt line has already been posted. recv_id: %. 
      [xtuple: postReceipt, -10, %]', precvid, precvid;
  ELSEIF (_r.recv_qty <= 0) THEN
    RAISE EXCEPTION 'Can not post receipt for qty %. Please correct qty and try again. 
      [xtuple: postReceipt, -11, %]', _r.recv_qty, _r.recv_qty;
  END IF;

  IF (_r.recv_order_type ='PO') THEN
    _ordertypeabbr := ('P/O for ' || _r.vend_name || ' for item ' || _r.item_number);

    SELECT currToBase(pohead_curr_id,
        COALESCE(_r.recv_purchcost, poitem_unitprice),
        _r.recv_date::DATE) AS item_unitprice_base,
      poitem_prj_id AS prj_id INTO _o
    FROM poitem, pohead
    WHERE poitem_id = _r.recv_orderitem_id
      AND poitem_pohead_id = pohead_id;

  ELSIF (_r.recv_order_type ='RA') THEN
    _ordertypeabbr := 'R/A for item ' || _r.item_number;

    SELECT currToBase(rahead_curr_id, raitem_unitprice, _r.recv_date::DATE) AS item_unitprice_base,
      rahead_prj_id AS prj_id, raitem_unitcost INTO _o
    FROM raitem, rahead
    WHERE raitem_id = _r.recv_orderitem_id
      AND raitem_rahead_id = rahead_id;

  ELSIF (_r.recv_order_type ='TO') THEN
     _ordertypeabbr := 'T/O for item ' || _r.item_number;

    SELECT toitem_stdcost AS item_unitprice_base,
      NULL AS prj_id INTO _o
    FROM toitem
    WHERE toitem_id = _r.recv_orderitem_id;
  ELSE -- don't know how to handle this order type
    RAISE EXCEPTION 'Cant post receipt for this order type [xtuple: postReceipt, -13]';
  END IF;

  _glDate := COALESCE(_r.recv_gldistdate, _r.recv_date);
  _recvinvqty := roundQty(_r.item_fractional, (_r.recv_qty * _r.orderitem_qty_invuomratio));

  IF ( (_r.recv_order_type = 'PO') AND
        (_r.itemsite_id = -1 OR _r.itemsite_id IS NULL OR _r.itemsite_controlmethod = 'N') ) THEN

    IF (round((_o.item_unitprice_base * _r.recv_qty),2) <> 0) THEN
      IF (_r.itemsite_id IS NOT NULL ) THEN
        SELECT insertGLTransaction( fetchJournalNumber('GL-MISC'),
          'S/R', _r.recv_order_type,
          (_r.recv_order_number::TEXT || '-' || _r.orderitem_linenumber::TEXT),
          'Receive Non-Controlled Inventory from ' || _ordertypeabbr,
          costcat_liability_accnt_id,
          getPrjAccntId(poitem_prj_id, costcat_exp_accnt_id), -1,
          round((_o.item_unitprice_base * _r.recv_qty),2),
          _glDate::DATE, false ) INTO _tmp
        FROM poitem, itemsite, costcat
        WHERE poitem_itemsite_id = itemsite_id
          AND itemsite_costcat_id = costcat_id
          AND poitem_id = _r.orderitem_id;
      ELSE
        SELECT insertGLTransaction(fetchJournalNumber('GL-MISC'),
          'S/R', _r.recv_order_type,
          (_r.recv_order_number::TEXT || '-' || _r.orderitem_linenumber::TEXT),
          'Receive Non-Inventory from ' || 'P/O for ' || _r.vend_name || ' for ' || expcat_code,
          expcat_liability_accnt_id,
          getPrjAccntId(poitem_prj_id, expcat_exp_accnt_id), -1,
          round((_o.item_unitprice_base * _r.recv_qty),2),
          _glDate::DATE, false ) INTO _tmp
        FROM poitem, expcat
        WHERE poitem_expcat_id = expcat_id
          AND poitem_id = _r.orderitem_id;
      END IF;

      -- Posting to trial balance is deferred to prevent locking
      INSERT INTO itemlocpost ( itemlocpost_glseq, itemlocpost_itemlocseries)
      VALUES ( _tmp, _itemlocSeries );
    END IF;

    IF (round(_r.recv_freight_base,2) <> 0) THEN
      SELECT insertGLTransaction( fetchJournalNumber('GL-MISC'),
        'S/R', _r.recv_order_type,
        (_r.recv_order_number::TEXT || '-' || _r.orderitem_linenumber::TEXT),
        'Receive Non-Inventory Freight from ' || _ordertypeabbr,
        expcat_liability_accnt_id,
        getPrjAccntId(poitem_prj_id, expcat_freight_accnt_id), -1,
        _r.recv_freight_base,
        _glDate::DATE, false ) INTO _tmp
      FROM poitem, expcat
      WHERE((poitem_expcat_id=expcat_id)
        AND (poitem_id=_r.orderitem_id));

      IF (_tmp < 0) THEN 
        RETURN _tmp;
      END IF;

      -- Posting to trial balance is deferred to prevent locking
      INSERT INTO itemlocpost ( itemlocpost_glseq, itemlocpost_itemlocseries)
      VALUES ( _tmp, _itemlocSeries );
    END IF;

    _recvvalue := ROUND((_o.item_unitprice_base * _r.recv_qty),2);

    UPDATE poitem
    SET poitem_qty_received = (poitem_qty_received + _r.recv_qty),
	    poitem_freight_received = (poitem_freight_received + COALESCE(_r.recv_freight, 0))
    WHERE (poitem_id=_r.orderitem_id);

  ELSEIF ( (_r.recv_order_type = 'RA') AND
           (_r.itemsite_id = -1 OR _r.itemsite_id IS NULL) ) THEN
    RAISE EXCEPTION 'Missing itemsite, can not post receipt. [xtuple: postReceipt, -14]';	-- otherwise how do we get the accounts?

  ELSEIF ( (_r.recv_order_type = 'TO') AND
           (_r.itemsite_id = -1 OR _r.itemsite_id IS NULL) ) THEN
    RAISE EXCEPTION 'Missing itemsite, can not post transfer order receipt. [xtuple: postReceipt, -14]';
  ELSE	-- not ELSIF: some code is shared between diff order types
    IF (_r.recv_order_type = 'PO') THEN
      SELECT postInvTrans( itemsite_id, 'RP'::TEXT,
        _recvinvqty,
        'S/R'::TEXT,
        _r.recv_order_type::TEXT, _r.recv_order_number::TEXT || '-' || _r.orderitem_linenumber::TEXT,
        ''::TEXT,
        'Receive Inventory from ' || _ordertypeabbr,
        costcat_asset_accnt_id, costcat_liability_accnt_id,
        _itemlocSeries,
        _glDate,
        round((_o.item_unitprice_base * _r.recv_qty),2), -- always passing this in since it is ignored if it is not average costed item
        NULL, NULL, pPreDistributed) INTO _tmp
      FROM itemsite, costcat
      WHERE ( (itemsite_costcat_id=costcat_id)
       AND (itemsite_id=_r.itemsite_id) );
      
      IF (NOT FOUND) THEN
	      RAISE EXCEPTION 'Could not post inventory transaction: no cost category found for itemsite_id %
          [xtuple: postReceipt, -39, %]', _r.itemsite_id, _r.itemsite_id;
      END IF;

      -- If the 'Purchase Price Variance on Receipt' option is true
      IF (fetchMetricBool('RecordPPVonReceipt')) THEN
        _invhistid := _tmp;
        -- Find the difference in the purchase price value expected from the P/O and the value of the transaction
        SELECT ((_o.item_unitprice_base * _r.recv_qty) - (invhist_value_after - invhist_value_before)) INTO _pricevar
        FROM invhist
        WHERE (invhist_id = _invhistid);

        -- If difference exists then
        IF (_pricevar <> 0.00) THEN
          -- Record an additional GL Transaction for the purchase price variance
          SELECT insertGLTransaction( fetchJournalNumber('GL-MISC'),
		 		       'S/R', _r.recv_order_type,
                                     (_r.recv_order_number::TEXT || '-' || _r.orderitem_linenumber::TEXT),
                                      'Purchase price variance adjusted for P/O ' || _r.recv_order_number || ' for item ' || _r.item_number,
                                      costcat_liability_accnt_id,
                                      getPrjAccntId(_o.prj_id, costcat_purchprice_accnt_id), -1,
                                      _pricevar,
                                      _glDate::DATE, false ) INTO _tmp
          FROM itemsite, costcat
          WHERE itemsite_costcat_id = costcat_id
             AND itemsite_id = _r.itemsite_id;
          IF (NOT FOUND) THEN
            RAISE EXCEPTION 'Could not insert G/L transaction: no cost category found for itemsite_id % 
              [xtuple: postReceipt, -42, %]', _r.itemsite_id, _r.itemsite_id;
          END IF;

          -- Posting to trial balance is deferred to prevent locking
          INSERT INTO itemlocpost ( itemlocpost_glseq, itemlocpost_itemlocseries)
          VALUES ( _tmp, _itemlocSeries );
        END IF;
      END IF;

      IF (round(_r.recv_freight_base,2) <> 0) THEN
        SELECT insertGLTransaction(fetchJournalNumber('GL-MISC'),
  				  'S/R', _r.recv_order_type,
                                  (_r.recv_order_number::TEXT || '-' || _r.orderitem_linenumber::TEXT),
  				  'Receive Inventory Freight from ' || _r.recv_order_number || ' for item ' || _r.item_number,
  				   costcat_liability_accnt_id,
  				   getPrjAccntId(_o.prj_id, costcat_freight_accnt_id), -1,
  				   _r.recv_freight_base,
  				   _glDate::DATE, false ) INTO _tmp
        FROM itemsite, costcat
        WHERE ( (itemsite_costcat_id=costcat_id)
         AND (itemsite_id=_r.itemsite_id) );

        IF (NOT FOUND) THEN
          RAISE EXCEPTION 'Could not insert G/L transaction: no cost category found for itemsite_id % 
              [xtuple: postReceipt, -42, %]', _r.itemsite_id, _r.itemsite_id;
        END IF;

        -- Posting to trial balance is deferred to prevent locking
        INSERT INTO itemlocpost ( itemlocpost_glseq, itemlocpost_itemlocseries)
        VALUES ( _tmp, _itemlocSeries );
      END IF;
      
      UPDATE poitem
      SET poitem_qty_received = (poitem_qty_received + _r.recv_qty),
	      poitem_freight_received = (poitem_freight_received + COALESCE(_r.recv_freight, 0))
      WHERE (poitem_id=_r.orderitem_id);

    ELSIF (_r.recv_order_type = 'RA') THEN
      SELECT rahead_id, rahead_number, rahead_cust_id, rahead_saletype_id,
             rahead_shipzone_id, rahead_timing, rahead_new_cohead_id,
             raitem.* INTO _ra
	    FROM rahead
        JOIN raitem ON (rahead_id=raitem_rahead_id)
      WHERE (raitem_id=_r.recv_orderitem_id);

      IF (_r.itemsite_controlmethod = 'N' AND (round((_o.item_unitprice_base * _r.recv_qty),2) <> 0)) THEN
        SELECT insertGLTransaction( fetchJournalNumber('GL-MISC'),
                                    'S/R', _r.recv_order_type,
                                    (_r.recv_order_number::TEXT || '-' || _r.orderitem_linenumber::TEXT),
                                    'Receive Non-Controlled Inventory from ' || _ordertypeabbr,
                                    costcat_liability_accnt_id,
                                    getPrjAccntId(_o.prj_id, costcat_exp_accnt_id), -1,
                                    round((_o.item_unitprice_base * _r.recv_qty),2),
                                    _glDate::DATE, false ) INTO _tmp
        FROM itemsite JOIN costcat ON (costcat_id=itemsite_costcat_id)
        WHERE(itemsite_id=_r.itemsite_id);
        
        IF (NOT FOUND) THEN
          RAISE EXCEPTION 'Could not insert G/L transaction: no cost category found for itemsite_id % 
              [xtuple: postReceipt, -42, %]', _r.itemsite_id, _r.itemsite_id;
        END IF;
      ELSE
        SELECT postInvTrans(_r.itemsite_id, 'RR',
            _recvinvqty,
            'S/R',
            _r.recv_order_type, _ra.rahead_number::TEXT || '-' || _ra.raitem_linenumber::TEXT,
            '',
            'Receive Inventory from ' || _ordertypeabbr,
            costcat_asset_accnt_id,
            CASE 
              WHEN(COALESCE(_ra.raitem_cos_accnt_id, -1) != -1) THEN
                getPrjAccntId(_o.prj_id, _ra.raitem_cos_accnt_id)
              WHEN (_ra.raitem_warranty) THEN
                getPrjAccntId(_o.prj_id, resolveCOWAccount(_r.itemsite_id, _ra.rahead_cust_id, _ra.rahead_saletype_id, _ra.rahead_shipzone_id))
              ELSE
                getPrjAccntId(_o.prj_id, resolveCORAccount(_r.itemsite_id, _ra.rahead_cust_id, _ra.rahead_saletype_id, _ra.rahead_shipzone_id))
            END,
            _itemlocSeries, _glDate, COALESCE(_o.raitem_unitcost, stdcost(itemsite_item_id)) * _recvinvqty,
            NULL, NULL, pPreDistributed) INTO _tmp
        FROM itemsite, costcat
        WHERE ( (itemsite_costcat_id=costcat_id)
         AND (itemsite_id=_r.itemsite_id) );

        IF (NOT FOUND) THEN
          RAISE EXCEPTION 'Could not post inventory transaction: no cost category found for itemsite_id %
            [xtuple: postReceipt, -39, %]', _r.itemsite_id, _r.itemsite_id;
        END IF;
      END IF;

      INSERT INTO rahist (rahist_itemsite_id, rahist_date,
			  rahist_descrip,
			  rahist_qty, rahist_uom_id,
			  rahist_source, rahist_source_id, rahist_rahead_id) 
      VALUES (_r.itemsite_id, _glDate,
        'Receive Inventory from ' || _ordertypeabbr,
        _recvinvqty, _r.item_inv_uom_id,
        'RR', _r.recv_id, _ra.rahead_id);

      IF (round(_r.recv_freight_base,2) <> 0) THEN
        SELECT insertGLTransaction(fetchJournalNumber('GL-MISC'),
          'S/R', _r.recv_order_type,
          (_r.recv_order_number::TEXT || '-' || _r.orderitem_linenumber::TEXT),
          'Receive Inventory Freight from ' || _r.recv_order_number || ' for item ' || _r.item_number,
          costcat_liability_accnt_id,
          getPrjAccntId(_o.prj_id, costcat_freight_accnt_id), -1,
          _r.recv_freight_base,
          _glDate::DATE, false ) INTO _tmp
        FROM itemsite, costcat
        WHERE ( (itemsite_costcat_id=costcat_id)
         AND (itemsite_id=_r.itemsite_id) );
        
        IF (NOT FOUND) THEN -- error but not 0-value transaction
          RAISE EXCEPTION 'Could not insert G/L transaction: no cost category found for itemsite_id % 
              [xtuple: postReceipt, -42, %]', _r.itemsite_id, _r.itemsite_id;
        END IF;

        -- Posting to trial balance is deferred to prevent locking
        INSERT INTO itemlocpost ( itemlocpost_glseq, itemlocpost_itemlocseries)
        VALUES ( _tmp, _itemlocSeries );
      END IF;

      INSERT INTO rahist (rahist_date, rahist_descrip,
			  rahist_source, rahist_source_id,
			  rahist_curr_id, rahist_amount,
			  rahist_rahead_id) 
      VALUES (_glDate, 'Receive Inventory Freight from ' || _ordertypeabbr,
  		  'RR', _r.recv_id, _r.recv_freight_curr_id, _r.recv_freight,
  		  _ra.rahead_id
  	  );

      UPDATE raitem
      SET raitem_qtyreceived = (raitem_qtyreceived + _r.recv_qty)
      WHERE (raitem_id=_r.orderitem_id);

-- Expire date doesn't mean anything once the RA is received
-- WARNING: INSERTING 'NULL' MIGHT CAUSE PROBLEMS!!
      UPDATE rahead
      SET rahead_expiredate = NULL
      WHERE (rahead_id=_r.orderitem_orderhead_id);

--  Look for 'ship' lines
      SELECT (count(*) > 0) INTO _ship
      FROM raitem
      WHERE ((raitem_disposition = 'S')
       AND (raitem_new_coitem_id IS NULL)
       AND (raitem_rahead_id=_ra.rahead_id));

--  If receiving a qty on a shippable and upon receipt item, create coitem
      IF ((_ra.rahead_timing='R') AND
          (_ship OR (
          (_ra.raitem_disposition IN ('P','V')) AND
          (_ra.raitem_new_coitem_id IS NULL) AND
          (_ra.raitem_qtyauthorized > 0)))) THEN

          IF (_ra.rahead_new_cohead_id IS NOT NULL) THEN
            _coheadid = _ra.rahead_new_cohead_id;
          ELSE
--  No header, so create a Sales Order header first.
            SELECT nextval('cohead_cohead_id_seq') INTO _coheadid;

            INSERT INTO cohead (
              cohead_id,cohead_number,cohead_cust_id,cohead_custponumber,
              cohead_orderdate,cohead_salesrep_id,cohead_terms_id,
              cohead_shipvia,cohead_shipto_id,cohead_shiptoname,
              cohead_shiptoaddress1,cohead_shiptoaddress2,cohead_shiptoaddress3,
              cohead_shiptocity,cohead_shiptostate,cohead_shiptozipcode,
              cohead_shiptocountry,cohead_freight,cohead_shiptophone,
              cohead_shipto_cntct_id, cohead_shipto_cntct_honorific,
              cohead_shipto_cntct_first_name, cohead_shipto_cntct_middle,
              cohead_shipto_cntct_last_name, cohead_shipto_cntct_suffix,
              cohead_shipto_cntct_phone, cohead_shipto_cntct_title,
              cohead_shipto_cntct_fax, cohead_shipto_cntct_email,
              cohead_shipchrg_id, cohead_shipform_id,cohead_billtoname,
              cohead_billtoaddress1,cohead_billtoaddress2,cohead_billtoaddress3,
              cohead_billtocity,cohead_billtostate,cohead_billtozipcode,
              cohead_billtocountry,cohead_misc_accnt_id,cohead_misc_descrip,
              cohead_commission,cohead_holdtype,cohead_prj_id,cohead_shipcomplete,
              cohead_curr_id,cohead_taxzone_id,cohead_saletype_id,cohead_shipzone_id)
            SELECT _coheadid,fetchsonumber(),rahead_cust_id,rahead_custponumber,
              current_date,rahead_salesrep_id,COALESCE(cohead_terms_id,cust_terms_id),
              COALESCE(cohead_shipvia,cust_shipvia),rahead_shipto_id,rahead_shipto_name,
              rahead_shipto_address1,rahead_shipto_address2,rahead_shipto_address3,
              rahead_shipto_city,rahead_shipto_state,rahead_shipto_zipcode,
              rahead_shipto_country,0,COALESCE(cohead_shiptophone,''),
              cntct_id, cntct_honorific,
              cntct_first_name, cntct_middle,
              cntct_last_name, cntct_suffix,
              cntct_phone, cntct_title,
              cntct_fax, cntct_email,
              COALESCE(cohead_shipchrg_id,cust_shipchrg_id),
              COALESCE(cohead_shipform_id,cust_shipform_id),
              rahead_billtoname,rahead_billtoaddress1,rahead_billtoaddress2,rahead_billtoaddress3,
              rahead_billtocity,rahead_billtostate,rahead_billtozip,
              rahead_billtocountry,NULL,'',rahead_commission, 'N', rahead_prj_id,
              COALESCE(cohead_shipcomplete,
                CASE WHEN cust_partialship THEN
                  false
                ELSE true
                END),rahead_curr_id,rahead_taxzone_id,rahead_saletype_id,rahead_shipzone_id
            FROM rahead
              JOIN custinfo ON (rahead_cust_id=cust_id)
              LEFT OUTER JOIN cohead ON (rahead_orig_cohead_id=cohead_id)
              LEFT OUTER JOIN shiptoinfo ON (rahead_shipto_id=shipto_id)
              LEFT OUTER JOIN cntct ON (shipto_cntct_id=cntct_id)
            WHERE (rahead_id=_ra.rahead_id);

            UPDATE rahead SET rahead_new_cohead_id=_coheadid WHERE rahead_id=_ra.rahead_id;

          END IF;

-- Now enter the line item(s)
        IF (_ra.raitem_disposition IN ('P','V')) AND
           (_ra.raitem_new_coitem_id IS NULL) AND
           (_ra.raitem_qtyauthorized > 0) THEN

          SELECT nextval('coitem_coitem_id_seq') INTO _coitemid;

          SELECT COALESCE(MAX(coitem_linenumber),0)+1 INTO _linenumber
          FROM coitem
          WHERE (coitem_cohead_id=_coheadid);

          INSERT INTO coitem (
            coitem_id,coitem_cohead_id,coitem_linenumber,coitem_itemsite_id,
            coitem_status,coitem_scheddate,coitem_promdate, coitem_qtyord,
            coitem_unitcost,coitem_price,coitem_custprice,coitem_qtyshipped,
            coitem_order_id,coitem_memo,coitem_qtyreturned,
            coitem_taxtype_id,coitem_qty_uom_id,coitem_qty_invuomratio,
            coitem_price_uom_id,coitem_price_invuomratio,coitem_warranty,
            coitem_cos_accnt_id,coitem_order_type, coitem_custpn)
          SELECT _coitemid,_coheadid,_linenumber,_ra.raitem_coitem_itemsite_id,
              'O',_ra.raitem_scheddate,_ra.raitem_scheddate,_ra.raitem_qtyauthorized,
              stdcost(itemsite_item_id),COALESCE(_ra.raitem_saleprice,0),0,0,
              -1,_ra.raitem_notes,0,
              _ra.raitem_taxtype_id,_ra.raitem_qty_uom_id,_ra.raitem_qty_invuomratio,
              _ra.raitem_price_uom_id,_ra.raitem_price_invuomratio,_ra.raitem_warranty,
              _ra.raitem_cos_accnt_id,
              CASE WHEN itemsite_createwo THEN 'W' ELSE NULL END, _ra.raitem_custpn
          FROM itemsite
          WHERE (itemsite_id=_ra.raitem_coitem_itemsite_id);

          UPDATE raitem SET raitem_new_coitem_id=_coitemid WHERE (raitem_id=_ra.raitem_id);
        END IF;

        -- Create items to ship that have no direct relation to receipts.
        IF (_ship) THEN
          FOR _i IN
            SELECT raitem_id FROM raitem
            WHERE ((raitem_rahead_id=_ra.rahead_id)
              AND (raitem_disposition = 'S')
              AND (raitem_new_coitem_id IS NULL))
          LOOP

            SELECT nextval('coitem_coitem_id_seq') INTO _coitemid;

            SELECT COALESCE(MAX(coitem_linenumber),0)+1 INTO _linenumber
              FROM coitem
            WHERE (coitem_cohead_id=_coheadid);

            INSERT INTO coitem (
              coitem_id,coitem_cohead_id,coitem_linenumber,coitem_itemsite_id,
              coitem_status,coitem_scheddate,coitem_promdate, coitem_qtyord,
              coitem_unitcost,coitem_price,coitem_custprice,coitem_qtyshipped,
              coitem_order_id,coitem_memo,coitem_qtyreturned,
              coitem_taxtype_id,coitem_qty_uom_id,coitem_qty_invuomratio,
              coitem_price_uom_id,coitem_price_invuomratio,coitem_warranty,
              coitem_cos_accnt_id,coitem_order_type,coitem_custpn)
            SELECT _coitemid,_coheadid,_linenumber,raitem_coitem_itemsite_id,
              'O',raitem_scheddate,raitem_scheddate,raitem_qtyauthorized,
              stdcost(itemsite_item_id),COALESCE(raitem_saleprice,0),0,0,
              -1,raitem_notes,0,
              raitem_taxtype_id,raitem_qty_uom_id,raitem_qty_invuomratio,
              raitem_price_uom_id,raitem_price_invuomratio,raitem_warranty,
              raitem_cos_accnt_id,
              CASE WHEN itemsite_createwo THEN 'W' ELSE NULL END,raitem_custpn
            FROM raitem
              JOIN itemsite ON (itemsite_id=raitem_itemsite_id)
            WHERE (raitem_id=_i.raitem_id);

            UPDATE raitem SET raitem_new_coitem_id=_coitemid WHERE (raitem_id=_i.raitem_id);

          END LOOP;
        END IF;
      END IF;

    ELSIF (_r.recv_order_type = 'TO' AND fetchMetricBool('MultiWhs')) THEN
      SELECT interWarehouseTransfer(toitem_item_id, tohead_trns_warehous_id,
            tohead_dest_warehous_id, _r.recv_qty,
            'TO', formatToNumber(toitem_id), 'Receive from Transit To Dest Warehouse',
            _itemlocSeries, _glDate, pPreDistributed, 
            false), --pPostDistDetail set to false so that interWarehouseTransfer doesn't call postDistDetail in addition.
            isControlledItemsite(srcitemsite.itemsite_id) INTO _tmp, _sourceItemsiteControlled
      FROM tohead
        JOIN toitem ON tohead_id = toitem_tohead_id 
        JOIN item ON toitem_item_id = item_id
        JOIN itemsite AS srcitemsite ON item_id = srcitemsite.itemsite_item_id 
          AND tohead_trns_warehous_id = srcitemsite.itemsite_warehous_id
      WHERE toitem_id=_r.recv_orderitem_id
        AND item_type NOT IN ('R', 'F', 'J');

      IF (NOT FOUND) THEN
        RAISE EXCEPTION 'Could not find the transfer order item to post. 
          Be sure the Item Type is not R, F or J [xtuple: postReceipt, -40]';
      END IF;

      IF (round(_r.recv_freight_base,2) <> 0) THEN
        SELECT insertGLTransaction(fetchJournalNumber('GL-MISC'),
  				  'S/R', _r.recv_order_type,
                                  (_r.recv_order_number::TEXT || '-' || _r.orderitem_linenumber::TEXT),
  				  'Receive Inventory Freight from ' || _r.recv_order_number || ' for item ' || _r.item_number,
  				   costcat_toliability_accnt_id,
  				   costcat_freight_accnt_id, -1,
  				   _r.recv_freight_base,
  				   _glDate::DATE, false ) INTO _tmp
        FROM itemsite, costcat
        WHERE ( (itemsite_costcat_id=costcat_id)
         AND (itemsite_id=_r.itemsite_id) );

        IF (NOT FOUND) THEN
          RAISE EXCEPTION 'Could not insert G/L transaction: no cost category found for itemsite_id % 
              [xtuple: postReceipt, -42, %]', _r.itemsite_id, _r.itemsite_id;
        END IF;

        -- Posting to trial balance is deferred to prevent locking
        INSERT INTO itemlocpost ( itemlocpost_glseq, itemlocpost_itemlocseries)
        VALUES ( _tmp, _itemlocSeries );
      END IF;

      UPDATE toitem
      SET toitem_qty_received = (toitem_qty_received + _r.recv_qty),
	  toitem_freight_received = (toitem_freight_received +
				      currToCurr(_r.recv_freight_curr_id,
						 toitem_freight_curr_id,
						 _r.recv_freight, _glDate::DATE))
      WHERE (toitem_id=_r.orderitem_id);

    END IF;
    IF(_r.itemsite_costmethod='A') THEN
      _recvvalue := ROUND((_o.item_unitprice_base * _r.recv_qty),2);
    ELSIF (fetchMetricBool('RecordPPVonReceipt')) THEN
      _recvvalue := ROUND((_o.item_unitprice_base * _r.recv_qty), 2);
    ELSE
      _recvvalue := ROUND(stdcost(_r.itemsite_item_id) * _recvinvqty, 2);
    END IF;
  END IF;

  UPDATE recv
  SET recv_value=_recvvalue, recv_recvcost=_recvvalue / recv_qty, recv_posted=TRUE, recv_gldistdate=_glDate::DATE
  WHERE (recv_id=precvid);

  IF (_r.recv_order_type = 'PO') THEN
    -- If this is a drop-shipped PO, then Issue the item to Shipping and Ship the item
    -- Generate the PoItemDropShipped event
    PERFORM postEvent('PoItemDropShipped', 'P', poitem_id,
                      itemsite_warehous_id,
                      (pohead_number || '-' || poitem_linenumber || ': ' || item_number),
                      NULL, NULL, NULL, NULL)
    FROM poitem JOIN itemsite ON (itemsite_id=poitem_itemsite_id)
                JOIN item ON (item_id=itemsite_item_id)
                JOIN pohead ON (pohead_id=poitem_pohead_id)
    WHERE poitem_id = _r.orderitem_id
      AND pohead_dropship = TRUE
      AND poitem_duedate <= (CURRENT_DATE + itemsite_eventfence);

  END IF;

  -- Post distribution detail regardless of loc/control methods because postItemlocSeries is required.
  -- If it is a controlled item and the results were 0 something is wrong.
  IF (pPreDistributed) THEN
    IF (postDistDetail(_itemlocSeries) <= 0 AND (_r.controlled OR _sourceItemsiteControlled)) THEN
      RAISE EXCEPTION 'Posting Distribution Detail Returned 0 Results, [xtuple: postReceipt, -41]';
    END IF;
  END IF;

  RETURN _itemlocSeries;

END;
$$ LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION postreceipt(INTEGER, INTEGER, BOOLEAN) OWNER TO admin;
