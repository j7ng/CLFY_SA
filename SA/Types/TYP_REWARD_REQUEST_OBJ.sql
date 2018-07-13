CREATE OR REPLACE TYPE sa."TYP_REWARD_REQUEST_OBJ" FORCE
IS
  OBJECT
  (
    objid                     NUMBER,
    notification_id           VARCHAR2(35 CHAR),
    notification_type         VARCHAR2(50 CHAR),
    notification_date         DATE,
    source_name               VARCHAR2(35 CHAR),
    web_user_objid            NUMBER,
    Benefit_Earning_Objid     NUMBER,
    event_name                VARCHAR2(100 CHAR),
    event_type                VARCHAR2(50 CHAR),
    event_date                DATE,
    event_id                  VARCHAR2(60 CHAR),
    event_status              VARCHAR2(35 CHAR),
    request_process_status	  VARCHAR2(35 CHAR),
    description	              VARCHAR2(250 CHAR),
    Process_Status_Reason     VARCHAR2(250 CHAR),
    amount                    NUMBER,
    denomination              VARCHAR2(35 CHAR),
    Request_received_date  	  DATE,
    ben_earn_transaction_type VARCHAR2(100 CHAR),
    -- Constructor used to initialize the entire type
    CONSTRUCTOR FUNCTION TYP_REWARD_REQUEST_OBJ RETURN SELF AS RESULT
    );
/
CREATE OR REPLACE TYPE BODY sa."TYP_REWARD_REQUEST_OBJ" IS
-- Constructor used to initialize the entire type
CONSTRUCTOR FUNCTION TYP_REWARD_REQUEST_OBJ RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END;

END;
/