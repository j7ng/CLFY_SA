CREATE TABLE sa.x_scoring_esn (
  x_esn VARCHAR2(30 BYTE) NOT NULL,
  x_score VARCHAR2(15 BYTE) NOT NULL,
  x_promo_flag NUMBER
);
ALTER TABLE sa.x_scoring_esn ADD SUPPLEMENTAL LOG GROUP dmtsora2143104409_0 (x_esn, x_promo_flag, x_score) ALWAYS;