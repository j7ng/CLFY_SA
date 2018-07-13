CREATE OR REPLACE TYPE sa.RED_CARD_PIN_DAYS_TYPE 
AS
  OBJECT
  (
    pin                  VARCHAR2(30),
    brm_service_days      NUMBER     ,
    CONSTRUCTOR FUNCTION red_card_pin_days_type  RETURN SELF  AS RESULT );
/