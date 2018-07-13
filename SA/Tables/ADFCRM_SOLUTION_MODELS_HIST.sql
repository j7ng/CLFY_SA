CREATE TABLE sa.adfcrm_solution_models_hist (
  solution_id NUMBER NOT NULL,
  part_class_id NUMBER NOT NULL,
  changed_date DATE,
  changed_by VARCHAR2(50 BYTE),
  change_type VARCHAR2(100 BYTE)
);