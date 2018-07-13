CREATE TABLE sa.x_topp_telecom_territories (
  div VARCHAR2(30 BYTE),
  reg VARCHAR2(30 BYTE),
  city VARCHAR2(30 BYTE),
  st VARCHAR2(30 BYTE),
  rs_region VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_topp_telecom_territories ADD SUPPLEMENTAL LOG GROUP dmtsora1526267568_0 (city, div, reg, rs_region, st) ALWAYS;