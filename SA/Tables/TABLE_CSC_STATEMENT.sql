CREATE TABLE sa.table_csc_statement (
  objid NUMBER,
  csc_role NUMBER,
  statement_text LONG,
  relation VARCHAR2(30 BYTE),
  "VALUE" VARCHAR2(80 BYTE),
  csc_order VARCHAR2(10 BYTE),
  relevance NUMBER,
  server_id NUMBER,
  dev NUMBER,
  text2csc_expression NUMBER(*,0)
);
ALTER TABLE sa.table_csc_statement ADD SUPPLEMENTAL LOG GROUP dmtsora1633339701_0 (csc_order, csc_role, dev, objid, relation, relevance, server_id, text2csc_expression, "VALUE") ALWAYS;
COMMENT ON TABLE sa.table_csc_statement IS 'The CSC STATEMENT form stores the core content of the solution document. It contains the actual text describing a situation, relevant background information, and its resolution';
COMMENT ON COLUMN sa.table_csc_statement.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_csc_statement.csc_role IS 'The role of the statement: i.e., 0=description, 1=symptom, 2=error_message, 3=objective, 4=evidence, 5=cause, 6=work_around, 7=fix, 8=answer, 9=keyword';
COMMENT ON COLUMN sa.table_csc_statement.statement_text IS 'A textual representation of the statement';
COMMENT ON COLUMN sa.table_csc_statement.relation IS 'Shows the relationship of the Feature to the Value, the default is ';
COMMENT ON COLUMN sa.table_csc_statement."VALUE" IS 'The specific value of the feature for this particular problem statement';
COMMENT ON COLUMN sa.table_csc_statement.csc_order IS 'Order for sequential statements';
COMMENT ON COLUMN sa.table_csc_statement.relevance IS 'Number representing the importance of this statement in defining';
COMMENT ON COLUMN sa.table_csc_statement.server_id IS 'Exchange prodocol server ID number';
COMMENT ON COLUMN sa.table_csc_statement.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_csc_statement.text2csc_expression IS 'Expression for which the statement is a component';