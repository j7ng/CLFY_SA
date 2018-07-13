CREATE TABLE sa.x_metrics_cc_block (
  objid NUMBER NOT NULL,
  x_credit_card_number NUMBER,
  x_reason VARCHAR2(255 BYTE),
  x_rule_category VARCHAR2(255 BYTE)
);
ALTER TABLE sa.x_metrics_cc_block ADD SUPPLEMENTAL LOG GROUP dmtsora1165110076_0 (objid, x_credit_card_number, x_reason, x_rule_category) ALWAYS;