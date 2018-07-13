CREATE TABLE sa.table_csc_expression (
  objid NUMBER,
  relation VARCHAR2(30 BYTE),
  server_id NUMBER,
  dev NUMBER,
  nested2csc_expression NUMBER(*,0),
  text2csc_product NUMBER(*,0),
  text2csc_resolution NUMBER(*,0),
  text2csc_admin NUMBER(*,0),
  text2csc_problem NUMBER(*,0)
);
ALTER TABLE sa.table_csc_expression ADD SUPPLEMENTAL LOG GROUP dmtsora1104736906_0 (dev, nested2csc_expression, objid, relation, server_id, text2csc_admin, text2csc_problem, text2csc_product, text2csc_resolution) ALWAYS;
COMMENT ON TABLE sa.table_csc_expression IS 'Used when multiple STATEMENTs define a PROBLEM or RESOLUTION. The EXPRESSION form enables a Boolean (true/false) expression defining relationships between the statements using the relations: AND, OR, and NOT';
COMMENT ON COLUMN sa.table_csc_expression.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_csc_expression.relation IS 'Relation governing this expression. Default=AND for list of statements. Other values are: AND_ORDERED, AND_UNORDERED, OR_ORDERED, OR_UNORDED, NOT';
COMMENT ON COLUMN sa.table_csc_expression.server_id IS 'Exchange prodocol server ID number';
COMMENT ON COLUMN sa.table_csc_expression.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_csc_expression.nested2csc_expression IS 'Nested expression to allow complex Boolean expressions to be represented';
COMMENT ON COLUMN sa.table_csc_expression.text2csc_product IS 'Product identified by the expression';
COMMENT ON COLUMN sa.table_csc_expression.text2csc_resolution IS 'Resolution stated with the expression';
COMMENT ON COLUMN sa.table_csc_expression.text2csc_admin IS 'Related CSC expression';
COMMENT ON COLUMN sa.table_csc_expression.text2csc_problem IS 'Problem stated with the expression';