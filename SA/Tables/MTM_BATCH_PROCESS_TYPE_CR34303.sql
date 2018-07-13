CREATE TABLE sa.mtm_batch_process_type_cr34303 (
  x_prgm_objid NUMBER,
  x_process_type VARCHAR2(30 BYTE),
  x_priority VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.mtm_batch_process_type_cr34303 IS 'x_program_parameters with their priority in batch process.';
COMMENT ON COLUMN sa.mtm_batch_process_type_cr34303.x_prgm_objid IS 'Internal record number';
COMMENT ON COLUMN sa.mtm_batch_process_type_cr34303.x_process_type IS 'Type of process';
COMMENT ON COLUMN sa.mtm_batch_process_type_cr34303.x_priority IS 'Priority';