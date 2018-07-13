CREATE TABLE sa.table_lst_per_role (
  objid NUMBER,
  "ACTIVE" NUMBER,
  role_name VARCHAR2(80 BYTE),
  dev NUMBER,
  list_role2person NUMBER(*,0),
  per_role2mail_list NUMBER(*,0)
);
ALTER TABLE sa.table_lst_per_role ADD SUPPLEMENTAL LOG GROUP dmtsora1677506183_0 ("ACTIVE", dev, list_role2person, objid, per_role2mail_list, role_name) ALWAYS;