CREATE TABLE sa.adfcrm_task_flows (
  task_id NUMBER NOT NULL,
  task_name VARCHAR2(100 BYTE) NOT NULL,
  task_flow_id VARCHAR2(100 BYTE) NOT NULL,
  changed_date DATE DEFAULT SYSDATE,
  changed_by VARCHAR2(50 BYTE),
  change_type VARCHAR2(100 BYTE),
  CONSTRAINT adfcrm_task_flows_pk PRIMARY KEY (task_id),
  CONSTRAINT adfcrm_task_flows_uk UNIQUE (task_name,task_flow_id)
);
COMMENT ON TABLE sa.adfcrm_task_flows IS 'All tasks currently underway.';
COMMENT ON COLUMN sa.adfcrm_task_flows.task_id IS 'internal unique identifier for the tasks.';
COMMENT ON COLUMN sa.adfcrm_task_flows.task_name IS 'Link name.';
COMMENT ON COLUMN sa.adfcrm_task_flows.task_flow_id IS 'Flow id of the task in ADF.';
COMMENT ON COLUMN sa.adfcrm_task_flows.changed_date IS 'Date in which the change was done';
COMMENT ON COLUMN sa.adfcrm_task_flows.changed_by IS 'User that perform the change';
COMMENT ON COLUMN sa.adfcrm_task_flows.change_type IS 'Type of change INSERT/DELETE/UPDATE';