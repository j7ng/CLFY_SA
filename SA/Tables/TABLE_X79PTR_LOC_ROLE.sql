CREATE TABLE sa.table_x79ptr_loc_role (
  objid NUMBER,
  dev NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  server_id NUMBER,
  ptr_loc2x79location NUMBER,
  loc2x79provider_tr NUMBER
);
ALTER TABLE sa.table_x79ptr_loc_role ADD SUPPLEMENTAL LOG GROUP dmtsora1491868846_0 ("ACTIVE", dev, focus_type, loc2x79provider_tr, objid, ptr_loc2x79location, role_name, server_id) ALWAYS;