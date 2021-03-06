CREATE OR REPLACE TYPE sa.REWARD_SERVICE_INFO_OBJ IS OBJECT (
OBJID                    NUMBER,
SERVICE_PLAN_OBJID       NUMBER(22),
REWARD_PROGRAM_OBJID       NUMBER,
REWARD_POINT               NUMBER(22),
START_DATE                  DATE,
END_DATE                      DATE,
BRAND                   varchar2(100),
SOURCE_SYSTEM           VARCHAR2(100),
LAST_UPDATED_DATE       DATE,
  CONSTRUCTOR FUNCTION REWARD_SERVICE_INFO_OBJ   RETURN SELF
  AS
    RESULT
);
/