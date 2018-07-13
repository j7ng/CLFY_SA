CREATE TABLE sa.x_refurb_log (
  esn VARCHAR2(25 BYTE),
  status VARCHAR2(15 BYTE),
  file_name VARCHAR2(50 BYTE),
  log_text VARCHAR2(4000 BYTE),
  log_date DATE,
  sequence_no NUMBER
);
ALTER TABLE sa.x_refurb_log ADD SUPPLEMENTAL LOG GROUP dmtsora304766228_0 (esn, file_name, log_date, log_text, sequence_no, status) ALWAYS;
COMMENT ON TABLE sa.x_refurb_log IS 'Refurbishing Process Log';
COMMENT ON COLUMN sa.x_refurb_log.esn IS 'Phone Serial Number, References table_part_inst';
COMMENT ON COLUMN sa.x_refurb_log.status IS 'Transaction Status: SUCCESS,FAIL';
COMMENT ON COLUMN sa.x_refurb_log.file_name IS 'Process Name: REFURB';
COMMENT ON COLUMN sa.x_refurb_log.log_text IS 'Process Remarks: null';
COMMENT ON COLUMN sa.x_refurb_log.log_date IS 'Timestamp for transaction';
COMMENT ON COLUMN sa.x_refurb_log.sequence_no IS 'Sequence of the Phone';