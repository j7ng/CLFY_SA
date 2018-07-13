CREATE TABLE sa.x_rate_plan_change_migr (
  x_esn VARCHAR2(30 BYTE) NOT NULL,
  x_status VARCHAR2(50 BYTE) DEFAULT 'INSERTED' NOT NULL,
  x_trans_date DATE DEFAULT SYSDATE,
  x_error_msg VARCHAR2(2000 BYTE),
  x_update_date DATE DEFAULT SYSDATE
);
COMMENT ON TABLE sa.x_rate_plan_change_migr IS 'TEMP TABLE TO MIGRATE TFLTE TO TFWAP ';
COMMENT ON COLUMN sa.x_rate_plan_change_migr.x_esn IS 'ESN';
COMMENT ON COLUMN sa.x_rate_plan_change_migr.x_status IS 'DEFAULT IS INSERTED. PROCESSED, OR FAILED';
COMMENT ON COLUMN sa.x_rate_plan_change_migr.x_trans_date IS 'TRANSACTION DATE';
COMMENT ON COLUMN sa.x_rate_plan_change_migr.x_error_msg IS 'FAILER REASON';
COMMENT ON COLUMN sa.x_rate_plan_change_migr.x_update_date IS 'LAST MODIFICATION DATE';