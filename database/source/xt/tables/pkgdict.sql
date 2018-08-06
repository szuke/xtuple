-- table definition

select xt.create_table('pkgdict', 'xt', false, 'dict');

ALTER TABLE xt.pkgdict DISABLE TRIGGER ALL;
DROP TRIGGER IF EXISTS pkgdictaftertrigger ON xt.pkgdict;
CREATE TRIGGER pkgdictaftertrigger AFTER INSERT OR DELETE OR UPDATE ON xt.pkgdict FOR EACH ROW EXECUTE PROCEDURE _pkgdictaftertrigger();
DROP TRIGGER IF EXISTS pkgdictaltertrigger ON xt.pkgdict;
CREATE TRIGGER pkgdictaltertrigger BEFORE INSERT OR DELETE OR UPDATE ON xt.pkgdict FOR EACH ROW EXECUTE PROCEDURE _pkgdictaltertrigger();
DROP TRIGGER IF EXISTS pkgdictbeforetrigger ON xt.pkgdict;
CREATE TRIGGER pkgdictbeforetrigger BEFORE INSERT OR DELETE OR UPDATE ON xt.pkgdict FOR EACH ROW EXECUTE PROCEDURE _pkgdictbeforetrigger();
ALTER TABLE xt.pkgdict DROP CONSTRAINT IF EXISTS pkgdict_pkey CASCADE;
ALTER TABLE xt.pkgdict ADD CONSTRAINT pkgdict_pkey PRIMARY KEY(dict_id);
