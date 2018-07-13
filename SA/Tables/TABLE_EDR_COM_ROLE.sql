CREATE TABLE sa.table_edr_com_role (
  objid NUMBER,
  dev NUMBER,
  role_type NUMBER,
  edr_role2communication NUMBER,
  edr_role2e_addr NUMBER
);
ALTER TABLE sa.table_edr_com_role ADD SUPPLEMENTAL LOG GROUP dmtsora787035176_0 (dev, edr_role2communication, edr_role2e_addr, objid, role_type) ALWAYS;