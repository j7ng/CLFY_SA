CREATE TABLE sa.table_daylight_hr (
  objid NUMBER,
  start_time DATE,
  end_time DATE,
  dev NUMBER,
  daylight_hr2time_zone NUMBER(*,0)
);
ALTER TABLE sa.table_daylight_hr ADD SUPPLEMENTAL LOG GROUP dmtsora889452277_0 (daylight_hr2time_zone, dev, end_time, objid, start_time) ALWAYS;