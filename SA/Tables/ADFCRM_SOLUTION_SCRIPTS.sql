CREATE TABLE sa.adfcrm_solution_scripts (
  ss_id NUMBER NOT NULL,
  solution_id NUMBER NOT NULL,
  step NUMBER NOT NULL,
  script_type VARCHAR2(20 BYTE) NOT NULL,
  script_id VARCHAR2(20 BYTE) NOT NULL,
  changed_date DATE DEFAULT SYSDATE,
  changed_by VARCHAR2(50 BYTE),
  change_type VARCHAR2(100 BYTE),
  CONSTRAINT adfcrm_solution_scripts_pk PRIMARY KEY (ss_id),
  CONSTRAINT adfcrm_solution_scripts_uk UNIQUE (solution_id,step,script_type,script_id),
  CONSTRAINT adfcrm_solution_scripts_fk1 FOREIGN KEY (solution_id) REFERENCES sa.adfcrm_solution (solution_id)
);
COMMENT ON TABLE sa.adfcrm_solution_scripts IS 'Scripts associated with the solutions';
COMMENT ON COLUMN sa.adfcrm_solution_scripts.ss_id IS 'Internal unique identifier for the solution scripts.';
COMMENT ON COLUMN sa.adfcrm_solution_scripts.solution_id IS 'References to solution.solution_id';
COMMENT ON COLUMN sa.adfcrm_solution_scripts.step IS 'Consecutive to order scripts';
COMMENT ON COLUMN sa.adfcrm_solution_scripts.script_type IS 'References to table_x_scripts.x_script_type.';
COMMENT ON COLUMN sa.adfcrm_solution_scripts.script_id IS 'References to table_x_scripts.x_script_id.';
COMMENT ON COLUMN sa.adfcrm_solution_scripts.changed_date IS 'Date in which the change was done';
COMMENT ON COLUMN sa.adfcrm_solution_scripts.changed_by IS 'User that perform the change';
COMMENT ON COLUMN sa.adfcrm_solution_scripts.change_type IS 'Type of change INSERT/DELETE/UPDATE';