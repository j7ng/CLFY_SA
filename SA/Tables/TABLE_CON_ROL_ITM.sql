CREATE TABLE sa.table_con_rol_itm (
  objid NUMBER,
  dev NUMBER,
  path_type NUMBER,
  "DEPTH" NUMBER,
  parent2contact NUMBER,
  child2contact NUMBER,
  con_itm2rollup NUMBER
);
ALTER TABLE sa.table_con_rol_itm ADD SUPPLEMENTAL LOG GROUP dmtsora2070831496_0 (child2contact, con_itm2rollup, "DEPTH", dev, objid, parent2contact, path_type) ALWAYS;