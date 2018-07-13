CREATE TABLE sa.x_program_batch (
  objid NUMBER,
  batch_sub_date DATE,
  batch_rec_date DATE,
  payment_batch2x_cc_parms VARCHAR2(15 BYTE),
  batch_status VARCHAR2(50 BYTE),
  x_batch_id NUMBER,
  x_priority VARCHAR2(20 BYTE)
);
ALTER TABLE sa.x_program_batch ADD SUPPLEMENTAL LOG GROUP dmtsora2091162379_0 (batch_rec_date, batch_status, batch_sub_date, objid, payment_batch2x_cc_parms, x_batch_id) ALWAYS;
COMMENT ON TABLE sa.x_program_batch IS 'Control table for billing payments batch.';
COMMENT ON COLUMN sa.x_program_batch.batch_sub_date IS 'Date of Submission';
COMMENT ON COLUMN sa.x_program_batch.batch_rec_date IS 'Date of Recording';
COMMENT ON COLUMN sa.x_program_batch.payment_batch2x_cc_parms IS 'Reference to objid table_x_cc_parms';
COMMENT ON COLUMN sa.x_program_batch.batch_status IS 'Processing Status of the batch';
COMMENT ON COLUMN sa.x_program_batch.x_batch_id IS 'Sequential ID Number';
COMMENT ON COLUMN sa.x_program_batch.x_priority IS 'Priority for batch process';