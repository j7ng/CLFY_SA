CREATE TABLE sa.adfcrm_solution_files (
  file_id NUMBER,
  file_description VARCHAR2(50 BYTE),
  file_type VARCHAR2(30 BYTE),
  file_blob BLOB,
  changed_date DATE DEFAULT SYSDATE,
  changed_by VARCHAR2(50 BYTE),
  change_type VARCHAR2(100 BYTE)
);
COMMENT ON TABLE sa.adfcrm_solution_files IS 'All solution files.';
COMMENT ON COLUMN sa.adfcrm_solution_files.file_id IS 'Internal identifier for the file.';
COMMENT ON COLUMN sa.adfcrm_solution_files.file_description IS 'The description of the file.';
COMMENT ON COLUMN sa.adfcrm_solution_files.file_type IS 'File type';
COMMENT ON COLUMN sa.adfcrm_solution_files.file_blob IS 'File Binary Large Object.';
COMMENT ON COLUMN sa.adfcrm_solution_files.changed_date IS 'Date in which the change was done';
COMMENT ON COLUMN sa.adfcrm_solution_files.changed_by IS 'User that perform the change';
COMMENT ON COLUMN sa.adfcrm_solution_files.change_type IS 'Type of change INSERT/DELETE/UPDATE';