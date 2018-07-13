CREATE OR REPLACE TYPE sa."ESN_PIN_SMP_DET_TYPE" FORCE
IS
  OBJECT
  (
    esn                          VARCHAR2(35),
    pin                          VARCHAR2(35),
    smp                          VARCHAR2(35),
    esn_objid                    NUMBER,
    service_plan_name            VARCHAR2(100),
    service_plan_part_number     VARCHAR2(30),
    service_plan_part_class_name VARCHAR2(40),
	service_plan_group           VARCHAR2(50) ,
	error_code                   VARCHAR2(50) ,
	error_message                VARCHAR2(1000),
    -- Constructor used to initialize the entire type
    CONSTRUCTOR
  FUNCTION ESN_PIN_SMP_DET_TYPE
    RETURN SELF
  AS
    RESULT );
/
CREATE OR REPLACE TYPE BODY sa."ESN_PIN_SMP_DET_TYPE" IS
-- Constructor used to initialize the entire type
CONSTRUCTOR FUNCTION ESN_PIN_SMP_DET_TYPE RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END;

END;
/