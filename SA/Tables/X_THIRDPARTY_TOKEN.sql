CREATE TABLE sa.x_thirdparty_token (
  objid NUMBER,
  x_user_name VARCHAR2(50 BYTE),
  x_password VARCHAR2(200 BYTE),
  x_company_name VARCHAR2(100 BYTE),
  x_request_token VARCHAR2(200 BYTE),
  x_request_token_expires DATE
);
COMMENT ON TABLE sa.x_thirdparty_token IS 'STORES 3RD PARTY INFORMATION';
COMMENT ON COLUMN sa.x_thirdparty_token.objid IS 'INTERNAL RECORD ID';
COMMENT ON COLUMN sa.x_thirdparty_token.x_user_name IS 'USER NAME';
COMMENT ON COLUMN sa.x_thirdparty_token.x_password IS 'USER PASSWORD';
COMMENT ON COLUMN sa.x_thirdparty_token.x_company_name IS 'THIRD PARTY VENDOR NAME';
COMMENT ON COLUMN sa.x_thirdparty_token.x_request_token IS 'TOKEN IDENTIFIED WITH THE 3RD PARTY';
COMMENT ON COLUMN sa.x_thirdparty_token.x_request_token_expires IS 'DATE IN WHICH 3RD PARTY TOKEN EXPIRES';