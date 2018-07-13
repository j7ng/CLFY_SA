CREATE OR REPLACE FUNCTION sa."VALIDATE_ACH_NEXT_CHARGE_DATE" (
   i_x_prog_class     IN   VARCHAR2,
   i_x_status         IN   VARCHAR2,
   i_x_program_name   IN   VARCHAR2
)
   RETURN VARCHAR2 DETERMINISTIC
IS
BEGIN
   IF     i_x_prog_class = 'SWITCHBASE'
      AND i_x_status = 'RECURACHPENDING'
      AND i_x_program_name LIKE 'GoSmart%'
   THEN
      RETURN 'Y';
   ELSE
      RETURN 'N';
   END IF;

   RETURN 'N';
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN 'N';
END;
/