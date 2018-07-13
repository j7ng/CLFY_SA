CREATE TABLE sa.xsu_hmo_response (
  x_batchdate DATE,
  x_hmo VARCHAR2(10 BYTE),
  x_account VARCHAR2(200 BYTE),
  x_safelink_id NUMBER,
  x_min VARCHAR2(30 BYTE),
  x_part_class VARCHAR2(40 BYTE),
  x_service_plan VARCHAR2(250 BYTE),
  x_pgm_start_date DATE,
  x_ship_date DATE,
  x_tracking_no VARCHAR2(30 BYTE),
  x_case_id_number VARCHAR2(255 BYTE),
  x_phone_ready VARCHAR2(10 BYTE)
);
COMMENT ON TABLE sa.xsu_hmo_response IS 'TO SUPPORT IMPORT/EXPORT OF HMO DATA';
COMMENT ON COLUMN sa.xsu_hmo_response.x_batchdate IS 'TIMESTAMP WHICH THE RECORD IS CREATED';
COMMENT ON COLUMN sa.xsu_hmo_response.x_hmo IS 'SHORT NAME FOR HEALTH MAINTENANCE ORGANIZATION  (HMO) - PARTNER';
COMMENT ON COLUMN sa.xsu_hmo_response.x_account IS 'HMO ACCOUNT NUMBER';
COMMENT ON COLUMN sa.xsu_hmo_response.x_safelink_id IS '3RD PARTY CUSTOMER ID - LIFELINE ID';
COMMENT ON COLUMN sa.xsu_hmo_response.x_min IS 'MIN AT REQUEST GENERATED TIME';
COMMENT ON COLUMN sa.xsu_hmo_response.x_part_class IS 'ESN PART NUMBER';
COMMENT ON COLUMN sa.xsu_hmo_response.x_service_plan IS 'SAFELINK PLAN';
COMMENT ON COLUMN sa.xsu_hmo_response.x_pgm_start_date IS 'HMO PROGRAM START DATE';
COMMENT ON COLUMN sa.xsu_hmo_response.x_ship_date IS 'SHIPMENT DATE WHEN THAT PHONE WAS SHIPPED TO FROM THE TICKET ';
COMMENT ON COLUMN sa.xsu_hmo_response.x_tracking_no IS 'TRACKING NUMBER TO ENSURE THAT PHONE WAS RECEIVED ';
COMMENT ON COLUMN sa.xsu_hmo_response.x_case_id_number IS 'REFERENCE TABLE_CASE, ID_NUMBER';
COMMENT ON COLUMN sa.xsu_hmo_response.x_phone_ready IS 'PHONE FLAG, VALUES Y  OR N , TO DETERMINE IF SA.TABLE_X_OTA_FEATURES.X_FREE_DIAL NUMBER IS CORRECTLY ALIGNED WITH THE PHONE NUMBER IN TABLE_SITE';