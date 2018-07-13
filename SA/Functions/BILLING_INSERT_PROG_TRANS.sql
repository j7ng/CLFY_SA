CREATE OR REPLACE FUNCTION sa.billing_insert_prog_trans (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_insert_prog_trans									 	 	 	 	 */
/*                                                                                          	 */
/* Purpose      :   Utility procedure for inserting records into x_program_trans				 */
/*                                                                                          	 */
/*                                                                                          	 */
/* Platforms    :   Oracle 9i                                                    				 */
/*                                                                                          	 */
/* Author       :   RSI                                                            	    	 */
/*                                                                                          	 */
/* Date         :   01-19-2006																	 */
/* REVISIONS:                                                         							 */
/* VERSION  DATE        WHO          PURPOSE                                  					 */
/* -------  ---------- 	-----  		 --------------------------------------------   			 */
/*  1.0                       		 Initial  Revision                               			 */
/*                                                                                          	 */
/*                                                                                          	 */
/*************************************************************************************************/
   p_trans_objid              IN   x_program_trans.objid%TYPE,
   p_enrollment_status        IN   x_program_trans.x_enrollment_status%TYPE,
   p_enroll_status_reason     IN   x_program_trans.x_enroll_status_reason%TYPE,
   p_float_given              IN   x_program_trans.x_float_given%TYPE,
   p_cooling_given            IN   x_program_trans.x_cooling_given%TYPE,
   p_grace_period_given       IN   x_program_trans.x_grace_period_given%TYPE,
   p_trans_date               IN   x_program_trans.x_trans_date%TYPE,
   p_action_text              IN   x_program_trans.x_action_text%TYPE,
   p_action_type              IN   x_program_trans.x_action_type%TYPE,
   p_reason                   IN   x_program_trans.x_reason%TYPE,
   p_sourcesystem             IN   x_program_trans.x_sourcesystem%TYPE,
   p_esn                      IN   x_program_trans.x_esn%TYPE,
   p_exp_date                 IN   x_program_trans.x_exp_date%TYPE,
   p_cooling_exp_date         IN   x_program_trans.x_cooling_exp_date%TYPE,
   p_update_status            IN   x_program_trans.x_update_status%TYPE,
   p_update_user              IN   x_program_trans.x_update_user%TYPE,
   p_pgm_tran2pgm_entrolled   IN   x_program_trans.pgm_tran2pgm_entrolled%TYPE,
   p_pgm_trans2web_user       IN   x_program_trans.pgm_trans2web_user%TYPE,
   p_pgm_trans2site_part      IN   x_program_trans.pgm_trans2site_part%TYPE
)
   RETURN NUMBER
IS
BEGIN
   INSERT INTO x_program_trans
               (objid, x_enrollment_status, x_enroll_status_reason,
                x_float_given, x_cooling_given, x_grace_period_given,
                x_trans_date, x_action_text, x_action_type, x_reason,
                x_sourcesystem, x_esn, x_exp_date, x_cooling_exp_date,
                x_update_status, x_update_user, pgm_tran2pgm_entrolled,
                pgm_trans2web_user, pgm_trans2site_part)
        VALUES (p_trans_objid, p_enrollment_status, p_enroll_status_reason,
                p_float_given, p_cooling_given, p_grace_period_given,
                p_trans_date, p_action_text, p_action_type, p_reason,
                p_sourcesystem, p_esn, p_exp_date, p_cooling_exp_date,
                p_update_status, p_update_user, p_pgm_tran2pgm_entrolled,
                p_pgm_trans2web_user, p_pgm_trans2site_part);

   RETURN 0;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN 1;
END billing_insert_prog_trans;
/