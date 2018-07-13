CREATE TABLE sa.x_metrics_blk_data_serv (
  objid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_reason VARCHAR2(255 BYTE),
  block_status2contact NUMBER,
  x_rule_category VARCHAR2(255 BYTE)
);
ALTER TABLE sa.x_metrics_blk_data_serv ADD SUPPLEMENTAL LOG GROUP dmtsora793304616_0 (block_status2contact, objid, x_esn, x_reason, x_rule_category) ALWAYS;