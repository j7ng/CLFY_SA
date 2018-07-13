CREATE TABLE sa.table_price_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  "ACTIVE" NUMBER,
  focus_type NUMBER,
  dev NUMBER,
  price_role2price_inst NUMBER(*,0),
  price_role2part_info NUMBER(*,0)
);
ALTER TABLE sa.table_price_role ADD SUPPLEMENTAL LOG GROUP dmtsora220461135_0 ("ACTIVE", dev, focus_type, objid, price_role2part_info, price_role2price_inst, role_name) ALWAYS;