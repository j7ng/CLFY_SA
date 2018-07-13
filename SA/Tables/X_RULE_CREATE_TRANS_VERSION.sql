CREATE TABLE sa.x_rule_create_trans_version (
  objid NUMBER,
  x_rule_set_name VARCHAR2(255 BYTE),
  x_rule_set_desc VARCHAR2(255 BYTE),
  x_rule_act_param VARCHAR2(255 BYTE),
  x_rule_priority NUMBER(3),
  x_rule_version NUMBER(10),
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE),
  set_trans2rule_cat_mas NUMBER,
  set_trans2rule_act_mas NUMBER,
  set_trans2rule_atm_mas NUMBER,
  set_trans2rule_msg_mas NUMBER,
  version2create_trans NUMBER,
  x_rule_notify_param VARCHAR2(255 BYTE),
  x_create_date DATE,
  x_msg_script_type VARCHAR2(20 BYTE),
  x_msg_script_id VARCHAR2(20 BYTE)
);
ALTER TABLE sa.x_rule_create_trans_version ADD SUPPLEMENTAL LOG GROUP dmtsora2012309312_0 (objid, set_trans2rule_act_mas, set_trans2rule_atm_mas, set_trans2rule_cat_mas, set_trans2rule_msg_mas, version2create_trans, x_create_date, x_rule_act_param, x_rule_notify_param, x_rule_priority, x_rule_set_desc, x_rule_set_name, x_rule_version, x_update_stamp, x_update_status, x_update_user) ALWAYS;