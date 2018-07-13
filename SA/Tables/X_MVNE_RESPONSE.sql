CREATE TABLE sa.x_mvne_response (
  objid NUMBER(22) NOT NULL,
  x_esn VARCHAR2(30 BYTE),
  x_line VARCHAR2(30 BYTE),
  x_sim VARCHAR2(30 BYTE),
  x_imsi VARCHAR2(50 BYTE),
  x_pi_objid NUMBER(22),
  x_sp_objid NUMBER(22),
  x_ct_objid NUMBER(22),
  x_con_objid NUMBER(22),
  x_pe_objid NUMBER(22),
  x_wu_objid NUMBER(22),
  x_action_type VARCHAR2(30 BYTE),
  x_insert_date DATE,
  x_update_date DATE,
  x_processed_date DATE,
  x_status VARCHAR2(50 BYTE),
  x_processed_status VARCHAR2(30 BYTE),
  x_transaction_id VARCHAR2(30 BYTE),
  x_batch_id VARCHAR2(30 BYTE),
  x_error_message VARCHAR2(800 BYTE),
  CONSTRAINT x_mvne_response_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_mvne_response IS 'Migration and transaction response table ';
COMMENT ON COLUMN sa.x_mvne_response.objid IS 'unique sequence';
COMMENT ON COLUMN sa.x_mvne_response.x_esn IS 'esn';
COMMENT ON COLUMN sa.x_mvne_response.x_line IS 'line/min';
COMMENT ON COLUMN sa.x_mvne_response.x_sim IS 'sim';
COMMENT ON COLUMN sa.x_mvne_response.x_imsi IS 'imsi';
COMMENT ON COLUMN sa.x_mvne_response.x_pi_objid IS 'table_part_inst objid ';
COMMENT ON COLUMN sa.x_mvne_response.x_sp_objid IS 'table_site_part objid';
COMMENT ON COLUMN sa.x_mvne_response.x_ct_objid IS 'table_x_call_trans objid';
COMMENT ON COLUMN sa.x_mvne_response.x_con_objid IS 'contact objid';
COMMENT ON COLUMN sa.x_mvne_response.x_pe_objid IS 'x_program_enrolled objid';
COMMENT ON COLUMN sa.x_mvne_response.x_wu_objid IS 'table_web_user objid';
COMMENT ON COLUMN sa.x_mvne_response.x_action_type IS 'transaction action type :Migration/redemption/simchange/minchange';
COMMENT ON COLUMN sa.x_mvne_response.x_insert_date IS 'insert date';
COMMENT ON COLUMN sa.x_mvne_response.x_update_date IS 'update date';
COMMENT ON COLUMN sa.x_mvne_response.x_processed_date IS 'processed date';
COMMENT ON COLUMN sa.x_mvne_response.x_status IS 'status';
COMMENT ON COLUMN sa.x_mvne_response.x_processed_status IS 'processed status for response file';
COMMENT ON COLUMN sa.x_mvne_response.x_transaction_id IS 'transaction id';
COMMENT ON COLUMN sa.x_mvne_response.x_batch_id IS 'batch id';
COMMENT ON COLUMN sa.x_mvne_response.x_error_message IS 'error message';