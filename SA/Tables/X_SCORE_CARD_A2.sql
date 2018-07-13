CREATE TABLE sa.x_score_card_a2 (
  esn VARCHAR2(30 BYTE),
  "MIN" VARCHAR2(30 BYTE),
  start_date DATE,
  card_due_date DATE,
  x_zipcode VARCHAR2(20 BYTE),
  region VARCHAR2(40 BYTE)
);
ALTER TABLE sa.x_score_card_a2 ADD SUPPLEMENTAL LOG GROUP dmtsora545712186_0 (card_due_date, esn, "MIN", region, start_date, x_zipcode) ALWAYS;