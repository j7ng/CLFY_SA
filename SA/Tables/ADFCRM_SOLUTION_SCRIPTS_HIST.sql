CREATE TABLE sa.adfcrm_solution_scripts_hist (
  ss_id NUMBER NOT NULL,
  solution_id NUMBER NOT NULL,
  step NUMBER NOT NULL,
  script_type VARCHAR2(20 BYTE) NOT NULL,
  script_id VARCHAR2(20 BYTE) NOT NULL,
  changed_date DATE,
  changed_by VARCHAR2(50 BYTE),
  change_type VARCHAR2(100 BYTE)
);