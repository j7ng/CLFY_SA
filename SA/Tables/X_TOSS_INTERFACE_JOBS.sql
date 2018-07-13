CREATE TABLE sa.x_toss_interface_jobs (
  objid NUMBER,
  program_name VARCHAR2(80 BYTE),
  start_date DATE,
  end_date DATE,
  rows_processed NUMBER,
  status VARCHAR2(20 BYTE),
  cycle_number VARCHAR2(10 BYTE),
  file_name VARCHAR2(25 BYTE)
);
ALTER TABLE sa.x_toss_interface_jobs ADD SUPPLEMENTAL LOG GROUP dmtsora901452257_0 (cycle_number, end_date, file_name, objid, program_name, rows_processed, start_date, status) ALWAYS;