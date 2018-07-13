CREATE OR REPLACE TYPE sa."TYP_LRP_BENEFIT_TRANS" FORCE AS OBJECT (
  objid                         NUMBER,
  trans_date                    TIMESTAMP,
  web_account_id                VARCHAR2(100),
  subscriber_id                 VARCHAR2(100),
  min                           VARCHAR2(100),
  esn                           VARCHAR2(100),
  old_min                       VARCHAR2(100),
  old_esn                       VARCHAR2(100),
  trans_type                    VARCHAR2(100),
  trans_desc                    VARCHAR2(100),
  amount                        NUMBER(12,2),
  benefit_type_code             VARCHAR2(100),
  action                        VARCHAR2(100),
  action_type                   VARCHAR2(100),
  action_reason                 VARCHAR2(100),
  action_notes                  VARCHAR2(300),
  benefit_trans2benefit_trans   NUMBER,
  svc_plan_pin                  VARCHAR2(100),
  svc_plan_id                   VARCHAR2(100),
  brand                         VARCHAR2(100),
  benefit_trans2benefit	        NUMBER,
  agent_login_name              VARCHAR2(100),
  Transaction_Status            VARCHAR2(30),       -- CR41473  LRP2
  maturity_date	                DATE,          		  -- CR41473  LRP2
  expiration_date	        	    DATE,          		  -- CR41473  LRP2
  SOURCE	                	    VARCHAR2(30),       -- CR41473  LRP2
  source_trans_id	        	    VARCHAR2(30),       -- CR41473  LRP2
  -- Constructor used to initialize the entire type
  CONSTRUCTOR FUNCTION typ_lrp_benefit_trans RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY sa."TYP_LRP_BENEFIT_TRANS" IS
-- Constructor used to initialize the entire type
CONSTRUCTOR FUNCTION typ_lrp_benefit_trans RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END;

END;
/