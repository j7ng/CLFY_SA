CREATE TABLE sa.table_wk_work_hr (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  s_title VARCHAR2(80 BYTE),
  description VARCHAR2(255 BYTE),
  total_hour NUMBER,
  cal_type VARCHAR2(30 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_wk_work_hr ADD SUPPLEMENTAL LOG GROUP dmtsora1100503721_0 (cal_type, description, dev, objid, s_title, title, total_hour) ALWAYS;
COMMENT ON TABLE sa.table_wk_work_hr IS 'Calendar object; used in business hours feature. Defines the system business calendars which can be associated with sites';
COMMENT ON COLUMN sa.table_wk_work_hr.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_wk_work_hr.title IS 'Name of the business calendar';
COMMENT ON COLUMN sa.table_wk_work_hr.description IS 'Detailed description of the business calendar';
COMMENT ON COLUMN sa.table_wk_work_hr.total_hour IS 'Total hours in the business calendar for each work week';
COMMENT ON COLUMN sa.table_wk_work_hr.cal_type IS 'Calendar type that categorizes the business calendar; this is a user-defined pop up list with default name of CALENDAR_TYPE';
COMMENT ON COLUMN sa.table_wk_work_hr.dev IS 'Row version number for mobile distribution purposes';