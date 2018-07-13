CREATE TABLE sa.x_gencodes_breakdown_details (
  objid NUMBER NOT NULL,
  x_details_2_gencodes_hdr_objid NUMBER,
  x_cmd_name VARCHAR2(100 BYTE),
  x_cmd_status VARCHAR2(30 BYTE),
  x_idn_user_created VARCHAR2(50 BYTE),
  x_dte_created DATE,
  x_idn_user_change_last VARCHAR2(50 BYTE),
  x_dte_change_last DATE
);
COMMENT ON TABLE sa.x_gencodes_breakdown_details IS 'This table is created to log data related to transaction, while generating OTA gencodes -details ';
COMMENT ON COLUMN sa.x_gencodes_breakdown_details.objid IS 'Primary key column of X_GENCODES_BREAKDOWN_DETAILS table';
COMMENT ON COLUMN sa.x_gencodes_breakdown_details.x_details_2_gencodes_hdr_objid IS 'Primary key of X_GENCODES_BREAKDOWN_HEADER table ';
COMMENT ON COLUMN sa.x_gencodes_breakdown_details.x_cmd_name IS 'CMD name ';
COMMENT ON COLUMN sa.x_gencodes_breakdown_details.x_cmd_status IS 'CMD Status. Valid status being Y or P or A';