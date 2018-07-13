CREATE TABLE sa.batch_job_execution_context (
  job_execution_id NUMBER(19) NOT NULL,
  short_context VARCHAR2(2500 BYTE) NOT NULL,
  serialized_context CLOB,
  PRIMARY KEY (job_execution_id),
  CONSTRAINT job_exec_ctx_fk FOREIGN KEY (job_execution_id) REFERENCES sa.batch_job_execution (job_execution_id)
);