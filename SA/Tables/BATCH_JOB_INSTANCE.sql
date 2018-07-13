CREATE TABLE sa.batch_job_instance (
  job_instance_id NUMBER(19) NOT NULL,
  "VERSION" NUMBER(19),
  job_name VARCHAR2(100 BYTE) NOT NULL,
  job_key VARCHAR2(32 BYTE) NOT NULL,
  PRIMARY KEY (job_instance_id),
  CONSTRAINT job_inst_un UNIQUE (job_name,job_key)
);