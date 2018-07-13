CREATE TABLE sa.x_payment_service_parameters (
  objid NUMBER,
  x_ics_applications VARCHAR2(150 BYTE),
  x_afs_flag VARCHAR2(20 BYTE),
  x_dav_flag VARCHAR2(20 BYTE)
);
COMMENT ON COLUMN sa.x_payment_service_parameters.x_ics_applications IS 'Payment service applications';
COMMENT ON COLUMN sa.x_payment_service_parameters.x_afs_flag IS 'AFS flag';
COMMENT ON COLUMN sa.x_payment_service_parameters.x_dav_flag IS 'DAV flag';