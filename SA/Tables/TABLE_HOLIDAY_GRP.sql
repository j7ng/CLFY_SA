CREATE TABLE sa.table_holiday_grp (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  description VARCHAR2(255 BYTE),
  total_day NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_holiday_grp ADD SUPPLEMENTAL LOG GROUP dmtsora761000482_0 (description, dev, objid, title, total_day) ALWAYS;