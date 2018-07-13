CREATE TABLE sa.table_csc_tzone (
  objid NUMBER,
  "NAME" VARCHAR2(20 BYTE),
  s_name VARCHAR2(20 BYTE),
  full_name VARCHAR2(255 BYTE),
  gmt_diff NUMBER,
  is_default NUMBER,
  server_id NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_csc_tzone ADD SUPPLEMENTAL LOG GROUP dmtsora2137824401_0 (dev, full_name, gmt_diff, is_default, "NAME", objid, server_id, s_name) ALWAYS;
COMMENT ON TABLE sa.table_csc_tzone IS 'CSC Time zone object which is used to define the time zone in which an address is located';
COMMENT ON COLUMN sa.table_csc_tzone.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_csc_tzone."NAME" IS 'Time zone name';
COMMENT ON COLUMN sa.table_csc_tzone.full_name IS 'Detailed name/description of time zone';
COMMENT ON COLUMN sa.table_csc_tzone.gmt_diff IS 'Offset from Greenwich Mean Time (GMT) in seconds';
COMMENT ON COLUMN sa.table_csc_tzone.is_default IS 'Indicates this is the default time zone';
COMMENT ON COLUMN sa.table_csc_tzone.server_id IS 'Exchange prodocol server ID number';
COMMENT ON COLUMN sa.table_csc_tzone.dev IS 'Row version number for mobile distribution purposes';