CREATE OR REPLACE FUNCTION sa."LOAD_TMP_DATA_FUN" (
   p_table IN VARCHAR2,
   p_cnames IN VARCHAR2,
   p_dir IN VARCHAR2,
   p_filename IN VARCHAR2,
   p_delimiter IN VARCHAR2
   DEFAULT '|'
)RETURN NUMBER
IS

   /**************************************************************************************
   * Function Name: load_tmp_data_fun
   * Description :  Load esns data into a temporary table
   * Return      :  insert count
   * Created by  : Vani Adapa
   * Date        : 04/15/2004
   *
   * History
   * -------------------------------------------------------------
   * 04/15/04   1.0       VA                 Initial Release
   * 04/21/05   1.1       VA                 CR3698 - Modified to handle multiple character delimiter
   * 05/05/05   1.2       FL                 CR3698 - Modified to handle variable multi fields
   **************************************************************************************/
   l_input UTL_FILE.file_type;
   l_thecursor INTEGER
   DEFAULT DBMS_SQL.open_cursor;
   l_buffer VARCHAR2 (4000);
   l_lastline VARCHAR2 (4000);
   l_status INTEGER;
   l_colcnt NUMBER
   DEFAULT 0;
   l_cnt NUMBER
   DEFAULT 0;
   l_sep CHAR (1)
   DEFAULT NULL;
   l_errmsg VARCHAR2 (4000);
   --CR3698 Starts
   l_idx PLS_INTEGER;
   l_last_val BOOLEAN := FALSE;
--CR3698 Ends
BEGIN
--CR3698 Starts
   l_idx := 0;
   l_last_val := FALSE;
   --CR3698 Ends
   l_input := UTL_FILE.fopen (p_dir, p_filename, 'r');
   l_buffer := 'insert into ' || p_table || '(' || p_cnames || ') values ( ';
   --CR3698   l_buffer := 'insert into ' || p_table || ' values ( ';
   l_colcnt := LENGTH (p_cnames) - LENGTH (REPLACE (p_cnames, ',', '')) + 1;
   FOR i IN 1 .. l_colcnt
   LOOP
      l_buffer := l_buffer || l_sep || ':b' || i;
      l_sep := ',';
   END LOOP;
   l_buffer := l_buffer || ')';
   DBMS_SQL.parse (l_thecursor, l_buffer, DBMS_SQL.native);
   LOOP
      BEGIN
         UTL_FILE.get_line (l_input, l_lastline);
         EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            EXIT;
      END;
      l_lastline := REPLACE (l_lastline, '"', '');
      --      l_buffer := l_lastline || p_delimiter; --CR3698
      --CR3698 Starts
      l_last_val := FALSE;
      --CR3698 Ends
      FOR i IN 1 .. l_colcnt
      LOOP
--CR3698 Starts
         IF NOT l_last_val
         THEN
	 l_idx := INSTR(l_lastline, p_delimiter);
            IF l_idx > 0
            THEN
	 l_buffer := (SUBSTR(l_lastline, LENGTH(p_delimiter), l_idx - LENGTH(
p_delimiter)));
               l_lastline := SUBSTR(l_lastline, l_idx + LENGTH(p_delimiter));

            ELSE
	 l_buffer := l_lastline;
               l_last_val := TRUE;

            END IF;
            IF l_last_val
            THEN
	 l_buffer := REPLACE(l_buffer, '"');

            END IF;
--CR3698 Starts
         ELSE
		 l_buffer := NULL;

         END IF;
         --CR3698 Ends
         /* DBMS_SQL.bind_variable (
            l_thecursor,
            ':b' || i,
            SUBSTR (l_buffer, 1, INSTR (l_buffer, p_delimiter) - 1)
            );
         l_buffer := SUBSTR (l_buffer, INSTR (l_buffer, p_delimiter) + 1);            */
         DBMS_SQL.bind_variable ( l_thecursor, ':b' || i, l_buffer );
--CR3698 Ends
      END LOOP;
      BEGIN
         l_status := DBMS_SQL.         execute (l_thecursor);
         l_cnt := l_cnt + 1;
         EXCEPTION
         WHEN OTHERS
         THEN
            l_errmsg := SQLERRM;
            INSERT
            INTO error_table VALUES(
               l_errmsg,
               SYSDATE,
               'Load Eligible Esns Into Temp Table',
               l_buffer,
               'LOAD_TMP_DATA'
            );
      END;
   END LOOP;
   DBMS_SQL.close_cursor (l_thecursor);
   UTL_FILE.fclose (l_input);
   COMMIT;
   RETURN l_cnt;
END load_tmp_data_fun;
/