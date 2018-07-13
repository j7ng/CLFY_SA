CREATE OR REPLACE PROCEDURE sa."BILLING_DE_REGISTER" (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_de_register                     									 */
/*                                                                                          	 */
/* Purpose      :   Deregister a web user														 */
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

   p_web_user_objid   IN       NUMBER,
   o_err_num          OUT      NUMBER,
   o_err_msg          OUT      VARCHAR2
)
IS
   l_objid                table_web_user.objid%TYPE;
   l_login_name           table_web_user.login_name%TYPE;
   l_s_login_name         table_web_user.s_login_name%TYPE;
   l_password             table_web_user.password%TYPE;
   l_user_key             table_web_user.user_key%TYPE;
   l_status               table_web_user.status%TYPE;
   l_passwd_chg           table_web_user.passwd_chg%TYPE;
   l_dev                  table_web_user.dev%TYPE;
   l_ship_via             table_web_user.ship_via%TYPE;
   l_x_secret_questn      table_web_user.x_secret_questn%TYPE;
   l_s_x_secret_questn    table_web_user.s_x_secret_questn%TYPE;
   l_x_secret_ans         table_web_user.x_secret_ans%TYPE;
   l_s_x_secret_ans       table_web_user.s_x_secret_ans%TYPE;
   l_web_user2user        table_web_user.web_user2user%TYPE;
   l_web_user2contact     table_web_user.web_user2contact%TYPE;
   l_web_user2lead        table_web_user.web_user2lead%TYPE;
   l_web_user2bus_org     table_web_user.web_user2bus_org%TYPE;
   l_count                NUMBER;
BEGIN
   SELECT COUNT (ROWID)
     INTO l_count
     FROM table_web_user
    WHERE objid = p_web_user_objid;

   IF l_count > 0
   THEN
      DELETE FROM table_web_user
            WHERE objid = p_web_user_objid
        RETURNING objid, login_name, s_login_name, password,
                  user_key, status, passwd_chg, dev, ship_via,
                  x_secret_questn, s_x_secret_questn, x_secret_ans,
                  s_x_secret_ans, web_user2user, web_user2contact,
                  web_user2lead, web_user2bus_org
             INTO l_objid, l_login_name, l_s_login_name, l_password,
                  l_user_key, l_status, l_passwd_chg, l_dev, l_ship_via,
                  l_x_secret_questn, l_s_x_secret_questn, l_x_secret_ans,
                  l_s_x_secret_ans, l_web_user2user, l_web_user2contact,
                  l_web_user2lead, l_web_user2bus_org;

      INSERT INTO x_program_web_user_his
                  (objid, login_name, s_login_name, password,
                   user_key, status, passwd_chg, dev, ship_via,
                   x_secret_questn, s_x_secret_questn, x_secret_ans,
                   s_x_secret_ans, web_user2user, web_user2contact,
                   web_user2lead, web_user2bus_org)
           VALUES (l_objid, l_login_name, l_s_login_name, l_password,
                   l_user_key, l_status, l_passwd_chg, l_dev, l_ship_via,
                   l_x_secret_questn, l_s_x_secret_questn, l_x_secret_ans,
                   l_s_x_secret_ans, l_web_user2user, l_web_user2contact,
                   l_web_user2lead, l_web_user2bus_org);
   ELSIF l_count = 0
   THEN
      o_err_num := -1;
      o_err_msg := ' No Record Found';
   END IF;

   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      o_err_num := -100;
      o_err_msg :=    SQLCODE
                   || SUBSTR (SQLERRM, 1, 100);
END billing_de_register;
/