CREATE TABLE sa.x_rule_version (
  objid NUMBER,
  x_rule_version_number NUMBER(10),
  x_rule_version_action VARCHAR2(50 BYTE),
  rule_ver2table_user NUMBER,
  x_update_stamp DATE
);
ALTER TABLE sa.x_rule_version ADD SUPPLEMENTAL LOG GROUP dmtsora1544068663_0 (objid, rule_ver2table_user, x_rule_version_action, x_rule_version_number, x_update_stamp) ALWAYS;