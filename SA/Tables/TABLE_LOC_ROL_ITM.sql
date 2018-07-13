CREATE TABLE sa.table_loc_rol_itm (
  objid NUMBER,
  dev NUMBER,
  path_type NUMBER,
  "DEPTH" NUMBER,
  parent2inv_locatn NUMBER,
  child2inv_locatn NUMBER,
  loc_itm2rollup NUMBER
);
ALTER TABLE sa.table_loc_rol_itm ADD SUPPLEMENTAL LOG GROUP dmtsora1337062922_0 (child2inv_locatn, "DEPTH", dev, loc_itm2rollup, objid, parent2inv_locatn, path_type) ALWAYS;