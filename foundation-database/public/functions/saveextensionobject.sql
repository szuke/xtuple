CREATE OR REPLACE FUNCTION saveExtensionObject(pType TEXT, pGroup TEXT, pName TEXT, pGrade INTEGER, pSource TEXT, pNotes TEXT, pEnabled BOOLEAN, pSchema TEXT) RETURNS INTEGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple. 
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _schema TEXT;
  _table TEXT;
  _idcolumn TEXT;
  _namecolumn TEXT;
  _gradecolumn TEXT;
  _sourcecolumn TEXT;
  _notescolumn TEXT;
  _namecondition TEXT;
  _groupinsertclause TEXT := '';
  _groupinsertvalue TEXT := '';
  _enabledupdateclause TEXT := '';
  _enabledinsertclause TEXT := '';
  _enabledinsertvalue TEXT := '';
  _grade INTEGER;
  _id INTEGER;

BEGIN
  pType := lower(pType);
  pSchema := lower(pSchema);

  IF (pType NOT IN ('script', 'metasql', 'report', 'uiform')) THEN
    RAISE EXCEPTION 'Invalid extension object type % [xtuple: saveExtensionObject, -1, %]', pType, pType;
  END IF;

  IF (pSchema IS NOT NULL AND pSchema NOT IN (SELECT pkghead_name
                                                FROM pkghead
                                                JOIN pg_namespace
                                                  ON pkghead_name=nspname)) THEN
    RAISE EXCEPTION 'Package % does not exist [xtuple: saveExtensionObject, -2, %]', pSchema, pSchema;
  END IF;

  IF (pSchema IS NULL) THEN
    _schema := 'public';
    _table := pType;
  ELSE
    _schema := pSchema;
    _table := format('pkg%s', pType);
  END IF;

  IF (COALESCE(pName, '') = '') THEN
    RAISE EXCEPTION '% must have a name [xtuple: saveExtensionObject, -3, %]', pType, pType;
  END IF;

  IF (COALESCE(pSource, '') = '') THEN
    RAISE EXCEPTION '% must have content [xtuple: saveExtensionObject, -4, %]', pType, pType;
  END IF;

  pGroup := COALESCE(pGroup, '');
  pNotes := COALESCE(pNotes, '');
  pGrade := COALESCE(pGrade, 0);
  pEnabled := COALESCE(pEnabled, TRUE);

  IF (pType='script') THEN
    -- scripts are handled differently because they use order instead of grade
    -- uiforms use a column named uiform_order, but it is really a grade
    EXECUTE format($f$
                      UPDATE ONLY %I.%I
                         SET script_source=%L,
                             script_notes=%L,
                             script_enabled=%L
                       WHERE script_name=%L
                         AND script_order=%L
                      RETURNING script_id;
                    $f$, _schema, _table, pSource, pNotes, pEnabled, pName, pGrade) INTO _id;

    IF (_id IS NULL) THEN
      EXECUTE format($f$
                       INSERT INTO %I.%I
                       (script_name, script_order, script_source, script_notes, script_enabled)
                       VALUES(%L, %L, %L, %L, %L)
                       RETURNING script_id;
                     $f$, _schema, _table, pName, pGrade, pSource, pNotes, pEnabled) INTO _id;
    END IF;
  ELSE
    IF (pType='metasql') THEN
      _namecondition := format('metasql_group=%L AND metasql_name=%L', pGroup, pName);
      _groupinsertclause := 'metasql_group,';
      _groupinsertvalue := format('%L,', pGroup);
    ELSE
      _namecondition := format('%I=%L', format('%s_name', pType), pName);
    END IF;

    IF (pType='uiform') THEN
      _gradecolumn := 'uiform_order';
    ELSE
      _gradecolumn := format('%s_grade', pType);
    END IF;

    _idcolumn := format('%s_id', pType);

    IF (pType='uiform') THEN
      _enabledupdateclause := format(',uiform_enabled=%L', pEnabled);
      _enabledinsertclause := ',uiform_enabled';
      _enabledinsertvalue := format(',%L', pEnabled);
    END IF;

    IF (pType='metasql') THEN
      _sourcecolumn := 'metasql_query';
    ELSE
      _sourcecolumn := format('%s_source', pType);
    END IF;

    IF (pType='report') THEN
      _notescolumn := 'report_descrip';
    ELSE
      _notescolumn := format('%s_notes', pType);
    END IF;

    _namecolumn := format('%s_name', pType);

    EXECUTE format($f$
                     SELECT MIN(sequence_value-1)
                       FROM sequence
                      WHERE sequence_value-1>=%L
                        AND sequence_value-1 NOT IN (SELECT %I
                                                       FROM %I
                                                       JOIN pg_class c ON %I.tableoid=c.oid
                                                       JOIN pg_namespace n ON c.relnamespace=n.oid
                                                      WHERE %s
                                                        AND n.nspname!=%L)
                   $f$, pGrade, _gradecolumn, pType, pType, _namecondition, _schema) INTO _grade;
    _grade := COALESCE(_grade, 0);

    EXECUTE format($f$
                     SELECT %I
                       FROM ONLY %I.%I
                      WHERE %s AND %I=%L;
                   $f$, _idcolumn, _schema, _table, _namecondition, _gradecolumn, _grade) INTO _id;

    IF (_id IS NOT NULL) THEN
      EXECUTE format($f$
                       UPDATE %I.%I
                          SET %I=%L,
                              %I=%L
                              %s
                        WHERE %I=%L;
                     $f$, _schema, _table, _sourcecolumn, pSource, _notescolumn, pNotes, _enabledupdateclause, _idcolumn, _id);
    ELSE
      EXECUTE format($f$
                       INSERT INTO %I.%I
                       (%s %I, %I, %I, %I%s)
                       VALUES(%s %L, %L, %L, %L%s)
                       RETURNING %I;
                     $f$, _schema, _table, _groupinsertclause, _namecolumn, _gradecolumn, _sourcecolumn, _notescolumn, _enabledinsertclause, _groupinsertvalue, pName, _grade, pSource, pNotes, _enabledinsertvalue, _idcolumn) INTO _id;
    END IF;
  END IF;

  RETURN _id;
 
END;
$$ LANGUAGE 'plpgsql';
