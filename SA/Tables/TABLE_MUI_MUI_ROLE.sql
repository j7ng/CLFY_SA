CREATE TABLE sa.table_mui_mui_role (
  objid NUMBER,
  "ACTIVE" NUMBER,
  role_name VARCHAR2(80 BYTE),
  dev NUMBER,
  "PRIORITY" NUMBER,
  role_for2menu_item NUMBER,
  player2menu_item NUMBER
);
ALTER TABLE sa.table_mui_mui_role ADD SUPPLEMENTAL LOG GROUP dmtsora586981268_0 ("ACTIVE", dev, objid, player2menu_item, "PRIORITY", role_for2menu_item, role_name) ALWAYS;