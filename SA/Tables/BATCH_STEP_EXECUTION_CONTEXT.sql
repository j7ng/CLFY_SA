CREATE TABLE sa.batch_step_execution_context (
  step_execution_id NUMBER(19) NOT NULL,
  short_context VARCHAR2(2500 BYTE) NOT NULL,
  serialized_context CLOB,
  PRIMARY KEY (step_execution_id),
  CONSTRAINT step_exec_ctx_fk FOREIGN KEY (step_execution_id) REFERENCES sa.batch_step_execution (step_execution_id)
);