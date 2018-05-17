DROP TYPE IF EXISTS checkdata CASCADE;
CREATE TYPE checkdata AS (
        checkdata_page integer,
        checkdata_checknumber text,
        checkdata_checkwords text,
        checkdata_checkdate text,
        checkdata_checkamount text,
        checkdata_checkcurrsymbol text,
        checkdata_checkcurrabbr text,
        checkdata_checkcurrname text,
        checkdata_checkpayto text,
        checkdata_checkaddress text,
        checkdata_checkmemo text,
        checkdata_docnumber text,
        checkdata_docreference text,
        checkdata_docdate text,
        checkdata_docamount text,
        checkdata_docdiscount text,
        checkdata_docnetamount text
);
