CREATE TABLE sa.table_x_byop (
  objid NUMBER,
  x_esn VARCHAR2(30 BYTE),
  x_byop_type VARCHAR2(500 BYTE),
  x_byop_manufacturer VARCHAR2(200 BYTE),
  x_byop_model VARCHAR2(200 BYTE),
  x_cdma_port_counter NUMBER,
  x_msl_code VARCHAR2(100 BYTE)
);
COMMENT ON COLUMN sa.table_x_byop.objid IS 'INTERNAL UNIQUE IDENTIFIER FROM SEQUENCE SA.SEQU_X_BYOP';
COMMENT ON COLUMN sa.table_x_byop.x_esn IS 'BYOP COSTUMER ESN  ';
COMMENT ON COLUMN sa.table_x_byop.x_byop_type IS 'PHONE TABLET ITC';
COMMENT ON COLUMN sa.table_x_byop.x_byop_manufacturer IS 'MANUFACTURER OF THE PHONE';
COMMENT ON COLUMN sa.table_x_byop.x_byop_model IS 'MODEL OF THE PHONE ';
COMMENT ON COLUMN sa.table_x_byop.x_cdma_port_counter IS 'NUMBER OF FREE PORTS LEFT';
COMMENT ON COLUMN sa.table_x_byop.x_msl_code IS 'CODE NEEDED FOR SPRINT PHONES TO ACTIVATE THRU BYOP';