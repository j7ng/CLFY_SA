CREATE TABLE sa.x_return_log_dtl (
  objid NUMBER NOT NULL,
  return_log_hdr_objid NUMBER NOT NULL,
  part_number VARCHAR2(30 BYTE),
  esn VARCHAR2(30 BYTE),
  smp VARCHAR2(30 BYTE),
  is_tracfone_flag VARCHAR2(1 BYTE),
  pin_status VARCHAR2(25 BYTE),
  void_pin_flag VARCHAR2(1 BYTE),
  created_date DATE,
  modified_date DATE,
  sim VARCHAR2(50 BYTE),
  sim_status VARCHAR2(50 BYTE),
  accessory_serial VARCHAR2(50 BYTE),
  CONSTRAINT x_return_log_dtl_prime_idx PRIMARY KEY (objid),
  CONSTRAINT x_return_log_dtl_fore_idx FOREIGN KEY (return_log_hdr_objid) REFERENCES sa.x_return_log_hdr (objid)
);
COMMENT ON COLUMN sa.x_return_log_dtl.objid IS 'Internal record number';
COMMENT ON COLUMN sa.x_return_log_dtl.return_log_hdr_objid IS 'Link to X_Returns_LogHdr Objid';
COMMENT ON COLUMN sa.x_return_log_dtl.part_number IS 'Partnumber for each Refund Lineitem';
COMMENT ON COLUMN sa.x_return_log_dtl.esn IS 'It denotes the PartSerialNo of the Phone';
COMMENT ON COLUMN sa.x_return_log_dtl.smp IS 'It denotes the PartserialNof the redemption cards';
COMMENT ON COLUMN sa.x_return_log_dtl.is_tracfone_flag IS 'Y/N to determine the return belongs to TF';
COMMENT ON COLUMN sa.x_return_log_dtl.pin_status IS 'PIN Status (i.e. Redeemed, Not Redeemed, etc';
COMMENT ON COLUMN sa.x_return_log_dtl.void_pin_flag IS 'Y/N to determine if the PIN is VOID';
COMMENT ON COLUMN sa.x_return_log_dtl.created_date IS 'Creation Date';
COMMENT ON COLUMN sa.x_return_log_dtl.modified_date IS 'Modified Date';