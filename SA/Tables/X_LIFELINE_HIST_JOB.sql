CREATE TABLE sa.x_lifeline_hist_job (
  objid NUMBER NOT NULL,
  x_start_date DATE,
  x_end_date DATE,
  x_batch_id VARCHAR2(50 BYTE) NOT NULL,
  x_action_status VARCHAR2(50 BYTE) NOT NULL CONSTRAINT ll_sttatus_constr CHECK (X_ACTION_STATUS IN ('SUCCESS', 'FAILURE')),
  x_jobname VARCHAR2(50 BYTE),
  x_processed_cnt NUMBER(22)
);
COMMENT ON TABLE sa.x_lifeline_hist_job IS 'Safelink job processing history table';
COMMENT ON COLUMN sa.x_lifeline_hist_job.objid IS 'Internal Record Id, Primary Key';
COMMENT ON COLUMN sa.x_lifeline_hist_job.x_start_date IS 'Job Processing Start Date';
COMMENT ON COLUMN sa.x_lifeline_hist_job.x_end_date IS 'Job Processing End Date';
COMMENT ON COLUMN sa.x_lifeline_hist_job.x_batch_id IS 'Barch Processing ID mnemonic';
COMMENT ON COLUMN sa.x_lifeline_hist_job.x_action_status IS 'Batch Processing Status';
COMMENT ON COLUMN sa.x_lifeline_hist_job.x_jobname IS 'Description of the batch process ';