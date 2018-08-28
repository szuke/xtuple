DROP TRIGGER  IF EXISTS crmacctAfterTrigger  ON crmacct;
DROP TRIGGER  IF EXISTS crmacctBeforeTrigger ON crmacct;
DROP FUNCTION IF EXISTS _crmacctAfterTrigger();
DROP FUNCTION IF EXISTS _crmacctBeforeTrigger();

CREATE OR REPLACE FUNCTION _crmacctBeforeUpsertTrigger() RETURNS TRIGGER AS $$
-- TODO: add special handling for converting prospects <-> customers?
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
DECLARE
  _matchingUsrNew BOOLEAN := false;
  _matchingUsrOld BOOLEAN := false;
BEGIN

  NEW.crmacct_number         := UPPER(NEW.crmacct_number);
  NEW.crmacct_lastupdated    := now();
  NEW.crmacct_owner_username := LOWER(TRIM(NEW.crmacct_owner_username));

  IF COALESCE(NEW.crmacct_owner_username, '') = '' THEN
    NEW.crmacct_owner_username := getEffectiveXtUser();
  END IF;
  IF NEW.crmacct_competitor_id < 0 THEN
    NEW.crmacct_competitor_id := NULL;
  END IF;
  IF NEW.crmacct_partner_id < 0 THEN
    NEW.crmacct_partner_id := NULL;
  END IF;

  _matchingUsrNew := EXISTS(SELECT 1 FROM usr
                             WHERE usr_username = lower(NEW.crmacct_number));

  IF (TG_OP = 'INSERT') THEN
    -- disallow reusing crmacct_numbers
    IF fetchMetricText('CRMAccountNumberGeneration') IN ('A','O') THEN
      PERFORM clearNumberIssue('CRMAccountNumber', NEW.crmacct_number);
    END IF;

    IF _matchingUsrNew THEN
      NEW.crmacct_usr_username := lower(NEW.crmacct_number);
    ELSE
      NEW.crmacct_usr_username := NULL;
    END IF;

    NEW.crmacct_created := now();

  ELSIF (TG_OP = 'UPDATE') THEN
    _matchingUsrOld := EXISTS(SELECT 1 FROM usr
                               WHERE usr_username = lower(OLD.crmacct_number));
    NEW.crmacct_usr_username := lower(NEW.crmacct_number);
    IF _matchingUsrOld AND NOT _matchingUsrNew THEN
      EXECUTE format('ALTER ROLE %I RENAME TO %I;',
                     OLD.crmacct_usr_username, NEW.crmacct_usr_username);
    ELSIF NOT _matchingUsrOld AND NOT _matchingUsrNew THEN
      NEW.crmacct_usr_username := NULL;  -- see bug 25291
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS crmacctBeforeUpsertTrigger ON crmacct;
CREATE TRIGGER crmacctBeforeUpsertTrigger BEFORE INSERT OR UPDATE ON crmacct
  FOR EACH ROW EXECUTE PROCEDURE _crmacctBeforeUpsertTrigger();

CREATE OR REPLACE FUNCTION _crmacctBeforeDeleteTrigger() RETURNS TRIGGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
  UPDATE cntct SET cntct_crmacct_id = NULL
   WHERE cntct_crmacct_id = OLD.crmacct_id;

  DELETE FROM docass WHERE docass_source_id = OLD.crmacct_id AND docass_source_type = 'CRMA';
  DELETE FROM docass WHERE docass_target_id = OLD.crmacct_id AND docass_target_type = 'CRMA';

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS crmacctBeforeDeleteTrigger ON crmacct;
CREATE TRIGGER crmacctBeforeDeleteTrigger BEFORE DELETE ON crmacct
  FOR EACH ROW EXECUTE PROCEDURE _crmacctBeforeDeleteTrigger();

