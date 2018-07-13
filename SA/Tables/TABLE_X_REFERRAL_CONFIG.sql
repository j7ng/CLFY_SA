CREATE TABLE sa.table_x_referral_config (
  objid NUMBER NOT NULL,
  referral_id_1 VARCHAR2(10 BYTE),
  referral_id_2 VARCHAR2(10 BYTE),
  start_seq NUMBER,
  end_seq NUMBER,
  start_date DATE,
  end_date DATE,
  spiff NUMBER,
  residual NUMBER(19,2),
  bonus NUMBER,
  extra_bonus NUMBER(19,2),
  "TYPE" VARCHAR2(40 BYTE),
  usage_max_counter NUMBER,
  user_created VARCHAR2(100 BYTE),
  creation_date DATE,
  referral2table_site NUMBER
);
COMMENT ON TABLE sa.table_x_referral_config IS 'table to administer all the B2B referral codes';
COMMENT ON COLUMN sa.table_x_referral_config.referral_id_1 IS '4 or less character code for identifying the Vendor';
COMMENT ON COLUMN sa.table_x_referral_config.referral_id_2 IS '4 or less character code for identifying the Vendor category';
COMMENT ON COLUMN sa.table_x_referral_config.start_seq IS 'Starting Range';
COMMENT ON COLUMN sa.table_x_referral_config.end_seq IS 'Ending Range';
COMMENT ON COLUMN sa.table_x_referral_config.start_date IS 'Code start date';
COMMENT ON COLUMN sa.table_x_referral_config.end_date IS 'Code end date';
COMMENT ON COLUMN sa.table_x_referral_config.spiff IS 'Dollar amount';
COMMENT ON COLUMN sa.table_x_referral_config.residual IS '% amount to calculate the residual (could be recurring)';
COMMENT ON COLUMN sa.table_x_referral_config.bonus IS 'ONE TIME DOLLAR bonus if they meet certain criteria';
COMMENT ON COLUMN sa.table_x_referral_config.extra_bonus IS 'Extra % amount to calculate some extra bonus like loyalty or promotions for vendors etc';
COMMENT ON COLUMN sa.table_x_referral_config."TYPE" IS 'USAGE type of this code';
COMMENT ON COLUMN sa.table_x_referral_config.usage_max_counter IS 'How many times this referral code can be used (after successful validation)';
COMMENT ON COLUMN sa.table_x_referral_config.user_created IS 'User who created this code';
COMMENT ON COLUMN sa.table_x_referral_config.creation_date IS 'Date of code creation';