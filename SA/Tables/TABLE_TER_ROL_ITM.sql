CREATE TABLE sa.table_ter_rol_itm (
  objid NUMBER,
  dev NUMBER,
  path_type NUMBER,
  "DEPTH" NUMBER,
  rol_parent2territory NUMBER,
  rol_child2territory NUMBER,
  ter_itm2rollup NUMBER
);
ALTER TABLE sa.table_ter_rol_itm ADD SUPPLEMENTAL LOG GROUP dmtsora1310151885_0 ("DEPTH", dev, objid, path_type, rol_child2territory, rol_parent2territory, ter_itm2rollup) ALWAYS;