CREATE OR REPLACE FUNCTION _crmacctAfterUpsertTrigger () RETURNS TRIGGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN
  /* update _number and _name separately to propagate just what changed.
     the priv manipulation allows targeted updates of crmaccount-maintained data
   */
  IF TG_OP = 'UPDATE' AND
      (OLD.crmacct_number != NEW.crmacct_number OR
       OLD.crmacct_name   != NEW.crmacct_name) THEN
      IF NEW.crmacct_cust_id IS NOT NULL THEN
        UPDATE custinfo SET cust_number = NEW.crmacct_number
        WHERE ((cust_id=NEW.crmacct_cust_id)
          AND  (cust_number!=NEW.crmacct_number));
        UPDATE custinfo SET cust_name = NEW.crmacct_name
        WHERE ((cust_id=NEW.crmacct_cust_id)
          AND  (cust_name!=NEW.crmacct_name));
      END IF;

      IF NEW.crmacct_emp_id IS NOT NULL THEN
        UPDATE emp SET emp_code = NEW.crmacct_number
        WHERE ((emp_id=NEW.crmacct_emp_id)
          AND  (emp_code!=NEW.crmacct_number));
        UPDATE emp SET emp_name = NEW.crmacct_name
        WHERE ((emp_id=NEW.crmacct_emp_id)
          AND  (emp_name!=NEW.crmacct_name));
      END IF;

      IF (NEW.crmacct_prospect_id IS NOT NULL) THEN
        UPDATE prospect SET prospect_number = NEW.crmacct_number
        WHERE ((prospect_id=NEW.crmacct_prospect_id)
          AND  (prospect_number!=NEW.crmacct_number));
        UPDATE prospect SET prospect_name = NEW.crmacct_name
        WHERE ((prospect_id=NEW.crmacct_prospect_id)
          AND  (prospect_name!=NEW.crmacct_name));
      END IF;

      IF (NEW.crmacct_salesrep_id IS NOT NULL) THEN
        UPDATE salesrep SET salesrep_number = NEW.crmacct_number
        WHERE ((salesrep_id=NEW.crmacct_salesrep_id)
          AND  (salesrep_number!=NEW.crmacct_number));
        UPDATE salesrep SET salesrep_name = NEW.crmacct_name
        WHERE ((salesrep_id=NEW.crmacct_salesrep_id)
          AND  (salesrep_name!=NEW.crmacct_name));
      END IF;

      IF (NEW.crmacct_taxauth_id IS NOT NULL) THEN
        UPDATE taxauth SET taxauth_code = NEW.crmacct_number
        WHERE ((taxauth_id=NEW.crmacct_taxauth_id)
          AND  (taxauth_code!=NEW.crmacct_number));
        UPDATE taxauth SET taxauth_name = NEW.crmacct_name
        WHERE ((taxauth_id=NEW.crmacct_taxauth_id)
          AND  (taxauth_name!=NEW.crmacct_name));
      END IF;

      IF (NEW.crmacct_vend_id IS NOT NULL) THEN
        UPDATE vendinfo SET vend_number = NEW.crmacct_number
        WHERE ((vend_id=NEW.crmacct_vend_id)
          AND  (vend_number!=NEW.crmacct_number));
        UPDATE vendinfo SET vend_name = NEW.crmacct_name
        WHERE ((vend_id=NEW.crmacct_vend_id)
          AND  (vend_name!=NEW.crmacct_name));
      END IF;
  END IF;

  IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
    -- Link Primary and Secondary Contacts to this Account if they are not already
    IF (NEW.crmacct_cntct_id_1 IS NOT NULL) THEN
      UPDATE cntct SET cntct_crmacct_id = NEW.crmacct_id
       WHERE cntct_id=NEW.crmacct_cntct_id_1
         AND COALESCE(cntct_crmacct_id, -1) != NEW.crmacct_id;
    END IF;

    IF (NEW.crmacct_cntct_id_2 IS NOT NULL) THEN
      UPDATE cntct SET cntct_crmacct_id = NEW.crmacct_id
       WHERE cntct_id=NEW.crmacct_cntct_id_2
         AND COALESCE(cntct_crmacct_id, -1) != NEW.crmacct_id;
    END IF;

    -- cannot have fkey references to system catalogs so enforce them here
    IF (NEW.crmacct_usr_username IS NOT NULL) THEN
      UPDATE usrpref SET usrpref_value = NEW.crmacct_name
      WHERE ((usrpref_username=NEW.crmacct_usr_username)
        AND  (usrpref_name='propername')
        AND  (usrpref_value!=NEW.crmacct_name));
    END IF;

  END IF;

  IF (TG_OP = 'INSERT') THEN
    PERFORM postComment('ChangeLog', 'CRMA', NEW.crmacct_id,
                        ('Created by ' || getEffectiveXtUser()));
  ELSIF TG_OP = 'UPDATE' THEN
    IF NEW.crmacct_usr_username != OLD.crmacct_usr_username THEN
      PERFORM postComment('ChangeLog', 'CRMA', NEW.crmacct_id,
                          format('Changed crmacct from db user %L to %L by %L',
                                 OLD.crmacct_usr_username,
                                 NEW.crmacct_usr_username,
                                 getEffectiveXtUser()));
      END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS crmacctAfterUpsertTrigger ON crmacct;
