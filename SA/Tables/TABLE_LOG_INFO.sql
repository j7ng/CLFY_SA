CREATE TABLE sa.table_log_info (
  objid NUMBER,
  replaced_by VARCHAR2(30 BYTE),
  repl_by_date DATE,
  replaces VARCHAR2(30 BYTE),
  replaces_date DATE,
  part_subtype NUMBER,
  "DIMENSIONS" VARCHAR2(30 BYTE),
  weight NUMBER,
  abc_code VARCHAR2(4 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_log_info ADD SUPPLEMENTAL LOG GROUP dmtsora1145648775_0 (abc_code, dev, "DIMENSIONS", objid, part_subtype, replaced_by, replaces, replaces_date, repl_by_date, weight) ALWAYS;
COMMENT ON TABLE sa.table_log_info IS 'Reserved; future';
COMMENT ON COLUMN sa.table_log_info.objid IS 'Reserved; future';
COMMENT ON COLUMN sa.table_log_info.replaced_by IS 'Reserved; future';
COMMENT ON COLUMN sa.table_log_info.repl_by_date IS 'Reserved; future';
COMMENT ON COLUMN sa.table_log_info.replaces IS 'Reserved; future';
COMMENT ON COLUMN sa.table_log_info.replaces_date IS 'Reserved; future';
COMMENT ON COLUMN sa.table_log_info.part_subtype IS 'Reserved; future';
COMMENT ON COLUMN sa.table_log_info."DIMENSIONS" IS 'Reserved; future';
COMMENT ON COLUMN sa.table_log_info.weight IS 'Reserved; future';
COMMENT ON COLUMN sa.table_log_info.abc_code IS 'Reserved; future';
COMMENT ON COLUMN sa.table_log_info.dev IS 'Row version number for mobile distribution purposes';