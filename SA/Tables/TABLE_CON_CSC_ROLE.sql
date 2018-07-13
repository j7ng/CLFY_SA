CREATE TABLE sa.table_con_csc_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  access_id VARCHAR2(40 BYTE),
  dev NUMBER,
  csc_role2contact NUMBER(*,0),
  con_role2contr_schedule NUMBER(*,0)
);
ALTER TABLE sa.table_con_csc_role ADD SUPPLEMENTAL LOG GROUP dmtsora1075565171_0 (access_id, "ACTIVE", con_role2contr_schedule, csc_role2contact, dev, focus_type, objid, role_name) ALWAYS;