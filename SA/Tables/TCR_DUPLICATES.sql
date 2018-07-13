CREATE TABLE sa.tcr_duplicates (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  s_role_name VARCHAR2(80 BYTE),
  primary_site NUMBER,
  dev NUMBER,
  contact_role2site NUMBER(*,0),
  contact_role2contact NUMBER(*,0),
  contact_role2gbst_elm NUMBER(*,0),
  update_stamp DATE
);
ALTER TABLE sa.tcr_duplicates ADD SUPPLEMENTAL LOG GROUP dmtsora1071712640_0 (contact_role2contact, contact_role2gbst_elm, contact_role2site, dev, objid, primary_site, role_name, s_role_name, update_stamp) ALWAYS;