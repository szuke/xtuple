SELECT xt.create_view('public.usr', $BODY$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/EULA for the full text of the software license.

  WITH default_locale AS (
    SELECT
      locale_id,
      NOT (lower(locale_code) = 'default') AS sort
      FROM locale
     ORDER BY
      sort,
      locale_id
     LIMIT 1
  )
  SELECT
    usr_id,
    usr_username,
    COALESCE(value[6], '') AS usr_propername,
    usr_passwd,
    COALESCE(value[5]::integer, (SELECT locale_id FROM default_locale)) AS usr_locale_id,
    COALESCE(value[4], '') AS usr_initials,
    COALESCE((value[2] = 't'), false) AS usr_agent,
    COALESCE((value[1] = 't'), false) AS usr_active,
    COALESCE(value[3], '') AS usr_email,
    COALESCE(value[7], '') AS usr_window
    FROM (
      SELECT
        usr_id,
        usr_username,
        usr_passwd,
        -- Roll the value pairs up into an array for each user.
        --array_agg(name) AS name, -- Not actually used above, but helpful for debugging.
        array_agg(value ORDER BY name) AS value
        FROM (
          SELECT
            usr_id,
            usr_username,
            usr_passwd,
            pref_names.name,
            value
            FROM (
              -- Make a table of users and dummy pref names to serve as default rows if not set for the user.
              SELECT
                usesysid::integer AS usr_id,
                usename::text AS usr_username,
                null::text AS usr_passwd,
                name
                FROM pg_user
               CROSS JOIN (
                  SELECT
                    unnest(ARRAY[
                      'active',
                      'agent',
                      'email',
                      'initials',
                      'locale_id',
                      'propername',
                      'window'
                    ]) AS name
                ) AS pref_names
            ) AS pref_names
            LEFT JOIN (
              -- Join the user's pref settings with the users and dummy pref names table.
              SELECT
                usrpref_username AS username,
                usrpref_name AS name,
                usrpref_value AS value
                FROM usrpref
               WHERE true
                 AND usrpref_name IN (
                   'active',
                   'agent',
                   'email',
                   'initials',
                   'locale_id',
                   'propername',
                   'window'
                 )
            ) AS userprefs ON (pref_names.name = userprefs.name AND pref_names.usr_username = userprefs.username)
           -- Make sure they are alpha ordered so the array access operators above know which is which.
           ORDER BY
            usr_username,
            pref_names.name
        ) AS userprefs
       GROUP BY
        usr_id,
        usr_username,
        usr_passwd
  ) AS usrprefs;

$BODY$, false);
