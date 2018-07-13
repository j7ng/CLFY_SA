CREATE TABLE sa.table_schedule (
  objid NUMBER,
  title VARCHAR2(32 BYTE),
  dev NUMBER,
  schedule2employee NUMBER(*,0),
  schedule2site_part NUMBER(*,0)
);
ALTER TABLE sa.table_schedule ADD SUPPLEMENTAL LOG GROUP dmtsora983704419_0 (dev, objid, schedule2employee, schedule2site_part, title) ALWAYS;
COMMENT ON TABLE sa.table_schedule IS 'Schedule object; header record for employee and installed part maintenance schedules';
COMMENT ON COLUMN sa.table_schedule.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_schedule.title IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_schedule.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_schedule.schedule2employee IS 'Related employee; used for recording appointments, vacation, etc';
COMMENT ON COLUMN sa.table_schedule.schedule2site_part IS 'Related parts; used for recording down time, scheduled preventive maintenance, etc';