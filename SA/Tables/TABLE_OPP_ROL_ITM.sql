CREATE TABLE sa.table_opp_rol_itm (
  objid NUMBER,
  dev NUMBER,
  path_type NUMBER,
  "DEPTH" NUMBER,
  parent2opportunity NUMBER,
  child2opportunity NUMBER,
  opp_itm2rollup NUMBER
);
ALTER TABLE sa.table_opp_rol_itm ADD SUPPLEMENTAL LOG GROUP dmtsora1703477198_0 (child2opportunity, "DEPTH", dev, objid, opp_itm2rollup, parent2opportunity, path_type) ALWAYS;