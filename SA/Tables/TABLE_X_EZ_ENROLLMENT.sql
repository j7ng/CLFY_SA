CREATE TABLE sa.table_x_ez_enrollment (
  objid NUMBER,
  dev NUMBER,
  x_esn VARCHAR2(15 BYTE),
  x_fee_amount NUMBER,
  x_promotional_code VARCHAR2(5 BYTE),
  x_language VARCHAR2(7 BYTE),
  x_first_name VARCHAR2(20 BYTE),
  x_last_name VARCHAR2(20 BYTE),
  x_street_address VARCHAR2(40 BYTE),
  x_city VARCHAR2(30 BYTE),
  x_state VARCHAR2(2 BYTE),
  x_zip VARCHAR2(9 BYTE),
  x_country_code VARCHAR2(10 BYTE),
  x_phone VARCHAR2(10 BYTE),
  x_email VARCHAR2(128 BYTE),
  x_funding_type VARCHAR2(2 BYTE),
  x_cc_type VARCHAR2(4 BYTE),
  x_name_on_cc VARCHAR2(40 BYTE),
  x_exp_date VARCHAR2(4 BYTE),
  x_cc_number VARCHAR2(16 BYTE),
  x_pin VARCHAR2(4 BYTE),
  x_status VARCHAR2(1 BYTE),
  x_payment_mode NUMBER,
  x_payment_type VARCHAR2(6 BYTE),
  x_source_system VARCHAR2(3 BYTE),
  x_program_type VARCHAR2(1 BYTE)
);
ALTER TABLE sa.table_x_ez_enrollment ADD SUPPLEMENTAL LOG GROUP dmtsora2019659312_0 (dev, objid, x_cc_number, x_cc_type, x_city, x_country_code, x_email, x_esn, x_exp_date, x_fee_amount, x_first_name, x_funding_type, x_language, x_last_name, x_name_on_cc, x_payment_mode, x_payment_type, x_phone, x_pin, x_program_type, x_promotional_code, x_source_system, x_state, x_status, x_street_address, x_zip) ALWAYS;