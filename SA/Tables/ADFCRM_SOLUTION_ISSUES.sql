CREATE TABLE sa.adfcrm_solution_issues (
  issue_id NUMBER NOT NULL,
  issue_name VARCHAR2(50 BYTE) NOT NULL,
  solution_id NUMBER NOT NULL,
  changed_date DATE DEFAULT SYSDATE,
  changed_by VARCHAR2(50 BYTE),
  change_type VARCHAR2(100 BYTE),
  CONSTRAINT adfcrm_solution_issues_uk UNIQUE (issue_id),
  CONSTRAINT adfcrm_solution_issues_fk1 FOREIGN KEY (solution_id) REFERENCES sa.adfcrm_solution (solution_id)
);
COMMENT ON TABLE sa.adfcrm_solution_issues IS 'Solution Issues';
COMMENT ON COLUMN sa.adfcrm_solution_issues.issue_name IS 'Issue name referenced in the ticket/case';
COMMENT ON COLUMN sa.adfcrm_solution_issues.solution_id IS 'Reference to adfcrm_solution.solution_id';
COMMENT ON COLUMN sa.adfcrm_solution_issues.changed_date IS 'Date in which the change was done';
COMMENT ON COLUMN sa.adfcrm_solution_issues.changed_by IS 'User that perform the change';
COMMENT ON COLUMN sa.adfcrm_solution_issues.change_type IS 'Type of change INSERT/DELETE/UPDATE';