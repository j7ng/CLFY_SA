CREATE TABLE sa.x_promo_marketing (
  x_score VARCHAR2(10 BYTE) NOT NULL,
  x_cardredeemed VARCHAR2(24 BYTE) NOT NULL,
  x_efective_date DATE NOT NULL,
  x_expiration_date DATE NOT NULL,
  x_script VARCHAR2(10 BYTE) NOT NULL,
  x_act_type NUMBER NOT NULL,
  x_soure_system VARCHAR2(10 BYTE),
  x_promo_type VARCHAR2(10 BYTE) NOT NULL,
  x_promo_pos NUMBER
);
ALTER TABLE sa.x_promo_marketing ADD SUPPLEMENTAL LOG GROUP dmtsora1206021945_0 (x_act_type, x_cardredeemed, x_efective_date, x_expiration_date, x_promo_pos, x_promo_type, x_score, x_script, x_soure_system) ALWAYS;