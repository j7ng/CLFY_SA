CREATE TABLE sa.x_canceltosuspend (
  objid NUMBER,
  x_status VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  x_cancelto_suspend_date DATE,
  x_site_part_objid NUMBER,
  x_call_trans_objid NUMBER,
  x_processed_date DATE,
  x_result VARCHAR2(100 BYTE)
);
COMMENT ON TABLE sa.x_canceltosuspend IS 'TMO Cancel to Suspend Table.  It keeps track of Cancelation Schedule.';
COMMENT ON COLUMN sa.x_canceltosuspend.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_canceltosuspend.x_status IS 'Status';
COMMENT ON COLUMN sa.x_canceltosuspend.x_min IS 'MIN, Phone Number';
COMMENT ON COLUMN sa.x_canceltosuspend.x_cancelto_suspend_date IS 'Date for Change from Cancel to Suspend';
COMMENT ON COLUMN sa.x_canceltosuspend.x_site_part_objid IS 'Reference to objid in table_site_part';
COMMENT ON COLUMN sa.x_canceltosuspend.x_call_trans_objid IS 'Reference to objid in table_x_call_trans';
COMMENT ON COLUMN sa.x_canceltosuspend.x_processed_date IS 'Process Date';
COMMENT ON COLUMN sa.x_canceltosuspend.x_result IS 'Result';