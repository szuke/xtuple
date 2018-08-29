CREATE OR REPLACE FUNCTION getvoidcheckdate(
    pCheckNumber integer,
    pBankAccount integer)
  RETURNS date AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _voiddate DATE;

BEGIN

  _voiddate :=(SELECT CASE WHEN checkhead_void THEN gltrans_date 
                                               ELSE checkhead_checkdate END
                 FROM checkhead
                 JOIN bankaccnt ON bankaccnt_id = checkhead_bankaccnt_id
                 JOIN gltrans ON (gltrans_accnt_id = bankaccnt_accnt_id 
                                  AND gltrans_doctype = 'CK'
                                  AND checkhead_amount = (gltrans_amount * -1)
                                  AND gltrans_notes ~* 'Void Posted Check'
                                  AND gltrans_docnumber = checkhead_number::text)
                WHERE gltrans_posted
                  AND checkhead_number = pCheckNumber
                  AND bankaccnt_id = pBankAccount);

  RETURN _voiddate;

END;
$$ LANGUAGE plpgsql;
