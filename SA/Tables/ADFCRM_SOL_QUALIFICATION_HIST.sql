CREATE TABLE sa.adfcrm_sol_qualification_hist (
  solution_id NUMBER NOT NULL,
  class_param_name VARCHAR2(100 BYTE) NOT NULL,
  class_param_value VARCHAR2(100 BYTE) NOT NULL,
  changed_date DATE,
  changed_by VARCHAR2(50 BYTE),
  change_type VARCHAR2(100 BYTE)
);