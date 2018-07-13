CREATE TABLE sa.adfcrm_solution_qualification (
  solution_id NUMBER NOT NULL,
  class_param_name VARCHAR2(100 BYTE) NOT NULL,
  class_param_value VARCHAR2(100 BYTE) NOT NULL,
  changed_date DATE DEFAULT SYSDATE,
  changed_by VARCHAR2(50 BYTE),
  change_type VARCHAR2(100 BYTE),
  CONSTRAINT adfcrm_sol_qualification_pk PRIMARY KEY (solution_id,class_param_name,class_param_value),
  CONSTRAINT adfcrm_sol_qualification_fk1 FOREIGN KEY (solution_id) REFERENCES sa.adfcrm_solution (solution_id)
);
COMMENT ON TABLE sa.adfcrm_solution_qualification IS 'Parameters associated with the solution in order to qualify and condition it';
COMMENT ON COLUMN sa.adfcrm_solution_qualification.solution_id IS 'References to solution.solution_id';
COMMENT ON COLUMN sa.adfcrm_solution_qualification.class_param_name IS 'Part Class parameter name that qualify/condition the solution';
COMMENT ON COLUMN sa.adfcrm_solution_qualification.class_param_value IS 'Part Class parameter value permitted for the part class parameter name';
COMMENT ON COLUMN sa.adfcrm_solution_qualification.changed_date IS 'Date in which the change was done';
COMMENT ON COLUMN sa.adfcrm_solution_qualification.changed_by IS 'User that perform the change';
COMMENT ON COLUMN sa.adfcrm_solution_qualification.change_type IS 'Type of change INSERT/DELETE/UPDATE';