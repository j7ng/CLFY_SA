CREATE TABLE sa.adfcrm_task_flows_hist (
  task_id NUMBER NOT NULL,
  task_name VARCHAR2(100 BYTE) NOT NULL,
  task_flow_id VARCHAR2(100 BYTE) NOT NULL,
  changed_date DATE,
  changed_by VARCHAR2(50 BYTE),
  change_type VARCHAR2(100 BYTE)
);