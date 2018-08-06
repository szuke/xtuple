DROP FUNCTION IF EXISTS voidCreditMemo(INTEGER);
CREATE OR REPLACE FUNCTION voidCreditMemo(pCmheadid INTEGER,
                                          pItemlocSeries INTEGER DEFAULT NULL,
                                          pPreDistributed BOOLEAN DEFAULT FALSE) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _r RECORD;
  _p RECORD;
  _n RECORD;
  _glSequence INTEGER := 0;
  _glJournal INTEGER := 0;
  _itemlocSeries INTEGER := COALESCE(pItemlocSeries, NEXTVAL('itemloc_series_seq'));
  _invhistid INTEGER;
  _test INTEGER;
  _amount NUMERIC;
  _roundedBase NUMERIC;
  _totalAmount NUMERIC   := 0;
  _totalRoundedBase NUMERIC := 0;
  _commissionDue NUMERIC := 0;
  _toApply NUMERIC;
  _toClose BOOLEAN;
  _glDate	DATE;
  _taxBaseValue	NUMERIC	:= 0;
  _hasControlledItems BOOLEAN := FALSE;

BEGIN
  IF (pPreDistributed AND COALESCE(pItemlocSeries, 0) = 0) THEN
    RAISE EXCEPTION 'pItemlocSeries is Required when pPreDistributed [xtuple: voidCreditMemo, -3]';
  ELSIF (_itemlocSeries <= 0) THEN
    _itemlocSeries := NEXTVAL('itemloc_series_seq');
  END IF;

--  Cache C/M information
  SELECT cmhead.*,
         findARAccount(cmhead_cust_id) AS ar_accnt_id,
         ( SELECT COALESCE(SUM(taxhist_tax), 0)
           FROM cmheadtax
           WHERE ( (taxhist_parent_id = cmhead_id)
             AND   (taxhist_taxtype_id = getAdjustmentTaxtypeId()) ) ) AS adjtax
         INTO _p
  FROM cmhead
  WHERE (cmhead_id=pCmheadid);
  IF (NOT FOUND) THEN
    RAISE EXCEPTION 'Cannot Void Credit Memo as cmhead not found [xtuple: voidCreditMemo, -12]';
  END IF;
  IF (NOT _p.cmhead_posted) THEN
    RETURN -10;
  END IF;

--  Cache AROpen Information
  SELECT aropen.* INTO _n
  FROM aropen
  WHERE ( (aropen_doctype='C')
    AND   (aropen_docnumber=_p.cmhead_number) );
  IF (NOT FOUND) THEN
    RAISE EXCEPTION 'Cannot Void Credit Memo as aropen not found [xtuple: voidCreditMemo, -13]';
  END IF;

--  Check for ARApplications
  SELECT arapply_id INTO _test
  FROM arapply
  WHERE (arapply_target_aropen_id=_n.aropen_id)
     OR (arapply_source_aropen_id=_n.aropen_id)
  LIMIT 1;
  IF (FOUND) THEN
    RETURN -20;
  END IF;

  _glDate := COALESCE(_p.cmhead_gldistdate, _p.cmhead_docdate);

  SELECT fetchGLSequence() INTO _glSequence;
  SELECT fetchJournalNumber('AR-IN') INTO _glJournal;

--  Start by handling taxes (reverse sense)
  FOR _r IN SELECT tax_sales_accnt_id,
              round(sum(taxdetail_tax),2) AS tax,
              currToBase(_p.cmhead_curr_id, round(sum(taxdetail_tax),2), _p.cmhead_docdate) AS taxbasevalue
            FROM tax
             JOIN calculateTaxDetailSummary('CM', _p.cmhead_id, 'T') ON (taxdetail_tax_id=tax_id)
	    GROUP BY tax_id, tax_sales_accnt_id LOOP

    PERFORM insertIntoGLSeries( _glSequence, 'A/R', 'CM', _p.cmhead_number,
                                _r.tax_sales_accnt_id,
                                (_r.taxbasevalue * -1.0),
                                _glDate, ('Void-' || _p.cmhead_billtoname) );

    _totalAmount := _totalAmount + _r.tax * -1;
    _totalRoundedBase := _totalRoundedBase + _r.taxbasevalue * -1;
  END LOOP;

