CREATE TABLE sa.x_access_token (
  objid NUMBER,
  x_user_token VARCHAR2(200 BYTE),
  x_user_token_expires DATE,
  acc_token2web_user NUMBER,
  x_login_level NUMBER
);
COMMENT ON TABLE sa.x_access_token IS 'STORES INFORMATION ABOUT CUSTOMER THAT WANTS TO ACCESS TO SAVING CLUB';
COMMENT ON COLUMN sa.x_access_token.objid IS 'INTERNAL RECORD ID';
COMMENT ON COLUMN sa.x_access_token.x_user_token IS 'USER SESSION TOKEN';
COMMENT ON COLUMN sa.x_access_token.x_user_token_expires IS 'DATE IN WHICH TOKEN EXPIRES';
COMMENT ON COLUMN sa.x_access_token.acc_token2web_user IS 'REFERENCE TO OBJID IN TABLE_WEB_USER';
COMMENT ON COLUMN sa.x_access_token.x_login_level IS 'LOGIN LEVEL  (0 => NOT LOGGED IN, 50 => HANDSET AUTHORIZED,  100 =>  FULLY AUTHORIZED)';