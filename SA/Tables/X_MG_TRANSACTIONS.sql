CREATE TABLE sa.x_mg_transactions (
  objid NUMBER,
  x_rqst_type VARCHAR2(30 BYTE),
  x_vendor_id VARCHAR2(30 BYTE),
  x_vendor_name VARCHAR2(30 BYTE),
  x_date_trans DATE,
  x_paycode VARCHAR2(30 BYTE),
  x_min VARCHAR2(40 BYTE),
  x_denomination NUMBER,
  x_refer NUMBER,
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
  x_mg_reference_number VARCHAR2(60 BYTE),
  x_tf_reference_number VARCHAR2(60 BYTE),
  x_payment_type VARCHAR2(100 BYTE),
  x_bill_current VARCHAR2(50 BYTE),
  x_tax_amount NUMBER,
  x_actual_amount NUMBER,
  x_actual_tax_amount NUMBER,
  x_bill_amount NUMBER,
  x_lid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_case NUMBER,
  x_smp VARCHAR2(30 BYTE),
  x_rcf NUMBER,
  x_usf NUMBER,
  x_e911 NUMBER
);
COMMENT ON TABLE sa.x_mg_transactions IS 'TO REGISTER ALL TRANSACTIONS BETWEEN MONEYGRAM AND TRACFONE';
COMMENT ON COLUMN sa.x_mg_transactions.objid IS 'UNIQUE IDENTIFIER FOR TRANSACTION MONEYGRAM';
COMMENT ON COLUMN sa.x_mg_transactions.x_rqst_type IS 'REQUEST TYPE VALIDATION OR MONEYTRANSFER';
COMMENT ON COLUMN sa.x_mg_transactions.x_vendor_id IS 'UNIQUE IDENTIFIER FOR VENDOR';
COMMENT ON COLUMN sa.x_mg_transactions.x_vendor_name IS 'VENDOR NAME';
COMMENT ON COLUMN sa.x_mg_transactions.x_date_trans IS 'DATE OF TRANSACTION WAS COMPLETE';
COMMENT ON COLUMN sa.x_mg_transactions.x_paycode IS 'UNIQUE IDENTIFIER FOR CODE FOR TYPE OF PAYMENT';
COMMENT ON COLUMN sa.x_mg_transactions.x_min IS 'MIN ASSOCIATED TO TRANSACTION';
COMMENT ON COLUMN sa.x_mg_transactions.x_denomination IS 'DENOMINATION FOR THE PAYMENT';
COMMENT ON COLUMN sa.x_mg_transactions.x_refer IS 'MONEYGRAM REFRENCE SEND TO TRACFONE FOR TRANSACTION';
COMMENT ON COLUMN sa.x_mg_transactions.x_first_name_c IS 'FIRST NAME OF CUTUMER';
COMMENT ON COLUMN sa.x_mg_transactions.x_lastname_c IS 'LAST NAME OF CUTUMER';
COMMENT ON COLUMN sa.x_mg_transactions.x_address_c IS 'ADDRESS OF CUTUMER';
COMMENT ON COLUMN sa.x_mg_transactions.x_city_c IS 'CITY OF CUSTOMER';
COMMENT ON COLUMN sa.x_mg_transactions.x_state_c IS 'STATE OF CUSTOMER';
COMMENT ON COLUMN sa.x_mg_transactions.x_country_c IS 'COUNTRY OF CUSTOMER';
COMMENT ON COLUMN sa.x_mg_transactions.x_zip_c IS 'ZIPCODE OF CUSTOMER';
COMMENT ON COLUMN sa.x_mg_transactions.x_phone_c IS 'PHONE OF CUSTOMER';
COMMENT ON COLUMN sa.x_mg_transactions.x_status IS 'STATUS OF TRANSACTION FAIL OR PASS';
COMMENT ON COLUMN sa.x_mg_transactions.x_resp_code IS 'ERROR CODE INTERNAL FOR TRACFONE VALIDATION';
COMMENT ON COLUMN sa.x_mg_transactions.x_resp_message IS 'ERROR MESSAGE INTERNAL FOR TRACFONE VALIDATION ';
COMMENT ON COLUMN sa.x_mg_transactions.x_mg_reference_number IS 'REFERENCE SENT FOR MONEYGRAM';
COMMENT ON COLUMN sa.x_mg_transactions.x_tf_reference_number IS 'TRACFONE REFERENCE FOR TRANSACTION';
COMMENT ON COLUMN sa.x_mg_transactions.x_payment_type IS 'TYPE OF PAYMENT SAFELINK BB';
COMMENT ON COLUMN sa.x_mg_transactions.x_bill_current IS 'BILL OF CUSTOMER';
COMMENT ON COLUMN sa.x_mg_transactions.x_tax_amount IS 'TAX AMOUNT FOR TRANSACTION';
COMMENT ON COLUMN sa.x_mg_transactions.x_actual_amount IS 'ACTUAL AMOUNT FOR TRANSACTION';
COMMENT ON COLUMN sa.x_mg_transactions.x_actual_tax_amount IS 'ACTUAL AMOUNT * TAX AMOUNT FOR TRANSACTION';
COMMENT ON COLUMN sa.x_mg_transactions.x_bill_amount IS 'BILL AMOUNT FOR TRANSACTION';
COMMENT ON COLUMN sa.x_mg_transactions.x_lid IS 'LID FOR CUSTOMER';
COMMENT ON COLUMN sa.x_mg_transactions.x_esn IS 'ESN FOR CUSTOMER';
COMMENT ON COLUMN sa.x_mg_transactions.x_case IS 'CASE ASSOCIATED TO TRANSACTION';
COMMENT ON COLUMN sa.x_mg_transactions.x_smp IS 'X_SMP FROM TABLE_X_CC_RED_INV';
COMMENT ON COLUMN sa.x_mg_transactions.x_rcf IS 'Indicates RCF value ';
COMMENT ON COLUMN sa.x_mg_transactions.x_usf IS 'Indicates USF value ';
COMMENT ON COLUMN sa.x_mg_transactions.x_e911 IS 'Indicates E911 value ';