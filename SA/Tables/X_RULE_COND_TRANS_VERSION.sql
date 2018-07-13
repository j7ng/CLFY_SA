CREATE TABLE sa.x_rule_cond_trans_version (
  objid NUMBER,
  x_rule_cond_1 VARCHAR2(255 BYTE),
  x_rule_eval_1 VARCHAR2(255 BYTE),
  x_rule_param_1 VARCHAR2(255 BYTE),
  x_rule_cond_2 VARCHAR2(255 BYTE),
  x_rule_eval_2 VARCHAR2(255 BYTE),
  x_rule_param_2 VARCHAR2(255 BYTE),
  x_rule_cond_query VARCHAR2(4000 BYTE),
  x_rule_version NUMBER(10),
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE),
  cond_trans2create_trans NUMBER,
  version2cond_trans NUMBER,
  x_rule_cond_desc VARCHAR2(1000 BYTE)
);
ALTER TABLE sa.x_rule_cond_trans_version ADD SUPPLEMENTAL LOG GROUP dmtsora1054786441_0 (cond_trans2create_trans, objid, version2cond_trans, x_rule_cond_1, x_rule_cond_2, x_rule_cond_desc, x_rule_cond_query, x_rule_eval_1, x_rule_eval_2, x_rule_param_1, x_rule_param_2, x_rule_version, x_update_stamp, x_update_status, x_update_user) ALWAYS;