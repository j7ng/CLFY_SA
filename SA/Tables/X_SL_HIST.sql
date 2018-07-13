CREATE TABLE sa.x_sl_hist (
  objid NUMBER,
  lid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_event_dt DATE,
  x_insert_dt DATE,
  x_event_value VARCHAR2(50 BYTE),
  x_event_code NUMBER,
  x_event_data VARCHAR2(300 BYTE),
  x_min VARCHAR2(30 BYTE),
  username VARCHAR2(30 BYTE),
  x_sourcesystem VARCHAR2(30 BYTE),
  x_code_number VARCHAR2(20 BYTE),
  x_src_table VARCHAR2(50 BYTE),
  x_src_objid NUMBER,
  x_program_enrolled_id NUMBER
);
COMMENT ON TABLE sa.x_sl_hist IS 'Safelink Transaction History';
COMMENT ON COLUMN sa.x_sl_hist.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_sl_hist.lid IS '3rd Party Customer ID';
COMMENT ON COLUMN sa.x_sl_hist.x_esn IS 'Phone Serial Number';
COMMENT ON COLUMN sa.x_sl_hist.x_event_dt IS 'Event Date';
COMMENT ON COLUMN sa.x_sl_hist.x_insert_dt IS 'Insert Date';
COMMENT ON COLUMN sa.x_sl_hist.x_event_value IS 'Description of Event';
COMMENT ON COLUMN sa.x_sl_hist.x_event_code IS 'Code for the Event';
COMMENT ON COLUMN sa.x_sl_hist.x_event_data IS 'Data for the Event';
COMMENT ON COLUMN sa.x_sl_hist.x_min IS 'Mobile Phone Number';
COMMENT ON COLUMN sa.x_sl_hist.username IS 'login name';
COMMENT ON COLUMN sa.x_sl_hist.x_sourcesystem IS 'Source system';
COMMENT ON COLUMN sa.x_sl_hist.x_code_number IS 'Code Number';
COMMENT ON COLUMN sa.x_sl_hist.x_src_table IS 'src table: table_case, x_program_enrolled';
COMMENT ON COLUMN sa.x_sl_hist.x_src_objid IS 'Src table objid';
COMMENT ON COLUMN sa.x_sl_hist.x_program_enrolled_id IS 'not used';