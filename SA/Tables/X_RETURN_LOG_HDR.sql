CREATE TABLE sa.x_return_log_hdr (
  objid NUMBER NOT NULL,
  order_id VARCHAR2(50 BYTE) NOT NULL,
  rma_id VARCHAR2(50 BYTE) NOT NULL,
  request_payload CLOB,
  return_stage_code VARCHAR2(10 BYTE),
  return_status_code NUMBER,
  response_payload CLOB,
  retrigger_stage VARCHAR2(5 BYTE),
  comments VARCHAR2(100 BYTE),
  refund_payload CLOB,
  refund_stage_code VARCHAR2(50 BYTE),
  refund_status_code NUMBER,
  refund_resp_payload CLOB,
  created_date DATE,
  modified_date DATE,
  CONSTRAINT x_return_log_hdr_prime_idx PRIMARY KEY (objid),
  CONSTRAINT x_return_log_hdr_fore_idx FOREIGN KEY (return_stage_code) REFERENCES sa.x_return_stage (return_stage_code),
  CONSTRAINT x_return_log_hdr_fore_idx2 FOREIGN KEY (return_status_code) REFERENCES sa.x_return_status (return_status_code)
);
COMMENT ON COLUMN sa.x_return_log_hdr.objid IS 'Internal record number';
COMMENT ON COLUMN sa.x_return_log_hdr.order_id IS 'Commerce Order Id';
COMMENT ON COLUMN sa.x_return_log_hdr.rma_id IS 'OFS Provided RMA id';
COMMENT ON COLUMN sa.x_return_log_hdr.request_payload IS 'Input request from OFS for processing refunds';
COMMENT ON COLUMN sa.x_return_log_hdr.return_stage_code IS 'Indicates the current stage in the flow ';
COMMENT ON COLUMN sa.x_return_log_hdr.return_status_code IS 'Indicates the current status in the flow ';
COMMENT ON COLUMN sa.x_return_log_hdr.response_payload IS 'To store the Response Payload';
COMMENT ON COLUMN sa.x_return_log_hdr.retrigger_stage IS 'Place holder for Re-Triggering';
COMMENT ON COLUMN sa.x_return_log_hdr.comments IS 'Additional Notes if any';
COMMENT ON COLUMN sa.x_return_log_hdr.refund_payload IS 'Input request prepared by SOA for processing refunds with
CyberSource and SmartPay';
COMMENT ON COLUMN sa.x_return_log_hdr.refund_stage_code IS 'To determine current refund stage REF-I, REF-P';
COMMENT ON COLUMN sa.x_return_log_hdr.refund_status_code IS 'To determine current refund status SUCCESS, FAILURE';
COMMENT ON COLUMN sa.x_return_log_hdr.refund_resp_payload IS 'To store the Refund response Payload';
COMMENT ON COLUMN sa.x_return_log_hdr.created_date IS 'Creation Date';
COMMENT ON COLUMN sa.x_return_log_hdr.modified_date IS 'Modified Date';