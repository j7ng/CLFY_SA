CREATE TABLE sa.x_rule_category_master (
  objid NUMBER NOT NULL,
  x_rule_cat_name VARCHAR2(255 BYTE),
  x_rule_cat_desc VARCHAR2(255 BYTE),
  x_update_stamp DATE,
  x_update_status VARCHAR2(1 BYTE),
  x_update_user VARCHAR2(255 BYTE),
  x_max_rules_per_cat NUMBER(3),
  x_max_cond_per_rule NUMBER(3),
  x_rule_version NUMBER(10)
);
ALTER TABLE sa.x_rule_category_master ADD SUPPLEMENTAL LOG GROUP dmtsora546350394_0 (objid, x_max_cond_per_rule, x_max_rules_per_cat, x_rule_cat_desc, x_rule_cat_name, x_rule_version, x_update_stamp, x_update_status, x_update_user) ALWAYS;