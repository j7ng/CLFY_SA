CREATE TABLE sa.x_rpt_redemption_audit (
  x_smp VARCHAR2(30 BYTE),
  units NUMBER,
  x_date DATE
);
ALTER TABLE sa.x_rpt_redemption_audit ADD SUPPLEMENTAL LOG GROUP dmtsora711403563_0 (units, x_date, x_smp) ALWAYS;