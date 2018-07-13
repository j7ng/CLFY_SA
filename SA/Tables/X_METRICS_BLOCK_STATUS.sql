CREATE TABLE sa.x_metrics_block_status (
  objid NUMBER NOT NULL,
  x_esn VARCHAR2(30 BYTE),
  x_reason VARCHAR2(255 BYTE),
  block_status2web_user NUMBER,
  block_status2pgm_enroll NUMBER,
  x_rule_category VARCHAR2(255 BYTE)
);
ALTER TABLE sa.x_metrics_block_status ADD SUPPLEMENTAL LOG GROUP dmtsora127355880_0 (block_status2pgm_enroll, block_status2web_user, objid, x_esn, x_reason, x_rule_category) ALWAYS;