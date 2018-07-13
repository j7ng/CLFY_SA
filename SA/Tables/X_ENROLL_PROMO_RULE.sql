CREATE TABLE sa.x_enroll_promo_rule (
  objid NUMBER,
  promo_objid NUMBER,
  x_calculation_type NUMBER,
  x_promo_cycle_start NUMBER,
  x_frequency_duration NUMBER,
  x_max_discount NUMBER,
  x_increment_by NUMBER,
  x_transfer_check VARCHAR2(5 BYTE),
  x_priority NUMBER,
  x_script_id VARCHAR2(20 BYTE),
  x_promo_sponsor VARCHAR2(60 BYTE) DEFAULT 'TRACFONE' NOT NULL
);
COMMENT ON TABLE sa.x_enroll_promo_rule IS 'TABLE IS USED TO PROVIDE SPECIFIC DETAILS ABOUT THE PROMOTION';
COMMENT ON COLUMN sa.x_enroll_promo_rule.objid IS 'INTERNAL RECORD ID ';
COMMENT ON COLUMN sa.x_enroll_promo_rule.promo_objid IS 'REFERENCE TO OBJID OF TABLE_X_PROMOTION';
COMMENT ON COLUMN sa.x_enroll_promo_rule.x_calculation_type IS '0:NOT CUMULATING, 1: CUMULATING';
COMMENT ON COLUMN sa.x_enroll_promo_rule.x_promo_cycle_start IS 'ON WHAT CYCLE SHOULD THE PROMOTION FIRST APPLY? IF 0, APPLIES ON CHECKOUT';
COMMENT ON COLUMN sa.x_enroll_promo_rule.x_frequency_duration IS 'CYCLE FREQUENCY AT WHICH THE PROMOTION APPLIES';
COMMENT ON COLUMN sa.x_enroll_promo_rule.x_max_discount IS 'MAXIMUM CUMULATIVE DISCOUNT';
COMMENT ON COLUMN sa.x_enroll_promo_rule.x_increment_by IS 'DISCOUNT INCREMENT PER CYCLE';
COMMENT ON COLUMN sa.x_enroll_promo_rule.x_transfer_check IS 'CAN THE PROMO BE TRANSFERED TO ANOTHER ESN';
COMMENT ON COLUMN sa.x_enroll_promo_rule.x_priority IS 'RULE PRIORIT';
COMMENT ON COLUMN sa.x_enroll_promo_rule.x_script_id IS 'RELATIONSHIP WITH THE SCRIPT DESCRIBING THIS PROMOTION';
COMMENT ON COLUMN sa.x_enroll_promo_rule.x_promo_sponsor IS 'Name of sponsor for promotion default TRACFONE';