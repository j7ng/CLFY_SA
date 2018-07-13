CREATE TABLE sa.x_nlad_response_log (
  objid NUMBER,
  x_failedvalidationerrors VARCHAR2(200 BYTE),
  x_resolutionid VARCHAR2(200 BYTE),
  x_malformeddocument VARCHAR2(200 BYTE),
  x_personisduplicated VARCHAR2(200 BYTE),
  x_statuscode VARCHAR2(200 BYTE),
  x_addressisduplicated VARCHAR2(200 BYTE),
  x_enrollmentnumber VARCHAR2(200 BYTE),
  x_enrollmentchannel VARCHAR2(200 BYTE),
  x_nladerrormessage VARCHAR2(200 BYTE),
  x_phonenumberisduplicated VARCHAR2(200 BYTE),
  x_reference_id VARCHAR2(400 BYTE),
  x_batch_file_date DATE
);
COMMENT ON COLUMN sa.x_nlad_response_log.objid IS 'Unique identifier for transaction NLAD';
COMMENT ON COLUMN sa.x_nlad_response_log.x_failedvalidationerrors IS 'Unique identifier for transaction NLAD';
COMMENT ON COLUMN sa.x_nlad_response_log.x_resolutionid IS 'Unique identifier for transaction NLAD';
COMMENT ON COLUMN sa.x_nlad_response_log.x_malformeddocument IS 'Unique identifier for transaction NLAD';
COMMENT ON COLUMN sa.x_nlad_response_log.x_personisduplicated IS 'Unique identifier for transaction NLAD';
COMMENT ON COLUMN sa.x_nlad_response_log.x_statuscode IS 'Unique identifier for transaction NLAD';
COMMENT ON COLUMN sa.x_nlad_response_log.x_addressisduplicated IS 'Unique identifier for transaction NLAD';
COMMENT ON COLUMN sa.x_nlad_response_log.x_enrollmentnumber IS 'Unique identifier for transaction NLAD';
COMMENT ON COLUMN sa.x_nlad_response_log.x_enrollmentchannel IS 'Unique identifier for transaction NLAD';
COMMENT ON COLUMN sa.x_nlad_response_log.x_nladerrormessage IS 'Unique identifier for transaction NLAD';
COMMENT ON COLUMN sa.x_nlad_response_log.x_phonenumberisduplicated IS 'Unique identifier for transaction NLAD';
COMMENT ON COLUMN sa.x_nlad_response_log.x_reference_id IS 'Unique identifier for transaction NLAD';
COMMENT ON COLUMN sa.x_nlad_response_log.x_batch_file_date IS 'Unique identifier for transaction NLAD';