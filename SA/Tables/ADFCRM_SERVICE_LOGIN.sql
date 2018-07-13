CREATE TABLE sa.adfcrm_service_login (
  login_name VARCHAR2(255 BYTE),
  request VARCHAR2(255 BYTE),
  response VARCHAR2(255 BYTE),
  transaction_type VARCHAR2(255 BYTE),
  transaction_time TIMESTAMP DEFAULT systimestamp
);
COMMENT ON TABLE sa.adfcrm_service_login IS 'Store some of informaction saved in the logs by login name';
COMMENT ON COLUMN sa.adfcrm_service_login.login_name IS 'Reference to table_user.login_name';
COMMENT ON COLUMN sa.adfcrm_service_login.request IS 'Service request';
COMMENT ON COLUMN sa.adfcrm_service_login.response IS 'Service response';
COMMENT ON COLUMN sa.adfcrm_service_login.transaction_type IS 'Type of the transaction';
COMMENT ON COLUMN sa.adfcrm_service_login.transaction_time IS 'Time of the transaction';