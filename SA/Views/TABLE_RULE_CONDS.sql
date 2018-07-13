CREATE OR REPLACE FORCE VIEW sa.table_rule_conds (cond_objid,rule_objid,"TYPE","OPERATOR",operand1,op1_type,operand2,op2_type) AS
select table_rule_cond.objid, table_rule_cond.parentrule2com_tmplte,
 table_rule_cond.type, table_rule_cond.operator,
 table_rule_cond.operand1, table_rule_cond.op1_type,
 table_rule_cond.operand2, table_rule_cond.op2_type
 from table_rule_cond
 where table_rule_cond.parentrule2com_tmplte IS NOT NULL
 ;
COMMENT ON TABLE sa.table_rule_conds IS 'Template for the rule condition';
COMMENT ON COLUMN sa.table_rule_conds.cond_objid IS 'Rule cond internal record number';
COMMENT ON COLUMN sa.table_rule_conds.rule_objid IS 'Com_tmplte internal record number';
COMMENT ON COLUMN sa.table_rule_conds."TYPE" IS 'Internal designation of type of rule condition';
COMMENT ON COLUMN sa.table_rule_conds."OPERATOR" IS 'Relational operator of rule condition';
COMMENT ON COLUMN sa.table_rule_conds.operand1 IS 'First operand of the rule condition';
COMMENT ON COLUMN sa.table_rule_conds.op1_type IS 'Type of the first operand';
COMMENT ON COLUMN sa.table_rule_conds.operand2 IS 'Second operand of the rule condition';
COMMENT ON COLUMN sa.table_rule_conds.op2_type IS 'Type of the second operand';