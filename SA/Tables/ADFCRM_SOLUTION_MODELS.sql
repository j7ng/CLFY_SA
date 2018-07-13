CREATE TABLE sa.adfcrm_solution_models (
  solution_id NUMBER NOT NULL,
  part_class_id NUMBER NOT NULL,
  changed_date DATE DEFAULT SYSDATE,
  changed_by VARCHAR2(50 BYTE),
  change_type VARCHAR2(100 BYTE),
  CONSTRAINT adfcrm_solution_models_pk PRIMARY KEY (solution_id,part_class_id),
  CONSTRAINT adfcrm_solution_models_fk1 FOREIGN KEY (solution_id) REFERENCES sa.adfcrm_solution (solution_id)
);
COMMENT ON TABLE sa.adfcrm_solution_models IS 'Models associated with the solution in order to qualify and condition it';
COMMENT ON COLUMN sa.adfcrm_solution_models.solution_id IS 'References to solution.solution_id';
COMMENT ON COLUMN sa.adfcrm_solution_models.part_class_id IS 'References to table_part_class.objid';
COMMENT ON COLUMN sa.adfcrm_solution_models.changed_date IS 'Date in which the change was done';
COMMENT ON COLUMN sa.adfcrm_solution_models.changed_by IS 'User that perform the change';
COMMENT ON COLUMN sa.adfcrm_solution_models.change_type IS 'Type of change INSERT/DELETE/UPDATE';