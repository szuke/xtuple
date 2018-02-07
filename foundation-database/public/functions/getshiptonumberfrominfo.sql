
CREATE OR REPLACE FUNCTION getShipToNumberFromInfo(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, BOOLEAN, BOOLEAN) RETURNS TEXT AS $$
-- Copyright (c) 1999-2014 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _custname TEXT := COALESCE(TRIM(UPPER( $1)), '');
  _email TEXT 	 := COALESCE(TRIM(UPPER( $2)), '');
  _company TEXT  := COALESCE(TRIM(UPPER( $3)), '');
  _first TEXT 	 := COALESCE(TRIM(UPPER( $4)), '');
  _last TEXT 	 := COALESCE(TRIM(UPPER( $5)), '');
  _fullname TEXT := COALESCE(TRIM(UPPER( $6)), '');
  _addr1 TEXT 	 := COALESCE(TRIM(UPPER( $7)), '');
  _addr2 TEXT 	 := COALESCE(TRIM(UPPER( $8)), '');
  _addr3 TEXT 	 := COALESCE(TRIM(UPPER( $9)), '');
  _city TEXT 	 := COALESCE(TRIM(UPPER($10)), '');
  _state TEXT 	 := COALESCE(TRIM(UPPER($11)), '');
  _postalcode TEXT := COALESCE(TRIM(UPPER($12)), '');
  _country TEXT  := COALESCE(TRIM(UPPER($13)), '');
  _generate BOOLEAN := COALESCE($14, FALSE);
  _create BOOLEAN := COALESCE($15, FALSE);

  _citytrunc TEXT;
  _counter INTEGER;
  _custid INTEGER;
  _custnumber TEXT;
  _candidate TEXT;
  _r RECORD;
  _statetrunc TEXT;
BEGIN
  IF (_custname = '') THEN
    _custname := getCustNameFromInfo(_email, _company, _first, _last,
                     _fullname, FALSE);
  END IF;

  SELECT shipto_num INTO _candidate
  FROM
  (SELECT DISTINCT first_value(shipto_num) OVER (PARTITION BY namematch) AS shipto_num, namematch,
                   COUNT(*) OVER (PARTITION BY namematch) AS count
     FROM
   (SELECT shipto_num, UPPER(shipto_name)=UPPER(_fullname) AS namematch
      FROM shiptoinfo
      JOIN custinfo ON shipto_cust_id=cust_id
      JOIN addr ON shipto_addr_id=addr_id
      WHERE UPPER(cust_name)=UPPER(_custname)
        AND (COALESCE(shipto_name, '')='' OR COALESCE(_fullname, '')=''
             OR UPPER(shipto_name)=UPPER(_fullname))
        AND (COALESCE(addr_country, '')='' OR COALESCE(_country, '')=''
             OR UPPER(addr_country)=UPPER(_country))
        AND (COALESCE(addr_state, '')='' OR COALESCE(_state, '')=''
             OR UPPER(addr_state)=UPPER(_state))
        AND (COALESCE(addr_city, '')='' OR COALESCE(_city, '')=''
             OR UPPER(addr_city)=UPPER(_city))
        AND (COALESCE(addr_postalcode, '')='' OR COALESCE(_postalcode, '')=''
             OR UPPER(addr_postalcode)=UPPER(_postalcode))
        AND (COALESCE(addr_line1, '')='' OR COALESCE(_addr1, '')=''
             OR UPPER(addr_line1)=UPPER(_addr1))
        AND (COALESCE(addr_line2, '')='' OR COALESCE(_addr2, '')=''
             OR UPPER(addr_line2)=UPPER(_addr2))
        AND (COALESCE(addr_line3, '')='' OR COALESCE(_addr3, '')=''
             OR UPPER(addr_line3)=UPPER(_addr3))
   ) sub
  ) sub2
  WHERE count=1
  ORDER BY namematch desc
  LIMIT 1;

  IF (FOUND) THEN
    RETURN _candidate;
  END IF;

  IF (_generate) THEN
    SELECT cust_number, cust_id INTO _custnumber, _custid
    FROM custinfo
    WHERE (UPPER(cust_name)=_custname);

    -- keep the number short
    _citytrunc := SUBSTRING(_city FOR 5);
    _statetrunc := SUBSTRING(_state FOR 5);

    IF (LENGTH(_citytrunc) > 0 AND NOT EXISTS(SELECT UPPER(shipto_num)
              FROM shiptoinfo
              WHERE ((shipto_cust_id=_custid)
                AND (UPPER(shipto_num)=_citytrunc)) )) THEN
      _candidate := _citytrunc;
    ELSIF (LENGTH(_last || _citytrunc) > 0 AND NOT EXISTS(SELECT UPPER(shipto_num)
              FROM shiptoinfo
              WHERE ((shipto_cust_id=_custid)
                AND (UPPER(shipto_num)=_last || _citytrunc)) )) THEN
      _candidate := _last || _citytrunc;
    ELSIF (LENGTH(_statetrunc) > 0 AND NOT EXISTS(SELECT UPPER(shipto_num)
           FROM shiptoinfo
           WHERE ((shipto_cust_id=_custid)
             AND (UPPER(shipto_num)=_statetrunc)) )) THEN
      _candidate := _statetrunc;
    ELSIF (LENGTH(_last || _statetrunc) > 0 AND NOT EXISTS(SELECT UPPER(shipto_num)
           FROM shiptoinfo
           WHERE ((shipto_cust_id=_custid)
             AND (UPPER(shipto_num)=_last || _statetrunc)) )) THEN
      _candidate := _last || _statetrunc;

    ELSIF (LENGTH(_citytrunc || _statetrunc) > 0 AND NOT EXISTS(SELECT UPPER(shipto_num)
              FROM shiptoinfo
              WHERE ((shipto_cust_id=_custid)
                AND (UPPER(shipto_num)=_citytrunc || _statetrunc)) )) THEN
      _candidate := _citytrunc || _statetrunc;

    ELSE
      SELECT CAST(COALESCE(MAX(CAST(shipto_num AS INTEGER)), 0) + 1 AS TEXT)
      INTO _candidate
      FROM shiptoinfo
      WHERE ((shipto_cust_id=_custid)
       AND (shipto_num~'^[0-9]*$'));
    END IF;

    IF (_create) THEN
      INSERT INTO api.custshipto (
    customer_number, shipto_number, name,
    address1, address2, address3,
    city, state, postal_code, country, address_change,
    first, last, email,
    edi_profile
      ) VALUES (
    _custnumber, _candidate, _candidate,
    _addr1, _addr2, _addr3,
    _city, _state, _postalcode, _country, 'CHANGEONE',
    _first, _last, LOWER(_email),
    'No EDI'
      );
    END IF;

    RETURN _candidate;
  END IF;

  RETURN '';
END;
$$ LANGUAGE 'plpgsql';
