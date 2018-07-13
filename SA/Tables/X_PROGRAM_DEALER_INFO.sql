CREATE TABLE sa.x_program_dealer_info (
  objid NUMBER NOT NULL,
  x_dealer_id VARCHAR2(30 BYTE),
  x_esn VARCHAR2(30 BYTE),
  x_enrolled_date DATE,
  x_created_date DATE DEFAULT SYSDATE,
  x_updated_date DATE DEFAULT SYSDATE,
  x_enrollment_status VARCHAR2(30 BYTE),
  pgm_dealer2pgm_parameter NUMBER,
  pcrf_subscriber_id VARCHAR2(50 BYTE),
  pcrf_group_id VARCHAR2(50 BYTE)
);
COMMENT ON COLUMN sa.x_program_dealer_info.objid IS 'Unique identifier of the record.';
COMMENT ON COLUMN sa.x_program_dealer_info.x_dealer_id IS 'ID of the Dealer';
COMMENT ON COLUMN sa.x_program_dealer_info.x_esn IS 'Phone Serial Number, References part_serial_no in table_part_inst';
COMMENT ON COLUMN sa.x_program_dealer_info.x_enrolled_date IS 'Date os enrollment in plan';
COMMENT ON COLUMN sa.x_program_dealer_info.x_created_date IS 'Date when the record was created';
COMMENT ON COLUMN sa.x_program_dealer_info.x_updated_date IS 'Date when the record was updated';
COMMENT ON COLUMN sa.x_program_dealer_info.x_enrollment_status IS 'Status of the enrollment';
COMMENT ON COLUMN sa.x_program_dealer_info.pgm_dealer2pgm_parameter IS 'Reference to x_program_parameters';
COMMENT ON COLUMN sa.x_program_dealer_info.pcrf_subscriber_id IS 'Unique subscriberID assigned to customer ';
COMMENT ON COLUMN sa.x_program_dealer_info.pcrf_group_id IS 'GroupID of group the customer belongs to';