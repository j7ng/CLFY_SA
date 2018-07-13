CREATE TABLE sa.x_score_card_hist (
  active_date DATE,
  active_type VARCHAR2(30 BYTE),
  active_name VARCHAR2(100 BYTE),
  active_count NUMBER
);
ALTER TABLE sa.x_score_card_hist ADD SUPPLEMENTAL LOG GROUP dmtsora1809633470_0 (active_count, active_date, active_name, active_type) ALWAYS;