DROP FUNCTION IF EXISTS araging(date);
DROP FUNCTION IF EXISTS araging(date, boolean);

CREATE OR REPLACE FUNCTION araging(pAsOfDate DATE, pUseDocDate BOOLEAN, pConvBaseCurr BOOLEAN DEFAULT true) RETURNS SETOF araging AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
-- @param pConvBaseCurr if true then convert all amounts to base currency using aropen_docdate to ensure the same exchange rate
--                      if false then convert to the customer's currency using aropen_docdate to ensure the same exchange rate
DECLARE
  _row       araging%ROWTYPE;
  _asOfDate  DATE := COALESCE(pAsOfDate,current_date);
BEGIN

  FOR _row IN
    SELECT aropen_docdate   AS araging_docdate,
           aropen_duedate   AS araging_duedate,
           aropen_ponumber  AS araging_ponumber,
           aropen_docnumber AS araging_docnumber,
           aropen_doctype   AS araging_doctype,
           cust_id          AS araging_cust_id,
           cust_number      AS araging_cust_number,
           cust_name        AS araging_cust_name,
           cust_custtype_id AS araging_cust_custtype_id,
           custtype_code    AS araging_custtype_code,
           terms_descrip    AS araging_terms_descrip,
           aropen_amount    AS araging_aropen_amount,

           --today and greater:
           CASE WHEN((aropen_duedate >= DATE(_asOfDate))) THEN balance
                ELSE 0.0 END AS araging_cur_val,

           --0 to 30
           CASE WHEN((aropen_duedate >= DATE(_asOfDate)-30) AND (aropen_duedate < DATE(_asOfDate))) THEN balance
                ELSE 0.0 END AS araging_thirty_val,

           --30-60
           CASE WHEN((aropen_duedate >= DATE(_asOfDate)-60) AND (aropen_duedate < DATE(_asOfDate) - 30 )) THEN balance
                ELSE 0.0 END AS araging_sixty_val,

           --60-90
           CASE WHEN((aropen_duedate >= DATE(_asOfDate)-90) AND (aropen_duedate < DATE(_asOfDate) - 60)) THEN balance
                ELSE 0.0 END AS araging_ninety_val,

           --greater than 90:
           CASE WHEN((aropen_duedate > DATE(_asOfDate)-10000) AND (aropen_duedate < DATE(_asOfDate) - 90)) THEN balance
                ELSE 0.0 END AS araging_plus_val,

           --total amount:
           CASE WHEN((aropen_duedate > DATE(_asOfDate)-10000)) THEN balance
                ELSE 0.0 END AS araging_total_val

      FROM (SELECT
          (((aropen_amount - aropen_paid + COALESCE(SUM(arapply_target_paid),0))) /
             CASE WHEN (pConvBaseCurr) THEN aropen_curr_rate
                  ELSE currRate(aropen_curr_id, cust_curr_id, aropen_docdate)
             END *
             CASE WHEN (aropen_doctype IN ('C', 'R')) THEN -1.0
                  ELSE 1.0
             END) AS balance,
          ((aropen_amount) /
             CASE WHEN (pConvBaseCurr) THEN aropen_curr_rate
                  ELSE currRate(aropen_curr_id, cust_curr_id, aropen_docdate)
             END *
             CASE WHEN (aropen_doctype IN ('C', 'R')) THEN -1.0
                  ELSE 1.0
             END) AS aropen_amount,
          aropen_docdate,
          aropen_duedate,
          aropen_ponumber,
          aropen_docnumber,
          aropen_doctype,
          cust_id,
          cust_name,
          cust_number,
          cust_custtype_id,
          custtype_code,
          COALESCE(arterms.terms_descrip, custterms.terms_descrip, '') AS terms_descrip

            FROM aropen
            JOIN custinfo ON cust_id     = aropen_cust_id
            JOIN custtype ON custtype_id = cust_custtype_id
            LEFT OUTER JOIN terms arterms   ON arterms.terms_id   = aropen_terms_id
            LEFT OUTER JOIN terms custterms ON custterms.terms_id = cust_terms_id
            LEFT OUTER JOIN arapply ON aropen_id IN (arapply_target_aropen_id, arapply_source_aropen_id)
                                     AND arapply_distdate > _asOfDate
           WHERE CASE WHEN pUseDocDate THEN aropen_docdate
                      ELSE aropen_distdate END <= _asOfDate
             AND COALESCE(aropen_closedate, _asOfDate+1) > _asOfDate
          GROUP BY aropen_id, aropen_docdate, aropen_duedate, aropen_ponumber,
                   aropen_docnumber, aropen_doctype, aropen_paid, 
                   aropen_curr_id, aropen_amount, cust_id, cust_name,
                   cust_number, cust_custtype_id, custtype_code, 
                   arterms.terms_descrip, custterms.terms_descrip,
                  aropen_curr_rate, aropen_curr_id, cust_curr_id
          ORDER BY cust_number, aropen_duedate ) AS data
  LOOP
    RETURN NEXT _row;
  END LOOP;
  RETURN;
END;
$$ LANGUAGE plpgsql;
