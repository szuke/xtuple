CREATE OR REPLACE FUNCTION canProcessPaymentGatewayTransaction(
  pCcardId integer,
  pCurrId integer
) RETURNS boolean AS
$BODY$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _currentAccntPeriod RECORD;
  _custCardAccnt RECORD;
  _taxCodeAccnt RECORD;

BEGIN

  SELECT
    cust_id,
    cust_number,
    cust_taxzone_id,
    ccard_id,
    ccard_type,
    bankaccnt_name,
    ccbank_ccard_type IS NOT NULL AS card_has_ccbank,
    bankaccnt_id IS NOT NULL AS ccbank_has_bankaccnt,
    bankaccnt_accnt_id IS NOT NULL AS bankaccnt_has_glaccnt,
    accntIsValid(bankaccnt_accnt_id) AS bankaccnt_glaccnt_is_valid,
    findARAccount(cust_id) > 0 AS cust_has_ar_glaccnt,
    accntIsValid(findARAccount(cust_id)) AS ar_glaccnt_is_valid,
    findPrepaidAccount(cust_id) > 0 AS cust_has_prepaid_glaccnt,
    accntIsValid(findPrepaidAccount(cust_id)) AS prepaid_glaccnt_is_valid,
    findDeferredAccount(cust_id) > 0 AS cust_has_deferred_glaccnt,
    accntIsValid(findDeferredAccount(cust_id)) AS deferred_glaccnt_is_valid,
    CASE WHEN NOT fetchmetricbool('IgnoreCompany')
      THEN (bankaccnt_accnt.accnt_company IS NOT DISTINCT FROM ar_accnt.accnt_company)
      ELSE TRUE
    END AS ar_glaccnt_same_company,
    CASE WHEN NOT fetchmetricbool('IgnoreCompany')
      THEN (bankaccnt_accnt.accnt_company IS NOT DISTINCT FROM prepaid_accnt.accnt_company)
      ELSE TRUE
    END AS prepaid_glaccnt_same_company,
    CASE WHEN NOT fetchmetricbool('IgnoreCompany')
      THEN (bankaccnt_accnt.accnt_company IS NOT DISTINCT FROM deferred_accnt.accnt_company)
      ELSE TRUE
    END AS deferred_glaccnt_same_company,
    CASE WHEN COALESCE(fetchMetricValue('GLCompanySize'), 0) = 0
      THEN accntIsValid(fetchMetricValue('GLSeriesDiscrepancyAccount')::integer)
      ELSE accntIsValid(company_dscrp_accnt_id)
    END AS discrep_accnt_is_valid,
    CASE WHEN COALESCE(fetchMetricValue('GLCompanySize'), 0) = 0
      THEN accntIsValid(fetchMetricValue('UnassignedAccount')::integer)
      ELSE accntIsValid(company_unassigned_accnt_id)
    END AS unassigned_accnt_is_valid
    INTO _custCardAccnt
    FROM ccard
    JOIN custinfo ON ccard_cust_id = cust_id
    LEFT JOIN ccbank ON ccard_type = ccbank_ccard_type
    LEFT JOIN bankaccnt ON ccbank_bankaccnt_id = bankaccnt_id
    LEFT JOIN accnt AS bankaccnt_accnt ON bankaccnt_accnt_id = bankaccnt_accnt.accnt_id
    LEFT JOIN accnt AS ar_accnt ON ar_accnt.accnt_id = findARAccount(cust_id)
    LEFT JOIN accnt AS prepaid_accnt ON prepaid_accnt.accnt_id = findPrepaidAccount(cust_id)
    LEFT JOIN accnt AS deferred_accnt ON deferred_accnt.accnt_id = findDeferredAccount(cust_id)
    LEFT JOIN company ON bankaccnt_accnt.accnt_company = company_number
   WHERE ccard_id = pCcardId;

  IF (_custCardAccnt IS NULL) THEN
    RAISE EXCEPTION 'Invaid Customer or Payment Method. [xtuple: canProcessPaymentGatewayTransaction, -1]';
  END IF;
  IF (NOT _custCardAccnt.card_has_ccbank) THEN
    RAISE EXCEPTION 'Cannot find the default Bank Account for this Credit Card [xtuple: postCCcredit, -1, %]',
                    _custCardAccnt.ccard_type;
  END IF;
  IF (NOT _custCardAccnt.ccbank_has_bankaccnt) THEN
    RAISE EXCEPTION 'Payment Method Bank Account is not set up for ccard_type "%". [xtuple: canProcessPaymentGatewayTransaction, -2, %]',
                    _custCardAccnt.ccard_type,
                    _custCardAccnt.ccard_type;
  END IF;
  IF (NOT _custCardAccnt.bankaccnt_has_glaccnt) THEN
    RAISE EXCEPTION 'Payment Method Bank Account "%" does not have a G/L Account assigned. [xtuple: canProcessPaymentGatewayTransaction, -3, %]',
                    _custCardAccnt.bankaccnt_name,
                    _custCardAccnt.bankaccnt_name;
  END IF;
  IF (NOT _custCardAccnt.bankaccnt_glaccnt_is_valid) THEN
    RAISE EXCEPTION 'Payment Method Bank Account G/L Account "%" is not valid. [xtuple: canProcessPaymentGatewayTransaction, -4, %]',
                    _custCardAccnt.bankaccnt_name,
                    _custCardAccnt.bankaccnt_name;
  END IF;
  IF (NOT _custCardAccnt.cust_has_ar_glaccnt) THEN
    RAISE EXCEPTION 'Customer "%" does not have an A/R G/L Account assigned. [xtuple: canProcessPaymentGatewayTransaction, -5, %]',
                    _custCardAccnt.cust_number,
                    _custCardAccnt.cust_number;
  END IF;
  IF (NOT _custCardAccnt.ar_glaccnt_is_valid) THEN
    RAISE EXCEPTION 'Customer "%" A/R Account is not valid. [xtuple: canProcessPaymentGatewayTransaction, -6, %]',
                    _custCardAccnt.cust_number,
                    _custCardAccnt.cust_number;
  END IF;
  IF (NOT _custCardAccnt.cust_has_prepaid_glaccnt) THEN
    RAISE EXCEPTION 'Customer "%" does not have a Prepaid G/L Account assigned. [xtuple: canProcessPaymentGatewayTransaction, -7, %]',
                    _custCardAccnt.cust_number,
                    _custCardAccnt.cust_number;
  END IF;
  IF (NOT _custCardAccnt.prepaid_glaccnt_is_valid) THEN
    RAISE EXCEPTION 'Customer "%" Prepaid Account is not valid. [xtuple: canProcessPaymentGatewayTransaction, -8, %]',
                    _custCardAccnt.cust_number,
                    _custCardAccnt.cust_number;
  END IF;
  IF (NOT _custCardAccnt.cust_has_deferred_glaccnt) THEN
    RAISE EXCEPTION 'Customer "%" does not have a Deferred Revenue G/L Account assigned. [xtuple: canProcessPaymentGatewayTransaction, -9, %]',
                    _custCardAccnt.cust_number,
                    _custCardAccnt.cust_number;
  END IF;
  IF (NOT _custCardAccnt.deferred_glaccnt_is_valid) THEN
    RAISE EXCEPTION 'Customer "%" Deferred Revenue Account is not valid. [xtuple: canProcessPaymentGatewayTransaction, -10, %]',
                    _custCardAccnt.cust_number,
                    _custCardAccnt.cust_number;
  END IF;
  IF (NOT _custCardAccnt.ar_glaccnt_same_company) THEN
    RAISE EXCEPTION 'Payment Methods Bank Account and Customer A/R G/L Accounts are not for the same Company. [xtuple: canProcessPaymentGatewayTransaction, -11]';
  END IF;
  IF (NOT _custCardAccnt.prepaid_glaccnt_same_company) THEN
    RAISE EXCEPTION 'Payment Methods Bank Account and Customer Prepaid G/L Accounts are not for the same Company. [xtuple: canProcessPaymentGatewayTransaction, -12]';
  END IF;
  IF (NOT _custCardAccnt.deferred_glaccnt_same_company) THEN
    RAISE EXCEPTION 'Payment Methods Bank Account and Customer Deferred Revenue G/L Accounts are not for the same Company. [xtuple: canProcessPaymentGatewayTransaction, -13]';
  END IF;
  IF (NOT _custCardAccnt.discrep_accnt_is_valid) THEN
    RAISE EXCEPTION 'G/L Series Discrepancy Account is not set up. [xtuple: canProcessPaymentGatewayTransaction, -14]';
  END IF;
  IF (NOT _custCardAccnt.unassigned_accnt_is_valid) THEN
    RAISE EXCEPTION 'Unassigned G/L Account is not set up. [xtuple: canProcessPaymentGatewayTransaction, -15]';
  END IF;

  FOR _taxCodeAccnt IN
    SELECT
      tax_code,
      tax_sales_accnt_id IS NOT NULL AS tax_has_glaccnt,
      accntIsValid(tax_sales_accnt_id) AS tax_glaccnt_is_valid
      FROM taxass
      JOIN tax ON taxass_tax_id = tax_id
     WHERE taxass_taxzone_id = _custCardAccnt.cust_taxzone_id
  LOOP
    IF (NOT _taxCodeAccnt.tax_has_glaccnt) THEN
      RAISE EXCEPTION 'Tax Code "%" does not have a G/L Account assigned. [xtuple: canProcessPaymentGatewayTransaction, -16, %]',
                      _taxCodeAccnt.tax_code,
                      _taxCodeAccnt.tax_code;
    END IF;
    IF (NOT _taxCodeAccnt.tax_glaccnt_is_valid) THEN
      RAISE EXCEPTION 'Tax Code "%" G/L Account is not valid. [xtuple: canProcessPaymentGatewayTransaction, -17, %]',
                      _taxCodeAccnt.tax_code,
                      _taxCodeAccnt.tax_code;
    END IF;
  END LOOP;

  SELECT
    COALESCE(period_closed, FALSE) AS period_closed,
    (NOT checkPrivilege('PostFrozenPeriod') AND COALESCE(period_freeze, FALSE)) AS period_freeze
    INTO _currentAccntPeriod
    FROM period
   WHERE CURRENT_DATE BETWEEN period_start AND period_end;

  IF (_currentAccntPeriod IS NULL) THEN
    RAISE EXCEPTION 'Cannot post to nonexistent Accounting Period for "%". [xtuple: canProcessPaymentGatewayTransaction, -18, %]',
                    CURRENT_DATE, CURRENT_DATE;
  END IF;

  IF (_currentAccntPeriod.period_closed) THEN
    RAISE EXCEPTION 'Cannot post to a closed Accounting Period for "%". [xtuple: canProcessPaymentGatewayTransaction, -19, %]',
                    CURRENT_DATE, CURRENT_DATE;
  END IF;

  IF (_currentAccntPeriod.period_freeze) THEN
    RAISE EXCEPTION 'Cannot post to a frozen Accounting Period for "%". [xtuple: canProcessPaymentGatewayTransaction, -20, %]',
                    CURRENT_DATE, CURRENT_DATE;
  END IF;

  -- Will throw an error if the exchange rate is not set up.
  PERFORM currRate(pCurrId, baseCurrID(), CURRENT_DATE);

  RETURN true;

END;
$BODY$
  LANGUAGE plpgsql STABLE;
ALTER FUNCTION canProcessPaymentGatewayTransaction(integer, integer)
  OWNER TO admin;
