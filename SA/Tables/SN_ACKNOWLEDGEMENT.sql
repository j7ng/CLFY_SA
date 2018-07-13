CREATE TABLE sa.sn_acknowledgement (
  objid NUMBER(38,10),
  x_status_date DATE,
  x_status VARCHAR2(20 BYTE),
  x_sourcesystem VARCHAR2(30 BYTE),
  x_client_batch_id VARCHAR2(30 BYTE),
  x_customer_id NUMBER(38,10),
  x_contract_no VARCHAR2(30 BYTE),
  x_esn VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  x_action_code VARCHAR2(3 BYTE),
  x_error_code VARCHAR2(1000 BYTE),
  x_error_desc VARCHAR2(1000 BYTE),
  x_result VARCHAR2(1000 BYTE),
  ack_file_name VARCHAR2(30 BYTE),
  load_date DATE,
  x_refund NUMBER(22)
);
COMMENT ON TABLE sa.sn_acknowledgement IS 'THIS TABLE STORES SERVICE NET ACKNOWLEDGEMENTS';
COMMENT ON COLUMN sa.sn_acknowledgement.objid IS 'INTERNAL UNIQUE IDENTIFIER';
COMMENT ON COLUMN sa.sn_acknowledgement.x_status_date IS 'STATUS IS CURRENT DATE';
COMMENT ON COLUMN sa.sn_acknowledgement.x_status IS 'STATUS OF THE RECORD (EX: NEW)';
COMMENT ON COLUMN sa.sn_acknowledgement.x_sourcesystem IS 'SOURCE SYSTEM';
COMMENT ON COLUMN sa.sn_acknowledgement.x_client_batch_id IS 'CLIEN BATCH ID';
COMMENT ON COLUMN sa.sn_acknowledgement.x_customer_id IS 'CUSTOMER ID';
COMMENT ON COLUMN sa.sn_acknowledgement.x_contract_no IS 'CONTRACT NO';
COMMENT ON COLUMN sa.sn_acknowledgement.x_esn IS 'ESN NUMBER';
COMMENT ON COLUMN sa.sn_acknowledgement.x_min IS 'X_MIN VALUE';
COMMENT ON COLUMN sa.sn_acknowledgement.x_action_code IS 'ACTION CODE';
COMMENT ON COLUMN sa.sn_acknowledgement.x_error_code IS 'ERROR CODE';
COMMENT ON COLUMN sa.sn_acknowledgement.x_error_desc IS 'ERROR DESCRIPTION';
COMMENT ON COLUMN sa.sn_acknowledgement.x_result IS 'RESULT';
COMMENT ON COLUMN sa.sn_acknowledgement.ack_file_name IS 'NAME OF ACK FILE';
COMMENT ON COLUMN sa.sn_acknowledgement.load_date IS 'CURRENT LOAD DATE';
COMMENT ON COLUMN sa.sn_acknowledgement.x_refund IS 'RETAIL REFUND (EXCLUSIVE OF TAXES)';