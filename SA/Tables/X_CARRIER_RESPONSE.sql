CREATE TABLE sa.x_carrier_response (
  x_esn VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  x_sim VARCHAR2(50 BYTE),
  x_imsi VARCHAR2(50 BYTE),
  x_min_status VARCHAR2(30 BYTE),
  x_load_status VARCHAR2(30 BYTE),
  x_zipcode VARCHAR2(30 BYTE),
  x_carrier VARCHAR2(30 BYTE),
  x_insert_date DATE,
  x_update_date DATE
);
COMMENT ON TABLE sa.x_carrier_response IS 'carrier response table for migration';
COMMENT ON COLUMN sa.x_carrier_response.x_esn IS 'esn';
COMMENT ON COLUMN sa.x_carrier_response.x_min IS 'min';
COMMENT ON COLUMN sa.x_carrier_response.x_sim IS 'sim';
COMMENT ON COLUMN sa.x_carrier_response.x_imsi IS 'imsi';
COMMENT ON COLUMN sa.x_carrier_response.x_min_status IS 'min status';
COMMENT ON COLUMN sa.x_carrier_response.x_load_status IS 'load status';
COMMENT ON COLUMN sa.x_carrier_response.x_zipcode IS 'zipcode';
COMMENT ON COLUMN sa.x_carrier_response.x_carrier IS 'carrier';
COMMENT ON COLUMN sa.x_carrier_response.x_insert_date IS 'insert date';
COMMENT ON COLUMN sa.x_carrier_response.x_update_date IS 'update date';