CREATE OR REPLACE FUNCTION isdate(s varchar)
RETURNS boolean AS $$
BEGIN
  PERFORM s::date;
  RETURN true;
EXCEPTION WHEN others THEN
  RETURN false;
END;
$$ language plpgsql;

