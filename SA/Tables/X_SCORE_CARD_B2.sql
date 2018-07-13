CREATE TABLE sa.x_score_card_b2 (
  esn VARCHAR2(30 BYTE),
  "MIN" VARCHAR2(30 BYTE),
  start_date DATE,
  card_due_date DATE,
  x_zipcode VARCHAR2(20 BYTE),
  region VARCHAR2(40 BYTE),
  dma VARCHAR2(100 BYTE),
  "STATE" VARCHAR2(100 BYTE)
);
ALTER TABLE sa.x_score_card_b2 ADD SUPPLEMENTAL LOG GROUP dmtsora775452687_0 (card_due_date, dma, esn, "MIN", region, start_date, "STATE", x_zipcode) ALWAYS;