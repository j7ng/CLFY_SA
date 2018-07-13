CREATE TABLE sa.x_selfheal_log (
  x_esn VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  x_timestamp DATE,
  x_phone_seq NUMBER,
  x_system_seq NUMBER,
  x_request_type VARCHAR2(50 BYTE)
);
COMMENT ON TABLE sa.x_selfheal_log IS 'Log table for OTA self healing requests';
COMMENT ON COLUMN sa.x_selfheal_log.x_esn IS 'Phone Serial Number';
COMMENT ON COLUMN sa.x_selfheal_log.x_min IS 'Phone Mobile Number';
COMMENT ON COLUMN sa.x_selfheal_log.x_timestamp IS 'Timestamp for request';
COMMENT ON COLUMN sa.x_selfheal_log.x_phone_seq IS 'Phone Sequence';
COMMENT ON COLUMN sa.x_selfheal_log.x_system_seq IS 'System Sequence';
COMMENT ON COLUMN sa.x_selfheal_log.x_request_type IS 'Content of request: PIN NUmber or 555';