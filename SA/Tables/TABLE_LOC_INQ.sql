CREATE TABLE sa.table_loc_inq (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  icon_id NUMBER,
  field1 VARCHAR2(20 BYTE),
  field2 VARCHAR2(20 BYTE),
  field3 VARCHAR2(20 BYTE),
  field4 VARCHAR2(20 BYTE),
  field5 VARCHAR2(20 BYTE),
  field6 VARCHAR2(20 BYTE),
  field7 VARCHAR2(20 BYTE),
  field8 VARCHAR2(20 BYTE),
  field9 NUMBER,
  dev NUMBER,
  loc_inq_owner2user NUMBER(*,0)
);
ALTER TABLE sa.table_loc_inq ADD SUPPLEMENTAL LOG GROUP dmtsora675548385_0 (dev, field1, field2, field3, field4, field5, field6, field7, field8, field9, icon_id, loc_inq_owner2user, objid, title) ALWAYS;