CREATE OR REPLACE PROCEDURE sa."INSERT_ERROR_TAB_PROC" (
      ip_action         IN   VARCHAR2,
      ip_key            IN   VARCHAR2,
      ip_program_name   IN   VARCHAR2,
	  ip_error_text  IN VARCHAR2 DEFAULT NULL

   )
   IS



      sql_code       NUMBER;
      sql_err        VARCHAR2 (300);
      v_error_text   VARCHAR2 (1000);
      v_procedure_name CONSTANT VARCHAR2(200) :='insert_error_tab_proc()';
   BEGIN

      sql_code := SQLCODE;
      sql_err := SQLERRM;

	  IF ip_error_text IS NULL THEN
         v_error_text :=
         'SQL Error Code : ' ||
         to_char (sql_code) ||
         ' Error Message : ' ||
         sql_err;

	  ELSE
	    v_error_text := ip_error_text;
	  END IF;



      INSERT INTO ERROR_TABLE
                  (ERROR_TEXT, ERROR_DATE, ACTION, KEY, PROGRAM_NAME)
           VALUES(v_error_text, sysdate, ip_action, ip_key, ip_program_name);

   END insert_error_tab_proc;
/