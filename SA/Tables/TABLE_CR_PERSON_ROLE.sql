CREATE TABLE sa.table_cr_person_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  cr_person_role2contract NUMBER(*,0),
  cr_person_role2person NUMBER(*,0)
);
ALTER TABLE sa.table_cr_person_role ADD SUPPLEMENTAL LOG GROUP dmtsora1384070660_0 ("ACTIVE", cr_person_role2contract, cr_person_role2person, dev, focus_type, objid, role_name) ALWAYS;