CREATE TABLE sa.x_dealer_commissions (
  objid NUMBER,
  dealer_comms2employee NUMBER,
  "ROLE" VARCHAR2(50 BYTE) CONSTRAINT check_role CHECK ("ROLE" IN ('REP','DEALER','MASTER_AGENT','RETAILER')),
  title VARCHAR2(100 BYTE),
  signup_id VARCHAR2(60 BYTE),
  signup_confirm_code VARCHAR2(25 BYTE),
  terms_accept_date DATE,
  provider_id VARCHAR2(30 BYTE),
  prov_cust_status VARCHAR2(30 BYTE),
  prov_cust_last_update DATE,
  phone_num VARCHAR2(30 BYTE),
  create_date DATE,
  last_update_date DATE,
  spiff_ma_flag NUMBER(22)
);
COMMENT ON TABLE sa.x_dealer_commissions IS 'TABLE TO HOLD THE SPIFF AND OTHER INFO FOR INDEPENDENT DEALERS';
COMMENT ON COLUMN sa.x_dealer_commissions.objid IS 'UNIQUE OBJID  (FED FROM SEQ_DEALER_COMMS)';
COMMENT ON COLUMN sa.x_dealer_commissions.dealer_comms2employee IS 'POINTER TO THE TABLE_EMPLOYEE(OBJID)';
COMMENT ON COLUMN sa.x_dealer_commissions."ROLE" IS 'DESCRIPTION OF THE USER ROLE';
COMMENT ON COLUMN sa.x_dealer_commissions.title IS 'DESCRIPTION OF THE USER TITLE';
COMMENT ON COLUMN sa.x_dealer_commissions.signup_id IS 'ID OF THE AGENT SIGNED UP WITH TRACFONE';
COMMENT ON COLUMN sa.x_dealer_commissions.signup_confirm_code IS 'CONFIRMATION CODE GIVEN TO THE AGENT UPON SIGNUP';
COMMENT ON COLUMN sa.x_dealer_commissions.terms_accept_date IS 'CONFIRMATION CODE GIVEN TO THE AGENT UPON SIGNUP';
COMMENT ON COLUMN sa.x_dealer_commissions.provider_id IS 'ID GIVEN TO THE AGENT/DEALER UPON SIGNUP WITH OUR PAYMENT PROCESSOR';
COMMENT ON COLUMN sa.x_dealer_commissions.prov_cust_status IS 'STATUS OF THE DEALER AT OUR PAYMENT PROCESSOR';
COMMENT ON COLUMN sa.x_dealer_commissions.prov_cust_last_update IS 'LAST UPDATE DATE OF THE DEALER AT OUR PAYMENT PROCESSOR';
COMMENT ON COLUMN sa.x_dealer_commissions.phone_num IS 'LAST UPDATE DATE OF DEALER IN TRACFONE  SYSTEMS';