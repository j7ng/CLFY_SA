CREATE TABLE sa.table_rule_cond (
  objid NUMBER,
  "TYPE" NUMBER,
  "OPERATOR" NUMBER,
  operand1 VARCHAR2(255 BYTE),
  op1_type NUMBER,
  operand2 VARCHAR2(255 BYTE),
  op2_type NUMBER,
  dev NUMBER,
  parentrule2com_tmplte NUMBER(*,0),
  parentcond2rule_cond NUMBER(*,0)
);
ALTER TABLE sa.table_rule_cond ADD SUPPLEMENTAL LOG GROUP dmtsora69225630_0 (dev, objid, op1_type, op2_type, operand1, operand2, "OPERATOR", parentcond2rule_cond, parentrule2com_tmplte, "TYPE") ALWAYS;