-- Process line items (with items)
  FOR _r IN SELECT *
            FROM creditmemoitem
            WHERE cmitem_cmhead_id=_p.cmhead_id
              AND cmitem_qtycredit <> 0
              AND cmitem_itemsite_id IS NOT NULL
  LOOP

    IF (_r.extprice <> 0) THEN
--  Debit the Sales Account for the current cmitem (reverse sense)
      _roundedBase := round(currToBase(_p.cmhead_curr_id, _r.extprice, _p.cmhead_docdate), 2);
      SELECT insertIntoGLSeries( _glSequence, 'A/R', 'CM', _p.cmhead_number,
                                 CASE WHEN _p.cmhead_rahead_id IS NULL THEN
                                   getPrjAccntId(_p.cmhead_prj_id, salesaccnt_credit_accnt_id)
                                 ELSE
                                   getPrjAccntId(_p.cmhead_prj_id, salesaccnt_returns_accnt_id)
                                 END,
                                 _roundedBase,
                                 _glDate, ('Void-' || _p.cmhead_billtoname) ) INTO _test
      FROM salesaccnt
      WHERE (salesaccnt_id=findSalesAccnt(_r.cmitem_itemsite_id, 'IS', _p.cmhead_cust_id,
                                          _p.cmhead_saletype_id, _p.cmhead_shipzone_id));
      IF (NOT FOUND) THEN
        PERFORM deleteGLSeries(_glSequence);
        RAISE EXCEPTION 'Unable to void this Credit Memo because the Sales Account was not found. [xtuple: voidCreditMemo, -11]';
      END IF;
    END IF;

    _totalAmount := _totalAmount + round(_r.extprice, 2);
    _totalRoundedBase := _totalRoundedBase + _roundedBase;

  END LOOP;

-- Process line items (with Miscellaneoous C/M items)
  FOR _r IN SELECT *
            FROM creditmemoitem
            JOIN salescat ON (salescat_id = cmitem_salescat_id)
            WHERE cmitem_cmhead_id=_p.cmhead_id
              AND cmitem_qtycredit <> 0
              AND cmitem_itemsite_id IS NULL
  LOOP

    IF (_r.extprice <> 0) THEN
--  Debit the Sales Account for the current cmitem (reverse sense)
      _roundedBase := round(currToBase(_p.cmhead_curr_id, _r.extprice, _p.cmhead_docdate), 2);
      SELECT insertIntoGLSeries( _glSequence, 'A/R', 'CM', _p.cmhead_number,
                                   getPrjAccntId(_p.cmhead_prj_id,
                                      COALESCE(_r.cmitem_rev_accnt_id, _r.salescat_sales_accnt_id)),
                                 _roundedBase,
                                 _glDate, ('Void-' || _p.cmhead_billtoname) ) INTO _test;
      IF (NOT FOUND) THEN
        PERFORM deleteGLSeries(_glSequence);
        RAISE EXCEPTION 'Unable to void this Credit Memo because the Sales Account was not found. [xtuple: voidCreditMemo, -11]';
      END IF;
    END IF;

    _totalAmount := _totalAmount + round(_r.extprice, 2);
    _totalRoundedBase := _totalRoundedBase + _roundedBase;

  END LOOP;

