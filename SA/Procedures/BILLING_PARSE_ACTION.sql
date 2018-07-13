CREATE OR REPLACE PROCEDURE sa.billing_parse_action (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_parse_action                     							 		 */
/*                                                                                          	 */
/* Purpose      :   Parsing procedure															 */
/*                                                                                          	 */
/*                                                                                          	 */
/* Platforms    :   Oracle 9i                                                    				 */
/*                                                                                          	 */
/* Author       :   RSI                                                            	  			 */
/*                                                                                          	 */
/* Date         :   01-19-2006																	 */
/* REVISIONS:                                                         							 */
/* VERSION  DATE        WHO          PURPOSE                                  					 */
/* -------  ---------- 	-----  		 --------------------------------------------   			 */
/*  1.0                       		 Initial  Revision                               			 */
/*                                                                                          	 */
/*                                                                                          	 */
/*************************************************************************************************/
   p_string          IN       VARCHAR2,
   p_graceperiod     OUT      NUMBER,
   p_penalty         OUT      NUMBER,
   p_coolingperiod   OUT      NUMBER,
   p_days            OUT      NUMBER,
   op_result         OUT      NUMBER,
   op_msg            OUT      VARCHAR2
)
IS
   l_string        VARCHAR2 (2000) := p_string;
   l_index         NUMBER;
   l_loop_flag     BOOLEAN         := TRUE;
   l_param         VARCHAR2 (50);
   l_value         NUMBER;
   l_temp_string   VARCHAR2 (255);
BEGIN
   WHILE (l_loop_flag)
   LOOP
      -- Some processing done here
      l_index := INSTR (l_string, ';'); -- Get the index of the ';''

      IF (    l_index = 0
          AND LENGTH (l_string) = 0
         ) -- We have a parsed all the strings.
      THEN
         l_loop_flag := FALSE; --- Do not parse anymore
      ELSE
         -- We have valid data. Parse the string given.
         IF (l_index = 0)
         THEN
            l_index :=   LENGTH (l_string)
                       + 1;
            l_loop_flag := FALSE;
         END IF;

         l_temp_string := SUBSTR (l_string, 1,   l_index
                                               - 1);
         l_param := SUBSTR (l_temp_string, 1,   INSTR (l_temp_string, '=')
                                              - 1);
         l_value :=
            TO_NUMBER (SUBSTR (l_temp_string,   INSTR (l_temp_string, '=')
                                              + 1));

         IF (l_param = 'GP')
         THEN
            p_graceperiod := l_value;
         ELSIF (l_param = 'SCP' or l_param = 'CP')
         THEN
            p_coolingperiod := l_value;
         ELSIF (l_param = 'PENALTY')
         THEN
            p_penalty := l_value;
         ELSIF (l_param = 'DAYS')
         THEN
            p_days := l_value;
         END IF;

         l_string := SUBSTR (l_string,   l_index
                                       + 1);
      END IF;
   END LOOP;

   op_result := 0;
EXCEPTION
   WHEN OTHERS
   THEN
      op_result := -100;
END billing_parse_action;
/