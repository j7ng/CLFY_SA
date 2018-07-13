CREATE TABLE sa.x_rule_action_master (
  objid NUMBER NOT NULL,
  act_mas2cat_mas NUMBER(10),
  x_rule_act_name VARCHAR2(255 BYTE),
  x_rule_act_class_name VARCHAR2(4000 BYTE),
  x_rule_act_parameter VARCHAR2(255 BYTE),
  x_rule_act_exe_flag_code VARCHAR2(1 BYTE),
  x_update_stamp DATE,
  x_update_status VARCHAR2(30 BYTE),
  x_update_user VARCHAR2(255 BYTE)
);
ALTER TABLE sa.x_rule_action_master ADD SUPPLEMENTAL LOG GROUP dmtsora1956836826_0 (act_mas2cat_mas, objid, x_rule_act_class_name, x_rule_act_exe_flag_code, x_rule_act_name, x_rule_act_parameter, x_update_stamp, x_update_status, x_update_user) ALWAYS;