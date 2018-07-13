CREATE TABLE sa.x_score_card_history_bak (
  score_date DATE,
  score_technology VARCHAR2(100 BYTE),
  score_type VARCHAR2(100 BYTE),
  score_code VARCHAR2(100 BYTE),
  score_name VARCHAR2(100 BYTE),
  score_count NUMBER
);
ALTER TABLE sa.x_score_card_history_bak ADD SUPPLEMENTAL LOG GROUP dmtsora1226598708_0 (score_code, score_count, score_date, score_name, score_technology, score_type) ALWAYS;