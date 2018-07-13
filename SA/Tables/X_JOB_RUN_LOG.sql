CREATE TABLE sa.x_job_run_log (
  objid NUMBER,
  x_log_level NUMBER,
  x_messages VARCHAR2(4000 BYTE),
  x_log_date_time DATE,
  run_log2job_master NUMBER
);
ALTER TABLE sa.x_job_run_log ADD SUPPLEMENTAL LOG GROUP dmtsora1593953006_0 (objid, run_log2job_master, x_log_date_time, x_log_level, x_messages) ALWAYS;