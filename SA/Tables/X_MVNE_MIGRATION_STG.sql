CREATE TABLE sa.x_mvne_migration_stg (
  objid NUMBER(22) NOT NULL,
  x_esn VARCHAR2(30 BYTE),
  x_line VARCHAR2(30 BYTE),
  x_sim VARCHAR2(30 BYTE),
  x_plan VARCHAR2(30 BYTE),
  x_imsi VARCHAR2(50 BYTE),
  x_pi_objid NUMBER,
  x_sp_objid NUMBER,
  x_ct_objid NUMBER,
  x_con_objid NUMBER,
  x_pe_objid NUMBER,
  x_wu_objid NUMBER,
  x_action_type VARCHAR2(30 BYTE),
  x_insert_date DATE,
  x_update_date DATE,
  x_cycle_date DATE,
  x_status VARCHAR2(30 BYTE),
  x_bill_update_date DATE,
  x_zip VARCHAR2(30 BYTE),
  x_transaction_id VARCHAR2(30 BYTE),
  x_batch_id VARCHAR2(30 BYTE),
  CONSTRAINT x_mvne_migration_stg_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_mvne_migration_stg IS 'staging table for migration ';
COMMENT ON COLUMN sa.x_mvne_migration_stg.objid IS 'unique sequence ';
COMMENT ON COLUMN sa.x_mvne_migration_stg.x_esn IS 'esn';
COMMENT ON COLUMN sa.x_mvne_migration_stg.x_line IS 'line/min';
COMMENT ON COLUMN sa.x_mvne_migration_stg.x_sim IS 'sim';
COMMENT ON COLUMN sa.x_mvne_migration_stg.x_plan IS 'plan';
COMMENT ON COLUMN sa.x_mvne_migration_stg.x_imsi IS 'imsi';
COMMENT ON COLUMN sa.x_mvne_migration_stg.x_pi_objid IS 'table_part_inst objid ';
COMMENT ON COLUMN sa.x_mvne_migration_stg.x_sp_objid IS 'table_site_part objid';
COMMENT ON COLUMN sa.x_mvne_migration_stg.x_ct_objid IS 'table_x_call_trans objid';
COMMENT ON COLUMN sa.x_mvne_migration_stg.x_con_objid IS 'contact objid';
COMMENT ON COLUMN sa.x_mvne_migration_stg.x_pe_objid IS 'x_program_enrolled objid';
COMMENT ON COLUMN sa.x_mvne_migration_stg.x_wu_objid IS 'table_web_user objid';
COMMENT ON COLUMN sa.x_mvne_migration_stg.x_action_type IS 'action_type :line status active,inactive past due';
COMMENT ON COLUMN sa.x_mvne_migration_stg.x_insert_date IS 'insert date';
COMMENT ON COLUMN sa.x_mvne_migration_stg.x_update_date IS 'update date';
COMMENT ON COLUMN sa.x_mvne_migration_stg.x_cycle_date IS 'cycle date';
COMMENT ON COLUMN sa.x_mvne_migration_stg.x_status IS 'status';
COMMENT ON COLUMN sa.x_mvne_migration_stg.x_bill_update_date IS 'bill update date';
COMMENT ON COLUMN sa.x_mvne_migration_stg.x_zip IS 'zip';
COMMENT ON COLUMN sa.x_mvne_migration_stg.x_transaction_id IS 'transaction id ';
COMMENT ON COLUMN sa.x_mvne_migration_stg.x_batch_id IS 'batch id';