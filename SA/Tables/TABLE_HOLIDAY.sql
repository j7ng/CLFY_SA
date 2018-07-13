CREATE TABLE sa.table_holiday (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  start_time DATE,
  end_time DATE,
  dev NUMBER,
  holiday2holiday_grp NUMBER(*,0)
);
ALTER TABLE sa.table_holiday ADD SUPPLEMENTAL LOG GROUP dmtsora2114859213_0 (dev, end_time, holiday2holiday_grp, objid, start_time, title) ALWAYS;