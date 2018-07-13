CREATE TABLE sa.x_job_errors (
  objid NUMBER,
  x_source_job_id VARCHAR2(20 BYTE),
  x_request_type VARCHAR2(50 BYTE),
  x_request VARCHAR2(4000 BYTE),
  ordinal NUMBER,
  x_status_code NUMBER,
  x_reject NUMBER,
  x_insert_date DATE,
  x_update_date DATE,
  x_resent NUMBER,
  x_error_msg VARCHAR2(2048 BYTE)
);