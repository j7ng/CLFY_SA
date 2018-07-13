CREATE TABLE sa.table_shp_sit_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  shp_role2site NUMBER,
  shp_role2ship_parts NUMBER
);
ALTER TABLE sa.table_shp_sit_role ADD SUPPLEMENTAL LOG GROUP dmtsora1249269227_0 ("ACTIVE", dev, focus_type, objid, role_name, shp_role2ship_parts, shp_role2site) ALWAYS;