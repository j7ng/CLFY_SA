CREATE TABLE sa.table_x_carrier_log (
  objid NUMBER,
  log2carrier NUMBER,
  x_carrier_log LONG
);
ALTER TABLE sa.table_x_carrier_log ADD SUPPLEMENTAL LOG GROUP dmtsora226648611_0 (log2carrier, objid) ALWAYS;
COMMENT ON TABLE sa.table_x_carrier_log IS 'Stores carrier text information';
COMMENT ON COLUMN sa.table_x_carrier_log.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_carrier_log.log2carrier IS 'Carrier Relation to its Log';
COMMENT ON COLUMN sa.table_x_carrier_log.x_carrier_log IS 'Text associated with a carrier market / submarket';