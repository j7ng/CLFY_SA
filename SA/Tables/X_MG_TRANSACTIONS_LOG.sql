CREATE TABLE sa.x_mg_transactions_log (
  objid NUMBER,
  x_rqst_type VARCHAR2(30 BYTE),
  x_vendor_id VARCHAR2(30 BYTE),
  x_vendor_name VARCHAR2(30 BYTE),
  x_date_trans DATE,
  x_paycode VARCHAR2(30 BYTE),
  x_min VARCHAR2(40 BYTE),
  x_denomination NUMBER,
  x_first_name_c VARCHAR2(100 BYTE),
  x_lastname_c VARCHAR2(100 BYTE),
  x_address_c VARCHAR2(100 BYTE),
  x_city_c VARCHAR2(100 BYTE),
  x_state_c VARCHAR2(100 BYTE),
  x_country_c VARCHAR2(100 BYTE),
  x_zip_c VARCHAR2(100 BYTE),
  x_phone_c VARCHAR2(50 BYTE),
  x_status VARCHAR2(100 BYTE),
  x_resp_code VARCHAR2(100 BYTE),
  x_resp_message VARCHAR2(1000 BYTE),
  x_payment_type VARCHAR2(100 BYTE),
  x_lid NUMBER,
  x_esn VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.x_mg_transactions_log IS 'TO REGISTER ALL TRACFONE ERROR IN TRANSACTION BETWEEN MONEYGRAM AND TRACFONE';
COMMENT ON COLUMN sa.x_mg_transactions_log.objid IS 'UNIQUE IDENTIFIER FOR TRANSACTION MONEYGRAM';
COMMENT ON COLUMN sa.x_mg_transactions_log.x_vendor_id IS 'VENDOR ID';
COMMENT ON COLUMN sa.x_mg_transactions_log.x_vendor_name IS 'VENDOR NAME';
COMMENT ON COLUMN sa.x_mg_transactions_log.x_date_trans IS 'DATE OF TRANSACTION WAS COMPLETE';
COMMENT ON COLUMN sa.x_mg_transactions_log.x_paycode IS 'UNIQUE IDENTIFIER FOR CODE FOR TYPE OF PAYMENT';
COMMENT ON COLUMN sa.x_mg_transactions_log.x_min IS 'MIN ASSOCIATED TO TRANSACTION ';
COMMENT ON COLUMN sa.x_mg_transactions_log.x_denomination IS 'DENOMINATION FOR THE PAYMENT';
COMMENT ON COLUMN sa.x_mg_transactions_log.x_first_name_c IS 'FIRST NAME OF CUSTOMER';
COMMENT ON COLUMN sa.x_mg_transactions_log.x_lastname_c IS 'FIRST NAME OF CUSTOMER';
COMMENT ON COLUMN sa.x_mg_transactions_log.x_address_c IS 'ADDRESS OF CUSTOMER';
COMMENT ON COLUMN sa.x_mg_transactions_log.x_city_c IS 'CITY OF CUSTOMER';
COMMENT ON COLUMN sa.x_mg_transactions_log.x_state_c IS 'STATE OF CUSTOMER';
COMMENT ON COLUMN sa.x_mg_transactions_log.x_country_c IS 'COUNTRY OF CUSTOMER';
COMMENT ON COLUMN sa.x_mg_transactions_log.x_zip_c IS 'ZIPCODE OF CUSTOMER';
COMMENT ON COLUMN sa.x_mg_transactions_log.x_phone_c IS 'PHONE OF CUSTOMER';
COMMENT ON COLUMN sa.x_mg_transactions_log.x_status IS 'STATUS OF TRANSACTION FAIL OR PASS';
COMMENT ON COLUMN sa.x_mg_transactions_log.x_resp_code IS 'ERROR CODE INTERNAL FOR TRACFONE VALIDATION';
COMMENT ON COLUMN sa.x_mg_transactions_log.x_resp_message IS 'ERROR MESSAGE INTERNAL FOR TRACFONE VALIDATION';
COMMENT ON COLUMN sa.x_mg_transactions_log.x_payment_type IS 'TYPE OF PAYMENT SAFELINK BB';
COMMENT ON COLUMN sa.x_mg_transactions_log.x_lid IS 'LID FOR CUSTOMER';
COMMENT ON COLUMN sa.x_mg_transactions_log.x_esn IS 'ESN FOR CUSTOMER';