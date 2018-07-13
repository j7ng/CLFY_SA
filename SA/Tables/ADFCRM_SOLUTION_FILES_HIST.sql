CREATE TABLE sa.adfcrm_solution_files_hist (
  file_id NUMBER,
  file_description VARCHAR2(50 BYTE),
  file_type VARCHAR2(30 BYTE),
  file_blob BLOB,
  changed_date DATE,
  changed_by VARCHAR2(50 BYTE),
  change_type VARCHAR2(100 BYTE)
);