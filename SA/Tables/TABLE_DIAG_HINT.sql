CREATE TABLE sa.table_diag_hint (
  objid NUMBER,
  "STATEMENT" VARCHAR2(255 BYTE),
  s_statement VARCHAR2(255 BYTE),
  exp_level NUMBER,
  default_logic NUMBER,
  description LONG,
  exp_level_str VARCHAR2(20 BYTE),
  logic_val_str VARCHAR2(20 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_diag_hint ADD SUPPLEMENTAL LOG GROUP dmtsora326935026_0 (default_logic, dev, exp_level, exp_level_str, logic_val_str, objid, "STATEMENT", s_statement) ALWAYS;
COMMENT ON TABLE sa.table_diag_hint IS 'Diagnostic hints, questions asked by support specialist to narrow the possible solutions to callers problem';
COMMENT ON COLUMN sa.table_diag_hint.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_diag_hint."STATEMENT" IS 'True/False/Possible statement';
COMMENT ON COLUMN sa.table_diag_hint.exp_level IS 'Expertise level choices available; Beginner, Novice, etc';
COMMENT ON COLUMN sa.table_diag_hint.default_logic IS 'Default logic value of diagnostic hint';
COMMENT ON COLUMN sa.table_diag_hint.description IS 'Diagnostic hint description';
COMMENT ON COLUMN sa.table_diag_hint.exp_level_str IS 'Expertise level choices available; Beginner, Novice, etc';
COMMENT ON COLUMN sa.table_diag_hint.logic_val_str IS 'Setting of logic value choices, dependent on expertise level';
COMMENT ON COLUMN sa.table_diag_hint.dev IS 'Row version number for mobile distribution purposes';