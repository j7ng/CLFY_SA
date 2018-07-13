CREATE TABLE sa.x_ct_pcrf_log (
  call_trans_objid NUMBER(10) NOT NULL,
  processed_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT pk_ct_pcrf_log PRIMARY KEY (call_trans_objid)
);
COMMENT ON TABLE sa.x_ct_pcrf_log IS 'Table to maintain ig transaction ids processed by pcrf';
COMMENT ON COLUMN sa.x_ct_pcrf_log.call_trans_objid IS 'Call Transaction id unique identifier';
COMMENT ON COLUMN sa.x_ct_pcrf_log.processed_timestamp IS 'Time and date of when the row was processed';