DROP VIEW IF EXISTS xdruple.oauth_2_token;
DROP VIEW IF EXISTS xdruple.oauth_2_client;

SELECT
  xt.create_table('oa2client');

SELECT
  xt.add_column('oa2client','oa2client_id', 'serial', 'primary key', 'xt', 'oa2client table primary key.'),
  xt.add_column('oa2client','oa2client_client_id', 'text', 'not null unique', 'xt', 'Generated client_id obtained during application registration.'),
  xt.add_column('oa2client','oa2client_client_secret', 'text', 'unique', 'xt', 'The client secret obtained during application registration.'),
  xt.add_column('oa2client','oa2client_client_name', 'text', '', 'xt', 'Name of the client or application.'),
  xt.add_column('oa2client','oa2client_client_email', 'text', '', 'xt', 'Email address of the client.'),
  xt.add_column('oa2client','oa2client_client_web_site', 'text', '', 'xt', 'Web site of the client.'),
  xt.add_column('oa2client','oa2client_client_logo', 'text', '', 'xt', 'URL to client logo image file displayed during auth grant.'),
  xt.add_column('oa2client','oa2client_client_type', 'text', '', 'xt', 'The OAuth 2.0 client type: "web_server", "installed_app", "service_account"'),
  xt.add_column('oa2client','oa2client_active', 'boolean', '', 'xt', 'Flag to make a client active or not.'),
  xt.add_column('oa2client','oa2client_issued', 'timestamp with time zone', '', 'xt', 'The datetime that the client was registered'),
  xt.add_column('oa2client','oa2client_auth_uri', 'text', '', 'xt', 'The Authorization Endpoint URI.'),
  xt.add_column('oa2client','oa2client_token_uri', 'text', '', 'xt', 'The Token Endpoint URI.'),
  xt.add_column('oa2client','oa2client_delegated_access', 'boolean', '', 'xt', 'Flag to allow "service_account" client to use delegated access as another user.'),
  xt.add_column('oa2client','oa2client_client_x509_pub_cert', 'text', '', 'xt', 'The public x509 certificate, used to verify JWTs signed by the client.'),
  xt.add_column('oa2client','oa2client_org', 'text', 'not null default current_database()', 'xt', 'The name of the current database.');

COMMENT ON TABLE xt.oa2client IS 'Defines global OAuth 2.0 server registered client storage.';

-- Remove old, unused OAuth 2.0 single signon token.
DELETE FROM xt.oa2client WHERE oa2client_client_id = 'oauthsso';
