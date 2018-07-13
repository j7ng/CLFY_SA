CREATE TABLE sa.score_card_history_cnt_may13 (
  score_date DATE,
  county VARCHAR2(50 BYTE),
  st VARCHAR2(10 BYTE),
  carrier_mkt_name VARCHAR2(30 BYTE),
  carrier_grp_name VARCHAR2(30 BYTE),
  "ACTIVE" NUMBER,
  act NUMBER,
  deact NUMBER,
  react NUMBER,
  red_act NUMBER,
  red_cs NUMBER,
  red_free NUMBER,
  red_paid NUMBER,
  red_rt NUMBER
);
ALTER TABLE sa.score_card_history_cnt_may13 ADD SUPPLEMENTAL LOG GROUP dmtsora97725528_0 (act, "ACTIVE", carrier_grp_name, carrier_mkt_name, county, deact, react, red_act, red_cs, red_free, red_paid, red_rt, score_date, st) ALWAYS;