--  Credit the Misc. Account for Miscellaneous Charges (reverse sense)
  IF (_p.cmhead_misc <> 0) THEN
    _roundedBase := round(currToBase(_p.cmhead_curr_id, _p.cmhead_misc, _p.cmhead_docdate), 2);
    SELECT insertIntoGLSeries( _glSequence, 'A/R', 'CM', _p.cmhead_number,
                               getPrjAccntId(_p.cmhead_prj_id, accnt_id),
                               _roundedBase,
                               _glDate, ('Void-' ||_p.cmhead_billtoname) ) INTO _test
    FROM accnt
    WHERE (accnt_id=_p.cmhead_misc_accnt_id);

--  If the Misc. Charges Account was not found then punt
    IF (NOT FOUND) THEN
      PERFORM deleteGLSeries(_glSequence);
      IF (_test < 0) THEN
        RETURN _test;
      ELSE
        RAISE EXCEPTION 'Failed to create GL entry, no record found for accnt_id %
          [xtuple: voidCreditMemo, -7, %]', _p.cmhead_misc_accnt_id, _p.cmhead_misc_accnt_id;
      END IF;
    END IF;

--  Cache the Misc. Amount distributed
    _totalAmount := _totalAmount + _p.cmhead_misc;
    _totalRoundedBase := _totalRoundedBase + _roundedBase;
  END IF;

--  Debit the Freight Account (reverse sense)
  IF (_p.cmhead_freight <> 0) THEN
    _roundedBase := round(currToBase(_p.cmhead_curr_id, _p.cmhead_freight, _p.cmhead_docdate), 2);
    SELECT insertIntoGLSeries( _glSequence, 'A/R', 'CM', _p.cmhead_number,
                               getPrjAccntId(_p.cmhead_prj_id, accnt_id),
                               _roundedBase,
                               _glDate, ('Void-' || _p.cmhead_billtoname) ) INTO _test
    FROM accnt
    WHERE (accnt_id=findFreightAccount(_p.cmhead_cust_id));

--  If the Freight Charges Account was not found then punt
    IF (NOT FOUND) THEN
      PERFORM deleteGLSeries(_glSequence);
      IF (_test < 0) THEN
        RETURN _test;
      ELSE
        RAISE EXCEPTION 'Failed to create GL entry, no record found for accnt_id % [xtuple: voidCreditMemo, -8, %]',
          findFreightAccount(_p.cmhead_cust_id), findFreightAccount(_p.cmhead_cust_id);
      END IF;
    END IF;

--  Cache the Amount Distributed to Freight
    _totalAmount := _totalAmount + _p.cmhead_freight;
    _totalRoundedBase := _totalRoundedBase + _roundedBase;
  END IF;

  _totalAmount := _totalAmount;

--  Credit the A/R for the total Amount (reverse sense)
  IF (_totalAmount <> 0) THEN
    IF (_p.ar_accnt_id != -1) THEN
      SELECT insertIntoGLSeries( _glSequence, 'A/R', 'CM', _p.cmhead_number,
                                 _p.ar_accnt_id,
                                 (_totalRoundedBase * -1.0),
                                 _glDate, ('Void-' || _p.cmhead_billtoname) ) INTO _test;
    ELSE
      PERFORM deleteGLSeries(_glSequence);
      IF (_test < 0) THEN
        RETURN _test;
      ELSE
        RAISE EXCEPTION 'Failed to create GL entry for accnt_id % [xtuple: voidCreditMemo, -9, %]',
          _p.ar_accnt_id, _p.ar_accnt_id;
      END IF;
    END IF;
  END IF;

--  Commit the GLSeries;
  SELECT postGLSeries(_glSequence, _glJournal) INTO _test;
  IF (_test < 0) THEN
    PERFORM deleteGLSeries(_glSequence);
    RETURN _test;
  END IF;

--  Delete sales history
  DELETE FROM cohisttax
  WHERE (taxhist_parent_id IN (SELECT cohist_id
                               FROM cohist
                               WHERE (cohist_doctype='C' AND cohist_ordernumber=_p.cmhead_number)));

  DELETE FROM cohist
  WHERE (cohist_doctype='C' AND cohist_ordernumber=_p.cmhead_number);

