CREATE TABLE sa.table_db_geom (
  objid NUMBER,
  "ID" NUMBER,
  "TYPE" NUMBER,
  value1 VARCHAR2(80 BYTE),
  value2 VARCHAR2(80 BYTE),
  intval1 NUMBER,
  intval2 NUMBER,
  intval3 NUMBER,
  intval4 NUMBER,
  win_id NUMBER,
  dev NUMBER,
  user_setting2user NUMBER(*,0)
);
ALTER TABLE sa.table_db_geom ADD SUPPLEMENTAL LOG GROUP dmtsora432948766_0 (dev, "ID", intval1, intval2, intval3, intval4, objid, "TYPE", user_setting2user, value1, value2, win_id) ALWAYS;