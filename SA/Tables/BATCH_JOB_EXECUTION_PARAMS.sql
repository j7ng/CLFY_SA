CREATE TABLE sa.batch_job_execution_params (
  job_execution_id NUMBER(19) NOT NULL,
  type_cd VARCHAR2(6 BYTE) NOT NULL,
  key_name VARCHAR2(100 BYTE) NOT NULL,
  string_val VARCHAR2(250 BYTE),
  date_val TIMESTAMP,
  long_val NUMBER(19),
  double_val NUMBER,
  identifying CHAR NOT NULL,
  CONSTRAINT job_exec_params_fk FOREIGN KEY (job_execution_id) REFERENCES sa.batch_job_execution (job_execution_id)
);