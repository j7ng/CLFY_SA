CREATE TABLE sa.x_port_carriers (
  carrier_name VARCHAR2(30 BYTE),
  phone_type VARCHAR2(30 BYTE),
  port_type VARCHAR2(30 BYTE),
  min_to_transfer VARCHAR2(1 BYTE) CONSTRAINT cnt1_x_port_carriers CHECK (min_to_transfer IN('Y', 'N')),
  current_esn VARCHAR2(1 BYTE) CONSTRAINT cnt2_x_port_carriers CHECK (current_esn IN('Y', 'N')),
  account_no VARCHAR2(1 BYTE) CONSTRAINT cnt3_x_port_carriers CHECK (account_no IN('Y', 'N')),
  password_pin VARCHAR2(1 BYTE) CONSTRAINT cnt4_x_port_carriers CHECK (password_pin IN('Y', 'N')),
  v_key VARCHAR2(1 BYTE) CONSTRAINT cnt5_x_port_carriers CHECK (v_key IN('Y', 'N')),
  full_name VARCHAR2(1 BYTE) CONSTRAINT cnt6_x_port_carriers CHECK (full_name IN('Y', 'N')),
  billing_address VARCHAR2(1 BYTE) CONSTRAINT cnt7_x_port_carriers CHECK (billing_address IN('Y', 'N')),
  last_4_ssn VARCHAR2(1 BYTE) CONSTRAINT cnt8_x_port_carriers CHECK (last_4_ssn IN('Y', 'N')),
  is_account_alpha VARCHAR2(1 BYTE) CONSTRAINT cnt9_x_port_carriers CHECK (is_account_alpha IN('Y', 'N')),
  is_pin_alpha VARCHAR2(1 BYTE) CONSTRAINT cnt10_x_port_carriers CHECK (is_pin_alpha IN('Y', 'N')),
  account_no_regexp VARCHAR2(100 BYTE),
  password_pin_regexp VARCHAR2(100 BYTE),
  acct_no_regexp_desc VARCHAR2(250 BYTE),
  pwd_pin_regexp_desc VARCHAR2(250 BYTE),
  zip_code_flag VARCHAR2(1 BYTE) CONSTRAINT cnt11_x_port_carriers CHECK (zip_code_flag IN('Y', 'N')),
  esn_account_flag VARCHAR2(1 BYTE) CONSTRAINT cnt12_x_port_carriers CHECK (esn_account_flag IN('Y', 'N'))
);
COMMENT ON TABLE sa.x_port_carriers IS 'EXTERNAL CARRIERS FOR PORTING';
COMMENT ON COLUMN sa.x_port_carriers.carrier_name IS 'CARRIER NAME';
COMMENT ON COLUMN sa.x_port_carriers.phone_type IS 'LANDLINE OR WIRELESS';
COMMENT ON COLUMN sa.x_port_carriers.port_type IS 'EXTERNAL OR INTERNAL';
COMMENT ON COLUMN sa.x_port_carriers.min_to_transfer IS 'PHONE NUMBER TO TRANSFER';
COMMENT ON COLUMN sa.x_port_carriers.current_esn IS 'CURRENT PHONE SERIAL NUMBER';
COMMENT ON COLUMN sa.x_port_carriers.account_no IS 'ACCOUNT NUMBER';
COMMENT ON COLUMN sa.x_port_carriers.password_pin IS 'PASSWORD / PIN';
COMMENT ON COLUMN sa.x_port_carriers.v_key IS 'V-KEY';
COMMENT ON COLUMN sa.x_port_carriers.full_name IS 'FULL NAME';
COMMENT ON COLUMN sa.x_port_carriers.billing_address IS 'BILLING ADDRESS';
COMMENT ON COLUMN sa.x_port_carriers.last_4_ssn IS 'LAST 4 SSN';
COMMENT ON COLUMN sa.x_port_carriers.account_no_regexp IS ' Column to Store REGEXP for Account No';
COMMENT ON COLUMN sa.x_port_carriers.password_pin_regexp IS ' Column to Store REGEXP for Password PIN';
COMMENT ON COLUMN sa.x_port_carriers.acct_no_regexp_desc IS ' Column to Store REGEXP descriptoin for Account No';
COMMENT ON COLUMN sa.x_port_carriers.pwd_pin_regexp_desc IS ' Column to Store REGEXP description for Password PIN';
COMMENT ON COLUMN sa.x_port_carriers.zip_code_flag IS 'ZIP_CODE_FLAG validates ZIP value during port out from Carrier';
COMMENT ON COLUMN sa.x_port_carriers.esn_account_flag IS 'ESN_ACCOUNT_FLAG validates ESN value during port out from Carrier';