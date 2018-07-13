CREATE TABLE sa.table_web_user (
  objid NUMBER,
  login_name VARCHAR2(50 BYTE),
  s_login_name VARCHAR2(50 BYTE),
  "PASSWORD" VARCHAR2(255 BYTE),
  user_key VARCHAR2(30 BYTE),
  status NUMBER,
  passwd_chg DATE,
  dev NUMBER,
  ship_via VARCHAR2(80 BYTE),
  x_secret_questn VARCHAR2(200 BYTE),
  s_x_secret_questn VARCHAR2(200 BYTE),
  x_secret_ans VARCHAR2(200 BYTE),
  s_x_secret_ans VARCHAR2(200 BYTE),
  web_user2user NUMBER,
  web_user2contact NUMBER,
  web_user2lead NUMBER,
  web_user2bus_org NUMBER,
  x_last_update_date DATE,
  x_validated NUMBER,
  x_validated_counter NUMBER,
  named_userid VARCHAR2(255 BYTE),
  insert_timestamp DATE DEFAULT sysdate
);
ALTER TABLE sa.table_web_user ADD SUPPLEMENTAL LOG GROUP dmtsora1506806267_0 (dev, login_name, objid, passwd_chg, "PASSWORD", ship_via, status, s_login_name, s_x_secret_ans, s_x_secret_questn, user_key, web_user2bus_org, web_user2contact, web_user2lead, web_user2user, x_secret_ans, x_secret_questn) ALWAYS;
COMMENT ON TABLE sa.table_web_user IS 'Stores the profile of a WebSupport user';
COMMENT ON COLUMN sa.table_web_user.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_web_user.login_name IS 'WebSupport user login name';
COMMENT ON COLUMN sa.table_web_user."PASSWORD" IS 'WebSupport user password';
COMMENT ON COLUMN sa.table_web_user.user_key IS 'System-generated key value to locate WebSupport user';
COMMENT ON COLUMN sa.table_web_user.status IS 'WebSupport user Status; i.e., 0=inactive, 1=Active';
COMMENT ON COLUMN sa.table_web_user.passwd_chg IS 'Date/Time password was last changed; supports password expiration';
COMMENT ON COLUMN sa.table_web_user.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_web_user.ship_via IS 'Default means of shipment for the web_user. This is from a Clarify-defined popup list with default name SHIP_VIA';
COMMENT ON COLUMN sa.table_web_user.x_secret_questn IS 'Secret question for the customer account.';
COMMENT ON COLUMN sa.table_web_user.x_secret_ans IS 'Answer to the secret question';
COMMENT ON COLUMN sa.table_web_user.web_user2lead IS 'If the web_user is a lead, the lead';
COMMENT ON COLUMN sa.table_web_user.web_user2bus_org IS 'web user for the bus org';
COMMENT ON COLUMN sa.table_web_user.x_validated IS 'User email gets validated or not. Validation code (NULL/0 =>  NOT validated / 1 => validated)';
COMMENT ON COLUMN sa.table_web_user.x_validated_counter IS 'How many times the user email gets validated.Counter will only be relevant when x_validated represents "NOT validated"';
COMMENT ON COLUMN sa.table_web_user.named_userid IS 'Named User Id';
COMMENT ON COLUMN sa.table_web_user.insert_timestamp IS 'Audit column for record creation date';