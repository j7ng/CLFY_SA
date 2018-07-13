CREATE OR REPLACE TYPE sa.meter_source_type AS OBJECT
( meter_source               VARCHAR2(50),
  type                       VARCHAR2(50) ,
  timeout_minutes_threshold  NUMBER(22),
  daily_attempts_threshold   NUMBER(22),
  CONSTRUCTOR FUNCTION meter_source_type RETURN SELF AS RESULT
);
/