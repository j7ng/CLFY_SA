CREATE TABLE sa.x_score_card_history_road (
  score_date DATE,
  score_type VARCHAR2(100 BYTE),
  score_code VARCHAR2(100 BYTE),
  score_name VARCHAR2(100 BYTE),
  score_count NUMBER
);
ALTER TABLE sa.x_score_card_history_road ADD SUPPLEMENTAL LOG GROUP dmtsora1986676675_0 (score_code, score_count, score_date, score_name, score_type) ALWAYS;