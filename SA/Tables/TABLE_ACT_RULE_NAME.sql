CREATE TABLE sa.table_act_rule_name (
  objid NUMBER,
  parent_type NUMBER,
  act_code NUMBER,
  rule_name VARCHAR2(80 BYTE),
  flags NUMBER,
  flags2 NUMBER,
  flags3 NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_act_rule_name ADD SUPPLEMENTAL LOG GROUP dmtsora1468798041_0 (act_code, dev, flags, flags2, flags3, objid, parent_type, rule_name) ALWAYS;