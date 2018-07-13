CREATE TABLE sa.table_x_webcsr_log (
  objid NUMBER,
  dev NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_agent VARCHAR2(20 BYTE),
  x_date_time DATE,
  x_tran_type VARCHAR2(20 BYTE)
);
ALTER TABLE sa.table_x_webcsr_log ADD SUPPLEMENTAL LOG GROUP dmtsora157366510_0 (dev, objid, x_agent, x_date_time, x_esn, x_tran_type) ALWAYS;
COMMENT ON TABLE sa.table_x_webcsr_log IS 'Log WEBCSR flow selections';
COMMENT ON COLUMN sa.table_x_webcsr_log.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_webcsr_log.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_webcsr_log.x_esn IS 'TBD';
COMMENT ON COLUMN sa.table_x_webcsr_log.x_agent IS 'TBD';
COMMENT ON COLUMN sa.table_x_webcsr_log.x_date_time IS 'TBD';
COMMENT ON COLUMN sa.table_x_webcsr_log.x_tran_type IS 'TBD';