CREATE TRIGGER crmacctAfterUpsertTrigger AFTER INSERT OR UPDATE ON crmacct
  FOR EACH ROW EXECUTE PROCEDURE _crmacctAfterUpsertTrigger();

CREATE OR REPLACE FUNCTION _crmacctAfterDeleteTrigger() RETURNS TRIGGER AS $$
-- Copyright (c) 1999-2017 by OpenMFG LLC, d/b/a xTuple.
-- See www.xtuple.com/CPAL for the full text of the software license.
BEGIN

  IF (OLD.crmacct_cust_id IS NOT NULL) THEN
    RAISE EXCEPTION 'Cannot delete CRM Account because it is a Customer [xtuple: deleteCrmAccount, -1]';
  END IF;

  IF (OLD.crmacct_emp_id IS NOT NULL) THEN
    RAISE EXCEPTION 'Cannot delete CRM Account because it is an Employee [xtuple: deleteCrmAccount, -7]';
  END IF;

  IF (OLD.crmacct_prospect_id IS NOT NULL) THEN
    RAISE EXCEPTION 'Cannot delete CRM Account because it is a Prospect [xtuple: deleteCrmAccount, -3]';
  END IF;

  DELETE FROM salesrep WHERE salesrep_id  = OLD.crmacct_salesrep_id;
  IF (OLD.crmacct_salesrep_id IS NOT NULL) THEN
    RAISE EXCEPTION 'Cannot delete CRM Account because it is a Sales Rep [xtuple: deleteCrmAccount, -6]';
  END IF;

  IF (OLD.crmacct_taxauth_id IS NOT NULL) THEN
    RAISE EXCEPTION 'Cannot delete CRM Account because it is a Tax Authority [xtuple: deleteCrmAccount, -5]';
  END IF;

  IF (EXISTS(SELECT usename
               FROM pg_user
              WHERE usename=OLD.crmacct_usr_username)) THEN
    RAISE EXCEPTION 'Cannot delete CRM Account because it is a User [xtuple: deleteCrmAccount, -8]';
  END IF;

  IF (OLD.crmacct_vend_id IS NOT NULL) THEN
    RAISE EXCEPTION 'Cannot delete CRM Account because it is a Vendor [xtuple: deleteCrmAccount, -2]';
  END IF;

  DELETE FROM imageass
   WHERE (imageass_source_id=OLD.crmacct_id) AND (imageass_source='CRMA');
  DELETE FROM url
   WHERE (url_source_id=OLD.crmacct_id)      AND (url_source='CRMA');

  DELETE
  FROM charass
  WHERE charass_target_type = 'CRMACCT'
    AND charass_target_id = OLD.crmacct_id;

  PERFORM postComment('ChangeLog', 'CRMA', OLD.crmacct_id,
                      'Deleted "' || OLD.crmacct_number || '"');

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

SELECT dropIfExists('TRIGGER', 'crmacctAfterDeleteTrigger');
CREATE TRIGGER crmacctAfterDeleteTrigger AFTER DELETE ON crmacct
  FOR EACH ROW EXECUTE PROCEDURE _crmacctAfterDeleteTrigger();
