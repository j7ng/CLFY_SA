CREATE TABLE sa.adfcrm_solution_issues_hist (
  issue_id NUMBER NOT NULL,
  issue_name VARCHAR2(50 BYTE) NOT NULL,
  solution_id NUMBER NOT NULL,
  changed_date DATE,
  changed_by VARCHAR2(50 BYTE),
  change_type VARCHAR2(100 BYTE)
);