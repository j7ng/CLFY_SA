CREATE TABLE sa.table_monitor (
  objid NUMBER,
  title VARCHAR2(24 BYTE),
  description VARCHAR2(255 BYTE),
  icon_id NUMBER,
  "TYPE" NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_monitor ADD SUPPLEMENTAL LOG GROUP dmtsora891795579_0 (description, dev, icon_id, objid, title, "TYPE") ALWAYS;
COMMENT ON TABLE sa.table_monitor IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monitor.objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monitor.title IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monitor.description IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monitor.icon_id IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monitor."TYPE" IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_monitor.dev IS 'Row version number for mobile distribution purposes';