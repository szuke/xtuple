SELECT xt.create_view('public.usr', $BODY$
-- Copyright (c) 1999-2018 by OpenMFG LLC, d/b/a xTuple.
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
    usesysid::integer AS usr_id,
    usename::text AS usr_username,
    COALESCE(propername.usrpref_value, '') AS usr_propername,
    null::text AS usr_passwd,
    COALESCE(locale.usrpref_value::integer, (SELECT locale_id FROM default_locale)) AS usr_locale_id,
    COALESCE(initials.usrpref_value, '') AS usr_initials,
    COALESCE((agent.usrpref_value = 't'), false) AS usr_agent,
    COALESCE((active.usrpref_value = 't'), false) AS usr_active,
    COALESCE(email.usrpref_value, '') AS usr_email,
    COALESCE(wind.usrpref_value, '') AS usr_window
    FROM pg_user
    LEFT JOIN usrpref AS propername ON propername.usrpref_username = usename AND propername.usrpref_name = 'propername'
    LEFT JOIN usrpref AS locale ON locale.usrpref_username = usename AND locale.usrpref_name = 'locale_id'
    LEFT JOIN usrpref AS initials ON initials.usrpref_username = usename AND initials.usrpref_name = 'initials'
    LEFT JOIN usrpref AS agent ON agent.usrpref_username = usename AND agent.usrpref_name = 'agent'
    LEFT JOIN usrpref AS active ON active.usrpref_username = usename AND active.usrpref_name = 'active'
    LEFT JOIN usrpref AS email ON email.usrpref_username = usename AND email.usrpref_name = 'email'
    LEFT JOIN usrpref AS wind ON wind.usrpref_username = usename AND wind.usrpref_name = 'window';

$BODY$, false);
