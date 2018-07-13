CREATE TABLE sa.table_access_control (
  objid NUMBER,
  dev NUMBER,
  type_id NUMBER,
  access_rule LONG,
  "ACTIVE" NUMBER,
  comments VARCHAR2(255 BYTE)
);
ALTER TABLE sa.table_access_control ADD SUPPLEMENTAL LOG GROUP dmtsora885602533_0 ("ACTIVE", comments, dev, objid, type_id) ALWAYS;