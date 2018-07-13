CREATE TABLE sa.x_promo_ivr (
  x_script VARCHAR2(10 BYTE) NOT NULL,
  x_startphrase NUMBER(10),
  x_endphrase NUMBER(10),
  x_repeate VARCHAR2(5 BYTE) NOT NULL,
  x_confirm VARCHAR2(5 BYTE) NOT NULL,
  x_exclusivepromo VARCHAR2(5 BYTE) NOT NULL,
  x_status VARCHAR2(5 BYTE) NOT NULL
);
ALTER TABLE sa.x_promo_ivr ADD SUPPLEMENTAL LOG GROUP dmtsora2009641863_0 (x_confirm, x_endphrase, x_exclusivepromo, x_repeate, x_script, x_startphrase, x_status) ALWAYS;