CREATE TABLE sa.adfcrm_task_flow_scripts_hist (
  tfs_id NUMBER NOT NULL,
  task_id NUMBER NOT NULL,
  step NUMBER NOT NULL,
  script_type VARCHAR2(20 BYTE) NOT NULL,
  script_id VARCHAR2(20 BYTE) NOT NULL,
  changed_date DATE,
  changed_by VARCHAR2(50 BYTE),
  change_type VARCHAR2(100 BYTE)
);