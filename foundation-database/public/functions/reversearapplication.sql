CREATE OR REPLACE FUNCTION reversearapplication(papplyid integer)
  RETURNS integer AS $$
DECLARE
  _r	RECORD;
  _paid	NUMERIC;
  _round NUMERIC := 0.01;
  _newDocNum TEXT;
BEGIN

  SELECT arapply_cust_id,
         arapply_postdate,
         arapply_target_aropen_id, 
         arapply_target_docnumber, 
         arapply_target_doctype, 
         arapply_source_aropen_id,
         arapply_source_docnumber, 
         arapply_refnumber,
         arapply_fundstype,
         arapply_source_doctype, 
         arapply_curr_id,
         arapply_applied AS aamt, 
         arapply_target_paid AS pamt,
         arapply_reversed 
  INTO _r
  FROM arapply 
  WHERE arapply_id = papplyid;

-- Creates test to not allow to over unapply
  _paid := (SELECT aropen_paid
         FROM aropen 
         WHERE aropen_id = _r.arapply_target_aropen_id);

  IF ((_paid + _round) < _r.aamt) THEN
    RAISE EXCEPTION 'Amount paid is less than the applied amount [xtuple: reversearapplication, -1]';
  END IF;

  IF (_r.arapply_reversed) THEN
    RAISE EXCEPTION 'This application has already been reversed [xtuple: reversearapplication, -2]';
  END IF;  

  INSERT INTO arapply (arapply_cust_id,
                       arapply_postdate,
                       arapply_distdate,
                       arapply_username,
                       arapply_target_aropen_id, 
                       arapply_target_docnumber, 
                       arapply_target_doctype, 
                       arapply_source_aropen_id,
                       arapply_source_docnumber, 
                       arapply_refnumber,
                       arapply_fundstype,
                       arapply_source_doctype, 
                       arapply_curr_id,
                       arapply_applied,
                       arapply_target_paid)
  VALUES (_r.arapply_cust_id,
          _r.arapply_postdate,
          current_date,
          geteffectivextuser(),
          _r.arapply_target_aropen_id, 
          _r.arapply_target_docnumber, 
          _r.arapply_target_doctype, 
          _r.arapply_source_aropen_id,
          _r.arapply_source_docnumber, 
          _r.arapply_refnumber,
          _r.arapply_fundstype,
          _r.arapply_source_doctype, 
          _r.arapply_curr_id,
          _r.aamt * -1,
          _r.pamt * -1);

  UPDATE aropen SET aropen_paid = aropen_paid - _r.aamt 
  WHERE (aropen_id = _r.arapply_source_aropen_id
     OR  aropen_id = _r.arapply_target_aropen_id);

  UPDATE aropen SET aropen_open = true, aropen_closedate = NULL
  WHERE aropen_amount != aropen_paid 
  AND  (aropen_id = _r.arapply_source_aropen_id
   OR   aropen_id = _r.arapply_target_aropen_id);

-- Determine new Document Number and check for duplicates
  _newDocNum := COALESCE(NULLIF(_r.arapply_refnumber, ''), _r.arapply_source_docnumber);
  WHILE (EXISTS(SELECT 1 FROM aropen WHERE aropen_docnumber = _newDocNum)) LOOP
    _newDocNum := trim(regexp_replace(_newDocNum, '\[REV\]', '', 'g')) || ' [REV]';
  END LOOP;  

  IF (_r.arapply_source_doctype = 'K') THEN
    INSERT INTO aropen(
            aropen_docdate, aropen_duedate,  aropen_cust_id,
            aropen_doctype, aropen_docnumber,
            aropen_amount, aropen_curr_rate, aropen_curr_id,
            aropen_notes,
             aropen_ponumber,
             aropen_paid, aropen_open, aropen_username,
            aropen_discount, aropen_accnt_id,
            aropen_distdate
            )
    VALUES (_r.arapply_postdate, current_date, _r.arapply_cust_id,
            'C', _newDocNum,
            _r.aamt, currrate(_r.arapply_curr_id, _r.arapply_postdate), _r.arapply_curr_id,
             'Payment ' || _r.arapply_source_docnumber || _r.arapply_refnumber || ' to be re-applied; original date: ' || _r.arapply_postdate,
            '', 0, true, geteffectivextuser(), false, -1,
            current_date);
  END IF;

  UPDATE arapply SET arapply_reversed = true
  WHERE arapply_id = papplyid;

  RETURN 0;

END;
$$ LANGUAGE plpgsql;
