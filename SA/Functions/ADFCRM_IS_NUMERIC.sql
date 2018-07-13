CREATE OR REPLACE FUNCTION sa."ADFCRM_IS_NUMERIC" (p_val VARCHAR2)
   RETURN NUMBER
IS
v_val   NUMBER;
BEGIN
   BEGIN
      IF p_val IS NULL OR TRIM (p_val) = ''
      THEN
         RETURN 0;
      END IF;

      SELECT TO_NUMBER (p_val)
        INTO v_val
        FROM DUAL;

      RETURN 1;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;
END;
/