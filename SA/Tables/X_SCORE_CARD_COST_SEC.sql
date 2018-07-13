CREATE TABLE sa.x_score_card_cost_sec (
  x_units NUMBER,
  x_price NUMBER
);
ALTER TABLE sa.x_score_card_cost_sec ADD SUPPLEMENTAL LOG GROUP dmtsora886155447_0 (x_price, x_units) ALWAYS;