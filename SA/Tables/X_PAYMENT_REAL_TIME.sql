CREATE TABLE sa.x_payment_real_time (
  seq_id NUMBER,
  process_date DATE,
  input_xml VARCHAR2(4000 BYTE),
  output_xml VARCHAR2(4000 BYTE),
  status VARCHAR2(255 BYTE),
  last_updated DATE
);
ALTER TABLE sa.x_payment_real_time ADD SUPPLEMENTAL LOG GROUP dmtsora681817826_0 (input_xml, last_updated, output_xml, process_date, seq_id, status) ALWAYS;
COMMENT ON TABLE sa.x_payment_real_time IS 'This table stores the xml message and response for real time payments for billing programs.  It is accessed by package: BILLING_REAL_TIME_PKG';
COMMENT ON COLUMN sa.x_payment_real_time.seq_id IS 'Internal Record Id';
COMMENT ON COLUMN sa.x_payment_real_time.process_date IS 'Date of creation';
COMMENT ON COLUMN sa.x_payment_real_time.input_xml IS 'Request XML to be send to CyberSource';
COMMENT ON COLUMN sa.x_payment_real_time.output_xml IS 'Response XML from CyberSource';
COMMENT ON COLUMN sa.x_payment_real_time.status IS 'General Status of the request';
COMMENT ON COLUMN sa.x_payment_real_time.last_updated IS 'Date Time Last Update';