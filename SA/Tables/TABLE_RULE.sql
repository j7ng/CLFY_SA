CREATE TABLE sa.table_rule (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  operation VARCHAR2(80 BYTE),
  rule_text LONG,
  dev NUMBER
);
ALTER TABLE sa.table_rule ADD SUPPLEMENTAL LOG GROUP dmtsora548115283_0 (dev, objid, operation, title) ALWAYS;