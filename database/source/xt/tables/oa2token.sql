DROP VIEW IF EXISTS xdruple.oauth_2_token;
DROP VIEW IF EXISTS xm.oauth2token;
DROP VIEW IF EXISTS sys.oauth2token;

SELECT
  xt.create_table('oa2token');

SELECT
  xt.add_column('oa2token','oa2token_id', 'serial', 'primary key', 'xt', 'oa2token table primary key.'),
  xt.add_column('oa2token','oa2token_username', 'text', '', 'xt', 'Indicates the username this token exchange is for.'),
  xt.add_column('oa2token','oa2token_client_id', 'text', 'not null references xt.oa2client (oa2client_client_id) on delete cascade', 'xt', 'Indicates the client that is making the request.'),
  xt.add_column('oa2token','oa2token_redirect_uri', 'text', '', 'xt', 'Determines where the response is sent.'),
  xt.add_column('oa2token','oa2token_scope', 'text', 'not null', 'xt', 'Indicates the xTuple org access your application is requesting.'),
  xt.add_column('oa2token','oa2token_state', 'text', '', 'xt', 'Indicates any state which may be useful to your application upon receipt of the response.'),
  xt.add_column('oa2token','oa2token_approval_prompt', 'boolean', '', 'xt', 'Indicates if the user should be re-prompted for consent.'),
  xt.add_column('oa2token','oa2token_auth_code', 'text', 'unique', 'xt', 'The auth code returned from the initial authorization request.'),
  xt.add_column('oa2token','oa2token_auth_code_issued', 'timestamp with time zone', '', 'xt', 'The datetime the auth code was issued.'),
  xt.add_column('oa2token','oa2token_auth_code_expires', 'timestamp with time zone', '', 'xt', 'The datetime that the auth code expires.'),
  xt.add_column('oa2token','oa2token_refresh_token', 'text', 'unique', 'xt', 'The refresh token used to get a new access token when an old one expires.'),
  xt.add_column('oa2token','oa2token_refresh_issued', 'timestamp with time zone', '', 'xt', 'The datetime the refresh token was issued.'),
  xt.add_column('oa2token','oa2token_refresh_expires', 'timestamp with time zone', '', 'xt', 'The datetime that the refresh token expires.'),
  xt.add_column('oa2token','oa2token_access_token', 'text', 'unique', 'xt', 'The current access token to be included with every API call.'),
  xt.add_column('oa2token','oa2token_access_issued', 'timestamp with time zone', '', 'xt', 'The datetime the access token was issued.'),
  xt.add_column('oa2token','oa2token_access_expires', 'timestamp with time zone', '', 'xt', 'The datetime that the access token expires.'),
  xt.add_column('oa2token','oa2token_token_type', 'text', 'not null', 'xt', 'Indicates the type of token returned. At this time, this field will always have the value Bearer.'),
  xt.add_column('oa2token','oa2token_access_type', 'text', '', 'xt', 'Indicates if a web_server needs to access an API when the user is not present.'),
  xt.add_column('oa2token','oa2token_delegate', 'text', '', 'xt', 'username for which a service_account is requesting delegated access as.');

COMMENT ON TABLE xt.oa2token IS 'Defines global OAuth 2.0 server token storage.';
