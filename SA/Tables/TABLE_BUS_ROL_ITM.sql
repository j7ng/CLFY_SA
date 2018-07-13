CREATE TABLE sa.table_bus_rol_itm (
  objid NUMBER,
  dev NUMBER,
  path_type NUMBER,
  "DEPTH" NUMBER,
  parent2bus_org NUMBER,
  child2bus_org NUMBER,
  bus_itm2rollup NUMBER
);
ALTER TABLE sa.table_bus_rol_itm ADD SUPPLEMENTAL LOG GROUP dmtsora10539148_0 (bus_itm2rollup, child2bus_org, "DEPTH", dev, objid, parent2bus_org, path_type) ALWAYS;