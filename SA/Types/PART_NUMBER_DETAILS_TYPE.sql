CREATE OR REPLACE TYPE sa.part_number_details_type
IS
OBJECT  (
          part_number           VARCHAR2(50),
          billing_program_id    NUMBER,
          tax_applicable_flag   VARCHAR2(1),
          proration_applied     VARCHAR2(1),
          amount                NUMBER,
          CONSTRUCTOR  FUNCTION part_number_details_type RETURN SELF AS  RESULT
        );
/
CREATE OR REPLACE TYPE BODY sa.part_number_details_type IS
--
CONSTRUCTOR FUNCTION part_number_details_type RETURN SELF AS RESULT IS
BEGIN
  RETURN;
END;
END;
/