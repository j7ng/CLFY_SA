CREATE TABLE sa.x_score_card_region_dealer (
  score_date DATE,
  region VARCHAR2(40 BYTE),
  dealer_name VARCHAR2(80 BYTE),
  "ACTIVE" NUMBER,
  act NUMBER,
  react NUMBER,
  deact NUMBER,
  red_paid NUMBER,
  red_rt NUMBER,
  red_act NUMBER,
  red_cs NUMBER,
  red_free NUMBER
);
ALTER TABLE sa.x_score_card_region_dealer ADD SUPPLEMENTAL LOG GROUP dmtsora193279437_0 (act, "ACTIVE", deact, dealer_name, react, red_act, red_cs, red_free, red_paid, red_rt, region, score_date) ALWAYS;