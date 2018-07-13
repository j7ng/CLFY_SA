CREATE TABLE sa.table_addr_ba_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  last_update DATE,
  blg_argmnt_role2blg_argmnt NUMBER,
  address_role2address NUMBER
);
ALTER TABLE sa.table_addr_ba_role ADD SUPPLEMENTAL LOG GROUP dmtsora1809241302_0 ("ACTIVE", address_role2address, blg_argmnt_role2blg_argmnt, dev, focus_type, last_update, objid, role_name) ALWAYS;