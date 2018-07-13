CREATE TABLE sa.welcome20010715open_case (
  esn VARCHAR2(30 BYTE),
  cellnum VARCHAR2(30 BYTE),
  cust_first_name VARCHAR2(30 BYTE),
  cust_last_name VARCHAR2(30 BYTE),
  cust_home_phone VARCHAR2(20 BYTE),
  activation_date DATE,
  sourcesystem VARCHAR2(30 BYTE),
  activation_zipcode VARCHAR2(20 BYTE),
  multiple_esns CHAR
);
ALTER TABLE sa.welcome20010715open_case ADD SUPPLEMENTAL LOG GROUP dmtsora1332362812_0 (activation_date, activation_zipcode, cellnum, cust_first_name, cust_home_phone, cust_last_name, esn, multiple_esns, sourcesystem) ALWAYS;