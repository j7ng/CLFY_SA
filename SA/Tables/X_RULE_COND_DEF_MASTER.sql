CREATE TABLE sa.x_rule_cond_def_master (
  objid NUMBER,
  x_rule_cond_1_lhs VARCHAR2(255 BYTE),
  x_rule_cond_1_rhs VARCHAR2(255 BYTE),
  x_rule_cond_1_type VARCHAR2(255 BYTE),
  x_rule_cond_2_lhs VARCHAR2(255 BYTE),
  x_rule_cond_2_rhs VARCHAR2(255 BYTE),
  x_rule_cond_2_type VARCHAR2(255 BYTE),
  x_rule_cond_query_temp VARCHAR2(4000 BYTE),
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE),
  def_mas2cat_mas NUMBER
);
ALTER TABLE sa.x_rule_cond_def_master ADD SUPPLEMENTAL LOG GROUP dmtsora1367025458_0 (def_mas2cat_mas, objid, x_rule_cond_1_lhs, x_rule_cond_1_rhs, x_rule_cond_1_type, x_rule_cond_2_lhs, x_rule_cond_2_rhs, x_rule_cond_2_type, x_rule_cond_query_temp, x_update_stamp, x_update_status, x_update_user) ALWAYS;