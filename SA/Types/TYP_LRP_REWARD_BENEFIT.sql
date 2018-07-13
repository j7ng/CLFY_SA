CREATE OR REPLACE TYPE sa."TYP_LRP_REWARD_BENEFIT" AS OBJECT (
  objid              NUMBER,
  web_account_id     VARCHAR2(100),
  subscriber_id      VARCHAR2(100),
  min                VARCHAR2(100),
  esn                VARCHAR2(100),
  created_date       DATE,
  benefit_owner      VARCHAR2(100),
  status             VARCHAR2(100),
  notes              VARCHAR2(100),
  benefit_type_code  VARCHAR2(100),
  update_date        DATE,
  expiry_date        DATE,
  brand              VARCHAR2(100),
  quantity           NUMBER,
  value              NUMBER,
  program_name       VARCHAR2(100),
  account_status     VARCHAR2(30),
  pending_quantity	  NUMBER(12,2),          -- CR41473 LRP2
  expired_quantity	  NUMBER(12,2),          -- CR41473 LRP2
  total_quantity	    NUMBER(12,2),            -- CR41473 LRP2
  loyalty_tier        NUMBER,                -- CR41473 LRP2
  -- Constructor used to initialize the entire type
  CONSTRUCTOR FUNCTION typ_lrp_reward_benefit RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY sa."TYP_LRP_REWARD_BENEFIT" IS
-- Constructor used to initialize the entire type
CONSTRUCTOR FUNCTION typ_lrp_reward_benefit RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END;

END;
/