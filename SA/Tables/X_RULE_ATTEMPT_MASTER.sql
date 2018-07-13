CREATE TABLE sa.x_rule_attempt_master (
  objid NUMBER,
  attm_mas2cat_mas NUMBER,
  x_rule_amt_desc VARCHAR2(255 BYTE),
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE)
);
ALTER TABLE sa.x_rule_attempt_master ADD SUPPLEMENTAL LOG GROUP dmtsora432069809_0 (attm_mas2cat_mas, objid, x_rule_amt_desc, x_update_stamp, x_update_status, x_update_user) ALWAYS;