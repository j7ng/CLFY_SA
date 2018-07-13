CREATE TABLE sa.adfcrm_mtm_solution2task_flows (
  task_id NUMBER NOT NULL,
  solution_id NUMBER NOT NULL,
  case_conf_hdr_id NUMBER NOT NULL,
  changed_date DATE DEFAULT SYSDATE,
  changed_by VARCHAR2(50 BYTE),
  change_type VARCHAR2(100 BYTE),
  CONSTRAINT adfcrm_mtm_sol2task_flows_pk PRIMARY KEY (task_id,solution_id,case_conf_hdr_id),
  CONSTRAINT adfcrm_mtm_sol2task_flows_fk1 FOREIGN KEY (task_id) REFERENCES sa.adfcrm_task_flows (task_id),
  CONSTRAINT adfcrm_mtm_sol2task_flows_fk2 FOREIGN KEY (solution_id) REFERENCES sa.adfcrm_solution (solution_id)
);
COMMENT ON TABLE sa.adfcrm_mtm_solution2task_flows IS 'Many to many relation between tasks and solutions.';
COMMENT ON COLUMN sa.adfcrm_mtm_solution2task_flows.task_id IS 'References to task_flows.task_id';
COMMENT ON COLUMN sa.adfcrm_mtm_solution2task_flows.solution_id IS 'References to solution.solution_id';
COMMENT ON COLUMN sa.adfcrm_mtm_solution2task_flows.case_conf_hdr_id IS 'OBJID OF TABLE TABLE_X_CASE_CONF_HDR.';
COMMENT ON COLUMN sa.adfcrm_mtm_solution2task_flows.changed_date IS 'Date in which the change was done';
COMMENT ON COLUMN sa.adfcrm_mtm_solution2task_flows.changed_by IS 'User that perform the change';
COMMENT ON COLUMN sa.adfcrm_mtm_solution2task_flows.change_type IS 'Type of change INSERT/DELETE/UPDATE';