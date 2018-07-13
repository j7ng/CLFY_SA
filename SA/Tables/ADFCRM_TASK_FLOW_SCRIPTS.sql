CREATE TABLE sa.adfcrm_task_flow_scripts (
  tfs_id NUMBER NOT NULL,
  task_id NUMBER NOT NULL,
  step NUMBER NOT NULL,
  script_type VARCHAR2(20 BYTE) NOT NULL,
  script_id VARCHAR2(20 BYTE) NOT NULL,
  changed_date DATE DEFAULT SYSDATE,
  changed_by VARCHAR2(50 BYTE),
  change_type VARCHAR2(100 BYTE),
  CONSTRAINT adfcrm_task_flow_scripts_pk PRIMARY KEY (tfs_id),
  CONSTRAINT adfcrm_task_flow_scripts_fk1 FOREIGN KEY (task_id) REFERENCES sa.adfcrm_task_flows (task_id)
);
COMMENT ON TABLE sa.adfcrm_task_flow_scripts IS 'TASK FLOW WITH RELATED SCRIPTS.';
COMMENT ON COLUMN sa.adfcrm_task_flow_scripts.tfs_id IS 'INTERNAL UNIQUE IDENTIFIER FOR RECORDS IN ADFCRM_TASK_FLOW_SCRIPTS.';
COMMENT ON COLUMN sa.adfcrm_task_flow_scripts.task_id IS 'REFERENCE TO SA.ADFCRM_TASK_FLOWS.TASK_ID.';
COMMENT ON COLUMN sa.adfcrm_task_flow_scripts.step IS 'CONSECUTIVE TO ORDER SCRIPTS.';
COMMENT ON COLUMN sa.adfcrm_task_flow_scripts.script_type IS 'REFERENCES TO TABLE_X_SCRIPTS.X_SCRIPT_TYPE.';
COMMENT ON COLUMN sa.adfcrm_task_flow_scripts.script_id IS 'REFERENCES TO TABLE_X_SCRIPTS.X_SCRIPT_ID.';
COMMENT ON COLUMN sa.adfcrm_task_flow_scripts.changed_date IS 'Date in which the change was done';
COMMENT ON COLUMN sa.adfcrm_task_flow_scripts.changed_by IS 'User that perform the change';
COMMENT ON COLUMN sa.adfcrm_task_flow_scripts.change_type IS 'Type of change INSERT/DELETE/UPDATE';