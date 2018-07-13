CREATE TABLE sa.x_job_run_details (
  objid NUMBER,
  x_scheduled_run_date DATE,
  x_actual_run_date DATE,
  x_status VARCHAR2(30 BYTE),
  x_job_run_mode NUMBER,
  x_start_time DATE,
  x_end_time DATE,
  run_details2job_master NUMBER,
  x_priority NUMBER,
  x_status_code NUMBER,
  x_insert_date DATE,
  x_sub_sourcesystem VARCHAR2(30 BYTE),
  owner_name VARCHAR2(30 BYTE),
  x_reason VARCHAR2(20 BYTE),
  job_data_id VARCHAR2(20 BYTE),
  x_source_table VARCHAR2(80 BYTE),
  approved_by VARCHAR2(30 BYTE),
  approved_date DATE
);
ALTER TABLE sa.x_job_run_details ADD SUPPLEMENTAL LOG GROUP dmtsora616261411_0 (objid, run_details2job_master, x_actual_run_date, x_end_time, x_job_run_mode, x_scheduled_run_date, x_start_time, x_status) ALWAYS;