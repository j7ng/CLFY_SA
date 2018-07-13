CREATE TABLE sa.table_eco_mod_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  eco_mod_role2eco_hdr NUMBER(*,0),
  applies2mod_level NUMBER(*,0),
  result2mod_level NUMBER(*,0)
);
ALTER TABLE sa.table_eco_mod_role ADD SUPPLEMENTAL LOG GROUP dmtsora1232835155_0 ("ACTIVE", applies2mod_level, dev, eco_mod_role2eco_hdr, focus_type, objid, result2mod_level, role_name) ALWAYS;