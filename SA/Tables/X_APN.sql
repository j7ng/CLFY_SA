CREATE TABLE sa.x_apn (
  x_parent_name VARCHAR2(60 BYTE),
  rate_plan VARCHAR2(300 BYTE),
  org_id VARCHAR2(30 BYTE),
  apn VARCHAR2(30 BYTE),
  username VARCHAR2(30 BYTE),
  "PASSWORD" VARCHAR2(30 BYTE),
  auth_type VARCHAR2(30 BYTE),
  proxy_address VARCHAR2(300 BYTE),
  proxy_port VARCHAR2(30 BYTE),
  connection_type VARCHAR2(30 BYTE),
  mms_apn VARCHAR2(300 BYTE),
  mms_username VARCHAR2(30 BYTE),
  mms_password VARCHAR2(30 BYTE),
  mms_auth_type VARCHAR2(30 BYTE),
  mmsc VARCHAR2(300 BYTE),
  mms_proxy_address VARCHAR2(300 BYTE),
  mms_proxy_port VARCHAR2(30 BYTE),
  mms_apn_type VARCHAR2(30 BYTE),
  rtsp_proxy_addr VARCHAR2(300 BYTE),
  rtsp_proxy_port VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.x_apn IS 'MATRIX OF VALUES APN SETTINGS BASED ON CARRIER AND RATE_PLAN';
COMMENT ON COLUMN sa.x_apn.x_parent_name IS 'CARRIER PARENT';
COMMENT ON COLUMN sa.x_apn.rate_plan IS 'RATE PLAN';
COMMENT ON COLUMN sa.x_apn.org_id IS 'BUS ORG';
COMMENT ON COLUMN sa.x_apn.apn IS 'APN TYPE';
COMMENT ON COLUMN sa.x_apn.username IS 'UNDEFINED';
COMMENT ON COLUMN sa.x_apn."PASSWORD" IS 'UNDEFINED';
COMMENT ON COLUMN sa.x_apn.auth_type IS 'APN TYPE';
COMMENT ON COLUMN sa.x_apn.proxy_address IS 'PROXY URL';
COMMENT ON COLUMN sa.x_apn.proxy_port IS 'PROXY PORT';
COMMENT ON COLUMN sa.x_apn.connection_type IS 'UNDEFINED';
COMMENT ON COLUMN sa.x_apn.mms_apn IS 'MMS APN TYPE';
COMMENT ON COLUMN sa.x_apn.mms_username IS 'UNDEFINED';
COMMENT ON COLUMN sa.x_apn.mms_password IS 'UNDEFINED';
COMMENT ON COLUMN sa.x_apn.mms_auth_type IS 'UNDEFINED';
COMMENT ON COLUMN sa.x_apn.mmsc IS 'MMS WEB URL';
COMMENT ON COLUMN sa.x_apn.mms_proxy_address IS 'MMS PROXY ADDRESS';
COMMENT ON COLUMN sa.x_apn.mms_proxy_port IS 'MMS PROXY PORT';
COMMENT ON COLUMN sa.x_apn.mms_apn_type IS 'UNDEFINED';
COMMENT ON COLUMN sa.x_apn.rtsp_proxy_addr IS 'UNDEFINED';
COMMENT ON COLUMN sa.x_apn.rtsp_proxy_port IS 'UNDEFINED';