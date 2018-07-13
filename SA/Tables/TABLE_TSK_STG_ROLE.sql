CREATE TABLE sa.table_tsk_stg_role (
  objid NUMBER,
  "ACTIVE" NUMBER,
  role_name VARCHAR2(80 BYTE),
  role_type NUMBER,
  comments VARCHAR2(255 BYTE),
  focus_type NUMBER,
  dev NUMBER,
  role2cycle_stage NUMBER(*,0),
  role2stage_task NUMBER(*,0)
);
ALTER TABLE sa.table_tsk_stg_role ADD SUPPLEMENTAL LOG GROUP dmtsora164044809_0 ("ACTIVE", comments, dev, focus_type, objid, role2cycle_stage, role2stage_task, role_name, role_type) ALWAYS;