CREATE OR REPLACE TYPE sa.RETURN_MET_SOURCE_OBJ
AS
  object
  (
    VOICE_MTG_SOURCE         varchar2(50),
    SMS_MTG_SOURCE           varchar2(50) ,
    DATA_MTG_SOURCE           varchar2(50) ,
    ILD_MTG_SOURCE           varchar2(50),
   -- SHORT_NAME                  VARCHAR2(50),
    X_TIMEOUT_MINUTES_THRESHOLD NUMBER(22),
    X_DAILY_ATTEMPTS_THRESHOLD  NUMBER(22),
    CONSTRUCTOR
  FUNCTION RETURN_MET_SOURCE_OBJ
    RETURN SELF
  AS
    RESULT );
/