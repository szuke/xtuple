DO $$
BEGIN

  IF EXISTS (SELECT 1
               FROM pg_class
               JOIN pg_namespace ON relnamespace=pg_namespace.oid
              WHERE pg_class.relname='dict'
                AND pg_namespace.nspname='xt') THEN
    IF EXISTS (SELECT 1
               FROM pg_class
               JOIN pg_namespace ON relnamespace=pg_namespace.oid
              WHERE pg_class.relname='dictobsolete'
                AND pg_namespace.nspname='xt') THEN
      INSERT INTO xt.dictobsolete
      (dict_id, dict_language_name, dict_ext_id, dict_is_database, dict_is_framework,
       dict_usr_username, dict_date, dict_strings)
      SELECT dict_id, dict_language_name, dict_ext_id, dict_is_database, dict_is_framework,
      dict_usr_username, dict-date, dict_strings
        FROM xt.dict;
    ELSE
      CREATE TABLE xt.dictobsolete AS
      SELECT dict_id, dict_language_name, dict_ext_id, dict_is_database, dict_is_framework,
       dict_usr_username, dict_date, dict_strings
        FROM xt.dict;
    END IF;

    DROP TABLE xt.dict;
  END IF;

END;
$$ LANGUAGE plpgsql;
