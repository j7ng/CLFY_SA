CREATE TABLE sa.x_gencodes_breakdown_header (
  objid NUMBER NOT NULL,
  x_esn VARCHAR2(20 BYTE),
  x_config_id NUMBER,
  x_status VARCHAR2(30 BYTE),
  x_idn_user_created VARCHAR2(50 BYTE),
  x_dte_created DATE,
  x_idn_user_change_last VARCHAR2(50 BYTE),
  x_dte_change_last DATE
);
COMMENT ON TABLE sa.x_gencodes_breakdown_header IS 'This table is created to log data related to transaction, while generating OTA gencodes ';
COMMENT ON COLUMN sa.x_gencodes_breakdown_header.objid IS 'Primary key column of X_GENCODES_BREAKDOWN_HEADER table';
COMMENT ON COLUMN sa.x_gencodes_breakdown_header.x_esn IS 'ESN ';
COMMENT ON COLUMN sa.x_gencodes_breakdown_header.x_config_id IS 'Config id ';
COMMENT ON COLUMN sa.x_gencodes_breakdown_header.x_status IS 'CBO status. Valid status being COMPLETED, PENDING';
COMMENT ON COLUMN sa.x_gencodes_breakdown_header.x_idn_user_created IS 'User who created this record ';
COMMENT ON COLUMN sa.x_gencodes_breakdown_header.x_dte_created IS 'Date when this record is created ';
COMMENT ON COLUMN sa.x_gencodes_breakdown_header.x_idn_user_change_last IS 'User who last updated this record ';
COMMENT ON COLUMN sa.x_gencodes_breakdown_header.x_dte_change_last IS 'Date when this record is last updated ';