CREATE TABLE sa.x_phone_status_log (
  objid NUMBER(22) NOT NULL,
  x_esn VARCHAR2(50 BYTE),
  x_part_num VARCHAR2(50 BYTE),
  x_part_status VARCHAR2(50 BYTE),
  x_install_date DATE,
  x_min VARCHAR2(50 BYTE),
  x_stock VARCHAR2(10 BYTE),
  x_color_code VARCHAR2(10 BYTE),
  x_user VARCHAR2(200 BYTE),
  x_insert_date DATE,
  CONSTRAINT pk_x_phone_status_log PRIMARY KEY (objid)
);
COMMENT ON COLUMN sa.x_phone_status_log.x_esn IS 'ESN';
COMMENT ON COLUMN sa.x_phone_status_log.x_part_num IS 'Part Number';
COMMENT ON COLUMN sa.x_phone_status_log.x_part_status IS 'Part Status';
COMMENT ON COLUMN sa.x_phone_status_log.x_install_date IS 'Install date';
COMMENT ON COLUMN sa.x_phone_status_log.x_min IS 'Mobile Identification Number';
COMMENT ON COLUMN sa.x_phone_status_log.x_stock IS 'stock';
COMMENT ON COLUMN sa.x_phone_status_log.x_color_code IS 'color code';
COMMENT ON COLUMN sa.x_phone_status_log.x_user IS 'user';
COMMENT ON COLUMN sa.x_phone_status_log.x_insert_date IS 'Insert date time';