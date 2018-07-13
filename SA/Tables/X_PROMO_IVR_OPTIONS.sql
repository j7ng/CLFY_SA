CREATE TABLE sa.x_promo_ivr_options (
  x_script VARCHAR2(10 BYTE) NOT NULL,
  x_promonow NUMBER(10),
  x_promofuture NUMBER(10),
  x_op_order NUMBER(5) NOT NULL,
  x_promocode VARCHAR2(24 BYTE) NOT NULL,
  x_customerval VARCHAR2(50 BYTE),
  x_promotype VARCHAR2(10 BYTE) NOT NULL
);
ALTER TABLE sa.x_promo_ivr_options ADD SUPPLEMENTAL LOG GROUP dmtsora179297910_0 (x_customerval, x_op_order, x_promocode, x_promofuture, x_promonow, x_promotype, x_script) ALWAYS;