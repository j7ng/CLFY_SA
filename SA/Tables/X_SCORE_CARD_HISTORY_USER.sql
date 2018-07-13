CREATE TABLE sa.x_score_card_history_user (
  score_date DATE,
  login_name VARCHAR2(30 BYTE),
  first_name VARCHAR2(30 BYTE),
  last_name VARCHAR2(30 BYTE),
  esn_technology VARCHAR2(30 BYTE),
  "ACTIVE" NUMBER,
  act NUMBER,
  deact NUMBER,
  react NUMBER,
  red_act NUMBER,
  red_cs NUMBER,
  red_free NUMBER,
  red_paid NUMBER,
  red_rt NUMBER,
  red_paid_cost NUMBER,
  esn_part_number_product_code NUMBER
);
ALTER TABLE sa.x_score_card_history_user ADD SUPPLEMENTAL LOG GROUP dmtsora1118835565_0 (act, "ACTIVE", deact, esn_part_number_product_code, esn_technology, first_name, last_name, login_name, react, red_act, red_cs, red_free, red_paid, red_paid_cost, red_rt, score_date) ALWAYS;