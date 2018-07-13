CREATE TABLE sa.x_c_score_card_combine2 (
  county VARCHAR2(50 BYTE),
  st VARCHAR2(10 BYTE),
  x_mkt_submkt_name VARCHAR2(30 BYTE),
  x_carrier_name VARCHAR2(30 BYTE),
  esn_technology VARCHAR2(20 BYTE),
  cnt NUMBER
);
ALTER TABLE sa.x_c_score_card_combine2 ADD SUPPLEMENTAL LOG GROUP dmtsora1790007432_0 (cnt, county, esn_technology, st, x_carrier_name, x_mkt_submkt_name) ALWAYS;