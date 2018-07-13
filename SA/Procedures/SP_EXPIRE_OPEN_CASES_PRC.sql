CREATE OR REPLACE PROCEDURE sa.SP_expire_open_cases_prc
IS

   /********************************************************************************/
   /* Copyright ? 2005 Tracfone Wireless Inc. All rights reserved                  */
   /*                                                                              */
   /* Name         :   SP_expire_open_cases_prc.sql                                */
   /* Purpose      :   Set RUT (Retail Unit Transfer) cases to "Expired" if they   */
   /*                  are more than 90 days old                		              */
   /*                                                                              */
   /*                                                                              */
   /* Parameters   :                                                               */
   /* Platforms    :   Oracle 8.0.6 AND newer versions        	                    */
   /* Author	   :   Gonzalo Carena                              		           */
   /*                IT outsourcing			                               	        */
   /* Date         : December 14,2005                                              */
   /* Revisions	: Version  	Date      Who      Purpose                           */
   /*               -------  --------  -------   ------------------------------    */
   /* 		        1.0      12/14/05  GC        Initial revision                  */
   /*               1.1      25/01/06  FL        To change Unit by Units           */
   /*						                                                              */
   /********************************************************************************/

   --Get all open cases that were opened more that "X_Expire_Days" days ago.
   CURSOR c_case (p_days NUMBER)
   IS
   SELECT c.*
   FROM table_case C, table_condition CO
   WHERE C.CASE_STATE2CONDITION = CO.OBJID
     AND CO.TITLE LIKE 'Open%'
     AND c.s_title = 'RETAIL UNIT TRANSFER'
     AND c.x_case_type = 'Units'
     and creation_time between (SYSDATE - 150) and (SYSDATE - p_days);

   r_case c_case%ROWTYPE;

   l_days number := NULL;
   l_return VARCHAR2(10);
   l_return_msg VARCHAR2(200);

BEGIN

   begin
      select x_expire_days
      into l_days
      from table_x_webcsr_log_param
      where rownum = 1;

      if l_days is null then
         l_days := 90;
      end if;

   exception
      when others then
         l_days := 90;
   end;

   FOR r_case IN c_case(l_days)
   LOOP

       Igate.sp_close_case(r_case.id_number,   -- p_case_id
                           'SA',               -- p_user_login_name
                           'RUT_expiration',   -- p_source
                           'Expired',          -- p_resolution_code
                           l_return,           -- p_status
                           l_return_msg);      -- p_msg

       commit;

       DBMS_OUTPUT.put_line('Case ID ' || r_case.id_number
                         || ': Set to "Expired" date ' || SYSDATE);


   END LOOP;
END SP_expire_open_cases_prc;
/