--  Delete the Invoice aropen item
  DELETE FROM aropen
  WHERE (aropen_doctype='C' AND aropen_docnumber=_p.cmhead_number);

-- Handle the Inventory and G/L Transactions for any returned Inventory where cmitem_updateinv is true (reverse sense)
  FOR _r IN SELECT cmhead_id, cmitem_itemsite_id AS itemsite_id, cmitem_id,
                   (cmitem_qtyreturned * cmitem_qty_invuomratio) AS qty,
                   cmhead_number, cmhead_cust_id AS cust_id, item_number,
                   cmhead_prj_id AS prj_id, cmhead_saletype_id AS saletype_id,
                   cmhead_shipzone_id AS shipzone_id, isControlledItemsite(cmitem_itemsite_id) AS controlled
            FROM cmhead, cmitem, itemsite, item
            WHERE ( (cmitem_cmhead_id=cmhead_id)
             AND (cmitem_itemsite_id=itemsite_id)
             AND (itemsite_item_id=item_id)
             AND (cmitem_qtyreturned <> 0)
             AND (cmitem_updateinv)
             AND (cmhead_id=_p.cmhead_id) )
            ORDER BY cmitem_id LOOP

--  Return credited stock to inventory
    SELECT postInvTrans( itemsite_id, 'RS', (_r.qty * -1),
                         'S/O', 'CM', _r.cmhead_number, '',
                         ('Credit Voided ' || _r.item_number),
                         costcat_asset_accnt_id,
                         getPrjAccntId(_r.prj_id, resolveCOSAccount(itemsite_id, _r.cust_id, _r.saletype_id, _r.shipzone_id)),
                         _itemlocSeries, _glDate, NULL, NULL, NULL, pPreDistributed,
                         _r.cmhead_id, _r.cmitem_id) INTO _invhistid
    FROM itemsite, costcat
    WHERE ( (itemsite_costcat_id=costcat_id)
     AND (itemsite_id=_r.itemsite_id) );

    IF (NOT FOUND) THEN
      RAISE EXCEPTION 'Could not post inventory transaction: no cost category found for
        itemsite_id % [xtuple: voidCreditMemo, -2, %]', _r.itemsite_id, _r.itemsite_id;
    END IF;

    IF (_r.controlled) THEN
      _hasControlledItems := TRUE;
    END IF;

  END LOOP;

--  Update coitem to reflect the returned qty where cmitem_updateinv is true (reverse sense)
  FOR _r IN SELECT cmitem_qtyreturned, cmitem_itemsite_id, cohead_id
            FROM cmitem, cmhead, invchead, cohead
            WHERE ( (cmitem_cmhead_id=cmhead_id)
             AND (cmhead_invcnumber=invchead_invcnumber)
             AND (invchead_ordernumber=cohead_number)
             AND (cmitem_qtyreturned <> 0)
             AND (cmitem_updateinv)
             AND (cmhead_id=_p.cmhead_id) ) LOOP
    UPDATE coitem
    SET coitem_qtyreturned = (coitem_qtyreturned + (_r.cmitem_qtyreturned * -1.0))
    WHERE coitem_id IN ( SELECT coitem_id
                         FROM coitem
                         WHERE ( (coitem_cohead_id=_r.cohead_id)
                          AND (coitem_itemsite_id = _r.cmitem_itemsite_id) )
                         LIMIT 1 );
  END LOOP;

--  Mark the cmhead as voided
  UPDATE cmhead
  SET cmhead_void=TRUE
  WHERE (cmhead_id=_p.cmhead_id);

  IF (pPreDistributed) THEN
    IF (postDistDetail(_itemlocSeries) <= 0 AND _hasControlledItems) THEN
      RAISE EXCEPTION 'Posting Distribution Detail Returned 0 Results [xtuple: voidCreditMemo, -6]';
    END IF;
  END IF;

  RETURN _itemlocSeries;

END;
$$ LANGUAGE plpgsql;

