CREATE TABLE sa.x_c_score_card_combine (
  county VARCHAR2(50 BYTE),
  st VARCHAR2(10 BYTE),
  x_mkt_submkt_name VARCHAR2(30 BYTE),
  x_carrier_name VARCHAR2(30 BYTE),
  cnt NUMBER
);
ALTER TABLE sa.x_c_score_card_combine ADD SUPPLEMENTAL LOG GROUP dmtsora1037011827_0 (cnt, county, st, x_carrier_name, x_mkt_submkt_name) ALWAYS;