CREATE TABLE sa.adfcrm_mtm_soltask_flows_hist (
  task_id NUMBER NOT NULL,
  solution_id NUMBER NOT NULL,
  case_conf_hdr_id NUMBER,
  changed_date DATE,
  changed_by VARCHAR2(50 BYTE),
  change_type VARCHAR2(100 BYTE)
);