CREATE TABLE sa.table_sit_csc_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  csc_role2site NUMBER(*,0),
  sit_role2contr_schedule NUMBER(*,0)
);
ALTER TABLE sa.table_sit_csc_role ADD SUPPLEMENTAL LOG GROUP dmtsora133274755_0 ("ACTIVE", csc_role2site, dev, focus_type, objid, role_name, sit_role2contr_schedule) ALWAYS;