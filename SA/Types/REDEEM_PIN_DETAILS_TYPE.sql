CREATE OR REPLACE TYPE sa.redeem_pin_details_type
AS OBJECT
(pin              VARCHAR2(20),
 pin_part_number  VARCHAR2(30),
 pin_part_class   VARCHAR2(40),
 pin_plan_type    VARCHAR2(30),
 pin_service_days NUMBER      ,
 pin_status       VARCHAR2(20),
 CONSTRUCTOR  FUNCTION redeem_pin_details_type RETURN SELF AS  RESULT
 );
/