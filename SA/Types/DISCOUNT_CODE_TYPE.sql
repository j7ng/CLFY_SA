CREATE OR REPLACE TYPE sa.discount_code_type IS OBJECT
(
    discount_code 		    VARCHAR2(100),
    CONSTRUCTOR  FUNCTION discount_code_type RETURN SELF AS  RESULT
);
/