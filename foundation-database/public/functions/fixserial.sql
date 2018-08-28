/* splitting the functionality this way makes the parameter-less version
   slow but this should be run rarely. the ability to fix one table
   should make up for it.
   TODO: consider searching all columns that refer to a given sequence
         instead of searching by schema.table.
 */
CREATE OR REPLACE FUNCTION fixSerial(pTablename TEXT, pSchema TEXT) RETURNS BOOL AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _a    RECORD;
  _max  BIGINT;
  _curr BIGINT;
  _seq  TEXT[];

BEGIN
  -- _usually_ one iteration
  FOR _a IN SELECT attname,
                   TRIM(quote_literal('\"''') FROM
                        SUBSTRING(pg_catalog.pg_get_expr(d.adbin, d.adrelid)
                        FROM '[' || quote_literal('\"''') ||
                             '].*[' || quote_literal('\"''') || ' ]')) AS seq
              FROM pg_attribute a
              JOIN pg_class     c ON a.attrelid = c.oid
              JOIN pg_attrdef   d ON d.adrelid = a.attrelid AND d.adnum = a.attnum
              JOIN pg_namespace n ON relnamespace = n.oid
             WHERE attnum > 0
                AND NOT attisdropped
                AND attnotnull
                AND pg_get_expr(d.adbin, d.adrelid) ~* 'nextval'
                AND a.atthasdef
                AND relpersistence IN ('p', 'u')
                AND relkind != 'f'
                AND relname = pTablename
                AND nspname = pSchema
  LOOP
    EXECUTE format('SELECT max(%I) FROM %I.%I;', _a.attname, pSchema, pTablename)
       INTO _max;

    _seq := string_to_array(_a.seq, '.');
    IF array_length(_seq, 1) = 1 THEN
      SELECT ARRAY[ nspname, _a.seq ] INTO _seq
        FROM pg_namespace n
        JOIN pg_class ON n.oid = relnamespace
       WHERE relkind = 'S'
         AND relname = _a.seq;
    END IF;

    EXECUTE format('SELECT last_value FROM %I.%I;', _seq[1], _seq[2]) INTO _curr;

    IF _max > _curr THEN
      RAISE NOTICE 'Adjusting sequence % from % to %', _a.seq, _curr, _max;
      PERFORM setval(_a.seq, _max);
    END IF;
  END LOOP;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fixSerial() RETURNS BOOL AS $$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
  SELECT BOOL_AND(fixSerial(relname, nspname))
    FROM pg_class c
    JOIN pg_namespace n ON relnamespace = n.oid
   WHERE relkind = 'r'
     AND relpersistence IN ('p', 'u');
$$ LANGUAGE sql;
