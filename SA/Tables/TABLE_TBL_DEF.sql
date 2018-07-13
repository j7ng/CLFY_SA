CREATE TABLE sa.table_tbl_def (
  objid NUMBER,
  dev NUMBER,
  "NAME" VARCHAR2(64 BYTE),
  "TYPE" VARCHAR2(6 BYTE),
  process_date DATE,
  base NUMBER,
  modify_flag NUMBER,
  internal NUMBER
);
ALTER TABLE sa.table_tbl_def ADD SUPPLEMENTAL LOG GROUP dmtsora969708624_0 (base, dev, internal, modify_flag, "NAME", objid, process_date, "TYPE") ALWAYS;
COMMENT ON TABLE sa.table_tbl_def IS 'Defines FML field tables used by Process Manager';
COMMENT ON COLUMN sa.table_tbl_def.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_tbl_def.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_tbl_def."NAME" IS 'Name of the table file. Note that only simple names should be used (paths defined by FLDTBLDIRS32)';
COMMENT ON COLUMN sa.table_tbl_def."TYPE" IS 'Indicates the type of file, either Export or Import';
COMMENT ON COLUMN sa.table_tbl_def.process_date IS 'Date/time of last operation (import or export)';
COMMENT ON COLUMN sa.table_tbl_def.base IS 'The *base value for the file, on export';
COMMENT ON COLUMN sa.table_tbl_def.modify_flag IS 'Set to 1 if the table has been modified but not exported';
COMMENT ON COLUMN sa.table_tbl_def.internal IS 'Set to 1 if the fields are for internal use, and not available in service requests';