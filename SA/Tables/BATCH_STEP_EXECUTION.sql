CREATE TABLE sa.batch_step_execution (
  step_execution_id NUMBER(19) NOT NULL,
  "VERSION" NUMBER(19) NOT NULL,
  step_name VARCHAR2(100 BYTE) NOT NULL,
  job_execution_id NUMBER(19) NOT NULL,
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP,
  status VARCHAR2(10 BYTE),
  commit_count NUMBER(19),
  read_count NUMBER(19),
  filter_count NUMBER(19),
  write_count NUMBER(19),
  read_skip_count NUMBER(19),
  write_skip_count NUMBER(19),
  process_skip_count NUMBER(19),
  rollback_count NUMBER(19),
  exit_code VARCHAR2(2500 BYTE),
  exit_message VARCHAR2(2500 BYTE),
  last_updated TIMESTAMP,
  PRIMARY KEY (step_execution_id),
  CONSTRAINT job_exec_step_fk FOREIGN KEY (job_execution_id) REFERENCES sa.batch_job_execution (job_execution_id)
);