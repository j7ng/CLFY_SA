CREATE OR REPLACE TYPE sa."RED_CARD_PIN_TYPE" FORCE
AS
  OBJECT
  (
    pin                  VARCHAR2(30),
    message              VARCHAR2(1000),
    updated_status       VARCHAR2(1),
    no_of_days           NUMBER,
    min                  VARCHAR2(30),
    -- Constructor used to initialize the entire type
    CONSTRUCTOR
  FUNCTION red_card_pin_type
    RETURN SELF
  AS
    RESULT );
/
CREATE OR REPLACE TYPE BODY sa."RED_CARD_PIN_TYPE" IS
-- Constructor used to initialize the entire type
CONSTRUCTOR FUNCTION red_card_pin_type RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END;
END;
/