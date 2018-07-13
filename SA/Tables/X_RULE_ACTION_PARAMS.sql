CREATE TABLE sa.x_rule_action_params (
  objid NUMBER,
  x_penalty NUMBER,
  x_cooling_period NUMBER,
  x_grace_period NUMBER,
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE),
  rule_param2prog_param NUMBER,
  rule_param2rule_trans NUMBER
);
ALTER TABLE sa.x_rule_action_params ADD SUPPLEMENTAL LOG GROUP dmtsora1278503855_0 (objid, rule_param2prog_param, rule_param2rule_trans, x_cooling_period, x_grace_period, x_penalty, x_update_stamp, x_update_status, x_update_user) ALWAYS;