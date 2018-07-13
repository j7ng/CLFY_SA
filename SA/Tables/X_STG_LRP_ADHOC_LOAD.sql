CREATE TABLE sa.x_stg_lrp_adhoc_load (
  web_account_id VARCHAR2(30 BYTE),
  esn VARCHAR2(30 BYTE),
  "MIN" VARCHAR2(30 BYTE),
  points NUMBER(*,0),
  "ACTION" VARCHAR2(10 BYTE),
  reason VARCHAR2(2000 BYTE),
  benefit_type VARCHAR2(100 BYTE)
);
COMMENT ON TABLE sa.x_stg_lrp_adhoc_load IS 'Table will contain list of Account/min/esn loaded from Add Points Job for LRP';
COMMENT ON COLUMN sa.x_stg_lrp_adhoc_load.web_account_id IS 'ACCOUNT ID of the customer';
COMMENT ON COLUMN sa.x_stg_lrp_adhoc_load.esn IS 'ESN of the customer';
COMMENT ON COLUMN sa.x_stg_lrp_adhoc_load."MIN" IS 'MIN of the customer';
COMMENT ON COLUMN sa.x_stg_lrp_adhoc_load.points IS 'number of points to be added to customer';