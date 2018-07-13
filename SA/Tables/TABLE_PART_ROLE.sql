CREATE TABLE sa.table_part_role (
  objid NUMBER,
  "ACTIVE" NUMBER,
  role_id NUMBER,
  dev NUMBER,
  role_for2mod_level NUMBER(*,0),
  role_player2mod_level NUMBER(*,0)
);
ALTER TABLE sa.table_part_role ADD SUPPLEMENTAL LOG GROUP dmtsora1681179027_0 ("ACTIVE", dev, objid, role_for2mod_level, role_id, role_player2mod_level) ALWAYS;