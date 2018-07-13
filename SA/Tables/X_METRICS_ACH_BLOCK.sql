CREATE TABLE sa.x_metrics_ach_block (
  objid NUMBER,
  met_ach_b2bank_acc NUMBER,
  x_reason VARCHAR2(255 BYTE),
  x_rule_category VARCHAR2(255 BYTE)
);
ALTER TABLE sa.x_metrics_ach_block ADD SUPPLEMENTAL LOG GROUP dmtsora1934396267_0 (met_ach_b2bank_acc, objid, x_reason, x_rule_category) ALWAYS;