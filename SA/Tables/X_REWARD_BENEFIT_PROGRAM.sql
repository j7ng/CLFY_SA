CREATE TABLE sa.x_reward_benefit_program (
  objid NUMBER NOT NULL,
  program_name VARCHAR2(100 BYTE),
  program_desc VARCHAR2(1000 BYTE),
  benefit_type_code VARCHAR2(100 BYTE),
  benefit_unit VARCHAR2(100 BYTE),
  benefit_value NUMBER,
  benefit_priority NUMBER,
  partial_usage_allowed VARCHAR2(1 BYTE),
  benefit_owner VARCHAR2(100 BYTE),
  brand VARCHAR2(100 BYTE),
  start_date DATE,
  end_date DATE,
  min_threshold_value NUMBER,
  max_threshold_value NUMBER,
  CONSTRAINT ben_prog_objid_pk PRIMARY KEY (objid),
  CONSTRAINT ben_prog_uq UNIQUE (program_name,benefit_type_code,benefit_unit,benefit_owner,brand)
);
COMMENT ON TABLE sa.x_reward_benefit_program IS 'Lookup table which stores the benefit program that customer can earn';
COMMENT ON COLUMN sa.x_reward_benefit_program.objid IS 'Unique record identifier';
COMMENT ON COLUMN sa.x_reward_benefit_program.program_name IS 'UPGRADE_PLANS/UPGRADE_PROGRAM/LOYALTY_PROGRAM';
COMMENT ON COLUMN sa.x_reward_benefit_program.program_desc IS 'Description of the program';
COMMENT ON COLUMN sa.x_reward_benefit_program.benefit_type_code IS 'Type of Benefit : UPGRADE_BENEFITS / UPGRADE_POINTS / LOYALTY_POINTS';
COMMENT ON COLUMN sa.x_reward_benefit_program.benefit_unit IS 'Unit of Benefit being offered (DOLLARS | MINUTES | POINTS | DATA | etc';
COMMENT ON COLUMN sa.x_reward_benefit_program.benefit_value IS 'Actual value of the Benefit';
COMMENT ON COLUMN sa.x_reward_benefit_program.benefit_priority IS 'Priority of this benefit compared to others of same type; 0 if N/A  ';
COMMENT ON COLUMN sa.x_reward_benefit_program.partial_usage_allowed IS 'One of: Y/N; Y if this benefit type can be partially used; N if benefit use is all or none';
COMMENT ON COLUMN sa.x_reward_benefit_program.benefit_owner IS 'Who owns the benefit { ESN | MIN | SID | ACCOUNT }';
COMMENT ON COLUMN sa.x_reward_benefit_program.brand IS 'NET10(NT) / SIMPLEMOBILE(SM) / STRAIGHTTALK(ST) / TRACFONE(TF) / TELCEL(TC) / TOTALWIRELESS(TW) / SAFELINK (SL)';
COMMENT ON COLUMN sa.x_reward_benefit_program.start_date IS 'Date program starts being available for customers';
COMMENT ON COLUMN sa.x_reward_benefit_program.end_date IS 'Date program stops being available for customers';
COMMENT ON COLUMN sa.x_reward_benefit_program.min_threshold_value IS 'Used to define minimum amount of points needed before they can be used';
COMMENT ON COLUMN sa.x_reward_benefit_program.max_threshold_value IS 'Used to define max amount of points that can be earned';