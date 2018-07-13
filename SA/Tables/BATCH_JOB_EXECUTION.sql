CREATE TABLE sa.batch_job_execution (
  job_execution_id NUMBER(19) NOT NULL,
  "VERSION" NUMBER(19),
  job_instance_id NUMBER(19) NOT NULL,
  create_time TIMESTAMP NOT NULL,
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  status VARCHAR2(10 BYTE),
  exit_code VARCHAR2(2500 BYTE),
  exit_message VARCHAR2(2500 BYTE),
  last_updated TIMESTAMP,
  job_configuration_location VARCHAR2(2500 BYTE),
  PRIMARY KEY (job_execution_id),
  CONSTRAINT job_inst_exec_fk FOREIGN KEY (job_instance_id) REFERENCES sa.batch_job_instance (job_instance_id)
);