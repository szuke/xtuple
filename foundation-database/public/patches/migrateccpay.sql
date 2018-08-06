DO $$
DECLARE
  _r RECORD;
  _resultcashrcpt INTEGER;
  _resultccpay INTEGER;
  _ccpays INTEGER[];
  _foundcashrcpts INTEGER[];
  _foundccpays INTEGER[];
  _cashrcpt RECORD;
  _ccpay INTEGER;

BEGIN

  -- Try to match existing cash receipts and ccpays as well as possible
  -- The old way is to compare order number with doc number and match customer
  -- If only one match is found this way, use it, otherwise, do the best we can
  -- In almost all cases it should be a simple match, the rest is just in case
  FOR _r IN SELECT CASE WHEN TRIM(COALESCE(cashrcpt_docnumber, ''))=''
                        THEN TEXT(cashrcpt_id)
                        ELSE cashrcpt_docnumber END AS docnumber,
                   cashrcpt_cust_id,
                   array_agg(cashrcpt_id) AS ids
              FROM cashrcpt
             WHERE isExternalFundsType(cashrcpt_fundstype)
               AND cashrcpt_ccpay_id IS NULL
             GROUP BY docnumber, cashrcpt_cust_id
  LOOP
    IF array_length(_r.ids, 1)=1 THEN
      -- Only one cashrcpt. Pick a matching ccpay by following priority:
      -- 3. Matching currency and amount (bitmask 11)
      -- 2. Matching currency only (bitmask 10)
      -- 1. Matching amount (bitmask 01)
      -- 0. Any (bitmask 00)
      -- When choosing among these, try to match based on creation time, approximated
      -- by cashrcpt_id for cashrcpt and done by ccpay_transaction_datetime followed by ccpay_id
      -- for ccpay
      UPDATE cashrcpt
         SET cashrcpt_ccpay_id=(SELECT ccpay_id
                                  FROM (SELECT ccpay_id,
                                        CASE WHEN ccpay_amount=cashrcpt_amount
                                                  OR ccpay_status!='C'
                                             THEN 1
                                             ELSE 0
                                              END +
                                        CASE WHEN ccpay_curr_id=cashrcpt_curr_id
                                             THEN 2 
                                             ELSE 0
                                              END AS match
                                          FROM ccpay
                                         WHERE ccpay_type='C'
                                           AND ccpay_id NOT IN (SELECT payco_ccpay_id FROM payco)
                                           AND ccpay_order_number=_r.docnumber
                                           AND ccpay_cust_id=_r.cashrcpt_cust_id
                                         ORDER BY match DESC,
                                         ccpay_transaction_datetime, ccpay_id) ordered
                                 LIMIT 1)
       WHERE cashrcpt_id=_r.ids[1]
       RETURNING cashrcpt_id, cashrcpt_ccpay_id
            INTO _resultcashrcpt, _resultccpay;

       _foundcashrcpts := _foundcashrcpts || _resultcashrcpt;
       _foundccpays := _foundccpays || _resultccpay;
    ELSE
      -- Multiple cash rcecipts. Grab all cash receipts and ccpays with this number and try
      -- to match them based on amount, currency, and order as above
      _ccpays := ARRAY(SELECT ccpay_id
                         FROM ccpay
                        WHERE ccpay_type='C'
                          AND ccpay_id NOT IN (SELECT payco_ccpay_id FROM payco)
                          AND ccpay_order_number=_r.docnumber
                          AND ccpay_cust_id=_r.cashrcpt_cust_id
                        ORDER BY ccpay_transaction_datetime, ccpay_id);

      FOR _cashrcpt IN SELECT cashrcpt_id, cashrcpt_amount, cashrcpt_curr_id,
                             generate_series(3, 0, -1) AS match
                        FROM cashrcpt
                       WHERE cashrcpt_id IN (SELECT UNNEST(_r.ids))
                       ORDER BY match DESC, cashrcpt_id
      LOOP
        IF (_cashrcpt.cashrcpt_id NOT IN (SELECT UNNEST(_foundcashrcpts))) THEN
          FOREACH _ccpay IN ARRAY _ccpays
          LOOP
            IF ((SELECT ((_cashrcpt.match & 2)!=0 OR ccpay_curr_id=_cashrcpt.cashrcpt_curr_id)
                    AND ((_cashrcpt.match & 1)!=0 OR ccpay_amount=_cashrcpt.cashrcpt_amount)
                   FROM ccpay
                  WHERE ccpay_id=_ccpay)
                AND _ccpay NOT IN (SELECT UNNEST(_foundccpays))) THEN
              UPDATE cashrcpt
                 SET cashrcpt_ccpay_id = _ccpay
               WHERE cashrcpt_id = _cashrcpt.cashrcpt_id;

              _foundcashrcpts := _foundcashrcpts || _cashrcpt.cashrcpt_id;
              _foundccpays    := _foundccpays    || _ccpay;

              EXIT;
            END IF;
          END LOOP;
        END IF;
      END LOOP;
    END IF;
  END LOOP;

END;
$$ LANGUAGE plpgsql;
