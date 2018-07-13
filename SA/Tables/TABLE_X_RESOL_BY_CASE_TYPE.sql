CREATE TABLE sa.table_x_resol_by_case_type (
  objid NUMBER,
  dev NUMBER,
  case_type2hgbst_elm NUMBER,
  resol_code2gbst_elm NUMBER
);
ALTER TABLE sa.table_x_resol_by_case_type ADD SUPPLEMENTAL LOG GROUP dmtsora548532252_0 (case_type2hgbst_elm, dev, objid, resol_code2gbst_elm) ALWAYS;
COMMENT ON TABLE sa.table_x_resol_by_case_type IS 'relation between case types and the appropriate resolution codes';
COMMENT ON COLUMN sa.table_x_resol_by_case_type.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_resol_by_case_type.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_resol_by_case_type.case_type2hgbst_elm IS 'TBD';
COMMENT ON COLUMN sa.table_x_resol_by_case_type.resol_code2gbst_elm IS 'TBD';