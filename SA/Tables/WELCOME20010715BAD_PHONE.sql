CREATE TABLE sa.welcome20010715bad_phone (
  esn VARCHAR2(30 BYTE),
  cellnum VARCHAR2(30 BYTE),
  cust_first_name VARCHAR2(30 BYTE),
  cust_last_name VARCHAR2(30 BYTE),
  activation_date DATE,
  activation_zipcode VARCHAR2(20 BYTE),
  cust_home_phone VARCHAR2(20 BYTE),
  multiple_esns CHAR,
  sourcesystem VARCHAR2(30 BYTE)
);
ALTER TABLE sa.welcome20010715bad_phone ADD SUPPLEMENTAL LOG GROUP dmtsora286196947_0 (activation_date, activation_zipcode, cellnum, cust_first_name, cust_home_phone, cust_last_name, esn, multiple_esns, sourcesystem) ALWAYS;