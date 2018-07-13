CREATE TABLE sa.dealer_commissions_stage (
  signup_id VARCHAR2(60 BYTE),
  provider_id VARCHAR2(30 BYTE),
  prov_cust_status VARCHAR2(30 BYTE),
  prov_cust_last_update DATE,
  process_flag NUMBER,
  process_dated DATE
);
COMMENT ON TABLE sa.dealer_commissions_stage IS 'TABLE TO HOLD THE DATA TO UPDATE FOR  INDEPENDENT DEALERS';
COMMENT ON COLUMN sa.dealer_commissions_stage.signup_id IS 'ID OF THE AGENT SIGNED UP WITH TRACFONE';
COMMENT ON COLUMN sa.dealer_commissions_stage.provider_id IS 'ID GIVEN TO THE AGENT/DEALER UPON SIGNUP WITH OUR PAYMENT PROCESSOR';
COMMENT ON COLUMN sa.dealer_commissions_stage.prov_cust_status IS 'STATUS OF THE DEALER AT OUR PAYMENT PROCESSOR';
COMMENT ON COLUMN sa.dealer_commissions_stage.prov_cust_last_update IS 'LAST UPDATE DATE OF THE DEALER AT OUR PAYMENT PROCESSOR';
COMMENT ON COLUMN sa.dealer_commissions_stage.process_flag IS 'HOLDS 1 OR 0 1 FOR PROCESSED 0 FOR NOT PROCESSED';
COMMENT ON COLUMN sa.dealer_commissions_stage.process_dated IS 'PROCESSED DATE OF THE DEALER AT OUR PAYMENT PROCESSOR';