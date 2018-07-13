CREATE TABLE sa.x_score_card_county (
  county VARCHAR2(50 BYTE),
  st VARCHAR2(10 BYTE),
  action_type VARCHAR2(41 BYTE),
  carrier_mkt_name VARCHAR2(30 BYTE),
  carrier_grp_name VARCHAR2(30 BYTE),
  esn_technology VARCHAR2(20 BYTE),
  score_count NUMBER
);
ALTER TABLE sa.x_score_card_county ADD SUPPLEMENTAL LOG GROUP dmtsora1398169319_0 (action_type, carrier_grp_name, carrier_mkt_name, county, esn_technology, score_count, st) ALWAYS;