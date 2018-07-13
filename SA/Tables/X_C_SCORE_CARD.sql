CREATE TABLE sa.x_c_score_card (
  esn VARCHAR2(30 BYTE),
  "MIN" VARCHAR2(30 BYTE),
  x_zipcode VARCHAR2(20 BYTE),
  county VARCHAR2(50 BYTE),
  st VARCHAR2(10 BYTE),
  x_mkt_submkt_name VARCHAR2(30 BYTE),
  x_carrier_name VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_c_score_card ADD SUPPLEMENTAL LOG GROUP dmtsora1701485829_0 (county, esn, "MIN", st, x_carrier_name, x_mkt_submkt_name, x_zipcode) ALWAYS;