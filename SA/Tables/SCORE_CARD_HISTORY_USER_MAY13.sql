CREATE TABLE sa.score_card_history_user_may13 (
  score_date DATE,
  login_name VARCHAR2(30 BYTE),
  first_name VARCHAR2(30 BYTE),
  last_name VARCHAR2(30 BYTE),
  "ACTIVE" NUMBER,
  act NUMBER,
  deact NUMBER,
  react NUMBER,
  red_act NUMBER,
  red_cs NUMBER,
  red_free NUMBER,
  red_paid NUMBER,
  red_rt NUMBER,
  red_paid_cost NUMBER
);
ALTER TABLE sa.score_card_history_user_may13 ADD SUPPLEMENTAL LOG GROUP dmtsora36271129_0 (act, "ACTIVE", deact, first_name, last_name, login_name, react, red_act, red_cs, red_free, red_paid, red_paid_cost, red_rt, score_date) ALWAYS;