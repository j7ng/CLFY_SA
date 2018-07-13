CREATE TABLE sa.table_time_zone (
  objid NUMBER,
  "NAME" VARCHAR2(20 BYTE),
  s_name VARCHAR2(20 BYTE),
  full_name VARCHAR2(255 BYTE),
  gmt_diff NUMBER,
  is_default NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_time_zone ADD SUPPLEMENTAL LOG GROUP dmtsora98717827_0 (dev, full_name, gmt_diff, is_default, "NAME", objid, s_name) ALWAYS;
COMMENT ON TABLE sa.table_time_zone IS 'Time zone object which is used to define the time zone in which an address is located';
COMMENT ON COLUMN sa.table_time_zone.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_time_zone."NAME" IS 'Time zone name';
COMMENT ON COLUMN sa.table_time_zone.full_name IS 'Detailed name/description of time zone';
COMMENT ON COLUMN sa.table_time_zone.gmt_diff IS 'Offset from Greenwich Mean Time (GMT) in seconds';
COMMENT ON COLUMN sa.table_time_zone.is_default IS 'Indicates this is the default time zone';
COMMENT ON COLUMN sa.table_time_zone.dev IS 'Row version number for mobile distribution purposes';