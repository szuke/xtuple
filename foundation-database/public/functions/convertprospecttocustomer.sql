DROP FUNCTION IF EXISTS convertProspectToCustomer(INTEGER);
DROP FUNCTION IF EXISTS convertProspectToCustomer(INTEGER, BOOLEAN);

CREATE OR REPLACE FUNCTION convertProspectToCustomer(pProspectId INTEGER,
                                                     pdoquotes   BOOLEAN DEFAULT FALSE)
RETURNS INTEGER AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _p          RECORD;
  _q          RECORD;

BEGIN
  SELECT * INTO _p
  FROM prospect
  WHERE prospect_id = pProspectId;

  IF EXISTS(SELECT 1 FROM custinfo WHERE cust_id = pProspectId) THEN
    RAISE EXCEPTION 'Cannot convert prospect % as there is already a customer with the same id [xtuple: convertProspectToCustomer, -10, %]',
                    _p.prospect_number, _p.prospect_number;
  END IF;

  INSERT INTO custinfo (
    cust_id,
    cust_active,
    cust_number,
    cust_name,
    cust_cntct_id,
    cust_taxzone_id,
    cust_comments,
    cust_creditstatus,
    cust_salesrep_id,
    cust_preferred_warehous_id,
    cust_terms_id,
    cust_custtype_id,
    cust_shipform_id,
    cust_shipvia,
    cust_balmethod,
    cust_ffshipto,
    cust_backorder,
    cust_partialship,
    cust_creditlmt,
    cust_creditrating,
    cust_commprcnt,
    cust_discntprcnt,
    cust_blanketpos,
    cust_shipchrg_id,
    cust_ffbillto,
    cust_usespos,
    cust_autoupdatestatus,
    cust_autoholdorders
  )
  SELECT
    _p.prospect_id,
    _p.prospect_active,
    _p.prospect_number,
    _p.prospect_name,
    _p.prospect_cntct_id,
    _p.prospect_taxzone_id,
    _p.prospect_comments,
    'G',
    salesrep_id,
    COALESCE(_p.prospect_warehous_id, -1),
    FetchMetricValue('DefaultTerms'),
    FetchMetricValue('DefaultCustType'),
    FetchMetricValue('DefaultShipFormId'),
    COALESCE(FetchDefaultShipVia(),''),
    FetchMetricText('DefaultBalanceMethod'),
    FetchMetricBool('DefaultFreeFormShiptos'),
    FetchMetricBool('DefaultBackOrders'),
    FetchMetricBool('DefaultPartialShipments'),
    FetchMetricValue('SOCreditLimit'),
    FetchMetricText('SOCreditRate'),
    salesrep_commission,
    0,
    false,
    COALESCE(FetchMetricValue('DefaultShipChrgId'), -1),
    fetchMetricBool('DefaultFreeFormBilltos'),
    false,
    false,
    false
    FROM salesrep
   WHERE salesrep_id = COALESCE(_p.prospect_salesrep_id, FetchMetricValue('DefaultSalesRep'));

  DELETE FROM prospect WHERE prospect_id = pProspectId;

  IF pdoquotes THEN
    BEGIN
      FOR _q IN SELECT quhead_number, convertQuote(quhead_id) AS err
                  FROM quhead
                 WHERE ((COALESCE(quhead_expire, endOfTime()) >= CURRENT_DATE)
                    AND (quhead_cust_id=pProspectId)) LOOP
        IF (_q.err < 0) THEN
          RAISE WARNING 'Quote % for % didn''t convert to a Sales Order [xtuple: convertQuote, %]',
                       _q.quhead_number, _p.prospect_number, _q.err;
        END IF;
      END LOOP;
    EXCEPTION WHEN OTHERS THEN
      RAISE WARNING 'Ignored errors converting quotes: % %', SQLSTATE, SQLERRM;
    END;
  END IF;

  RETURN pProspectId;
END;
$$ LANGUAGE plpgsql;
