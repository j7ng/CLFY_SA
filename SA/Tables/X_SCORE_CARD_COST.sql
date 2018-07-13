CREATE TABLE sa.x_score_card_cost (
  x_units NUMBER,
  x_price NUMBER
);
ALTER TABLE sa.x_score_card_cost ADD SUPPLEMENTAL LOG GROUP dmtsora1721111868_0 (x_price, x_units) ALWAYS;