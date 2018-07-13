CREATE OR REPLACE TYPE sa.customer_queued_card_type AS OBJECT
(
  smp                     VARCHAR2(30)  ,
  ext                     VARCHAR2(10)  ,
  queued_days             NUMBER(5)     ,
  part_number             VARCHAR2(30)  ,
  response                VARCHAR2(1000),
  CONSTRUCTOR FUNCTION customer_queued_card_type RETURN SELF AS RESULT
  --MEMBER FUNCTION get ( i_esn IN VARCHAR2 ) RETURN customer_queued_card_tab
);
/
CREATE OR REPLACE TYPE BODY sa.customer_queued_card_type IS

CONSTRUCTOR FUNCTION customer_queued_card_type RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END customer_queued_card_type;

END;
/