CREATE TABLE sa.table_pay_means (
  objid NUMBER,
  dev NUMBER,
  id_number VARCHAR2(64 BYTE),
  means_type NUMBER,
  expire_date DATE,
  bill_address VARCHAR2(80 BYTE),
  bill_city VARCHAR2(30 BYTE),
  bill_state_prov VARCHAR2(80 BYTE),
  bill_zipcode VARCHAR2(25 BYTE),
  cc_name VARCHAR2(80 BYTE),
  cc_type VARCHAR2(20 BYTE),
  cc_exp_mo VARCHAR2(2 BYTE),
  cc_exp_yr VARCHAR2(4 BYTE),
  last_four VARCHAR2(4 BYTE),
  bill_country VARCHAR2(40 BYTE),
  modify_stmp DATE,
  pay_means2bus_org NUMBER
);
ALTER TABLE sa.table_pay_means ADD SUPPLEMENTAL LOG GROUP dmtsora1006669607_0 (bill_address, bill_city, bill_country, bill_state_prov, bill_zipcode, cc_exp_mo, cc_exp_yr, cc_name, cc_type, dev, expire_date, id_number, last_four, means_type, modify_stmp, objid, pay_means2bus_org) ALWAYS;
COMMENT ON TABLE sa.table_pay_means IS 'Contains the description of a device for making a payment; e.g., credit card ';
COMMENT ON COLUMN sa.table_pay_means.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_pay_means.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_pay_means.id_number IS 'Payment means identification number; e.g., the credit card number';
COMMENT ON COLUMN sa.table_pay_means.means_type IS 'The payment option for this line item; e.g., purchase order, credit card, etc. This is from a user-defined popup with default name PAY_METHOD';
COMMENT ON COLUMN sa.table_pay_means.expire_date IS 'The last date the payment means is effective';
COMMENT ON COLUMN sa.table_pay_means.bill_address IS 'Street address of the person whose name appears on the payment means';
COMMENT ON COLUMN sa.table_pay_means.bill_city IS 'The city for the bill address ';
COMMENT ON COLUMN sa.table_pay_means.bill_state_prov IS 'The state/province of the bill address';
COMMENT ON COLUMN sa.table_pay_means.bill_zipcode IS 'Zipcode or postal code of the bill address';
COMMENT ON COLUMN sa.table_pay_means.cc_name IS 'For credit cards, complete name of the credit card owner as it appears on the card';
COMMENT ON COLUMN sa.table_pay_means.cc_exp_mo IS '2-digit number of the month when the card expires';
COMMENT ON COLUMN sa.table_pay_means.cc_exp_yr IS '2- or 4-digit number of the year in which the credit card expires';
COMMENT ON COLUMN sa.table_pay_means.last_four IS 'Last four digits of the pay_means id_number';
COMMENT ON COLUMN sa.table_pay_means.bill_country IS 'The country of the bill address';
COMMENT ON COLUMN sa.table_pay_means.modify_stmp IS 'Date and time when object was last saved';