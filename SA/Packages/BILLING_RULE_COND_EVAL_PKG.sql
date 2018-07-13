CREATE OR REPLACE PACKAGE sa.billing_rule_cond_eval_pkg
IS
   PROCEDURE billing_rule_cond_eval (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_rule_cond_eval													 	 */
/*                                                                                          	 */
/* Purpose      :   Evaluate condition															 */
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
      p_enroll_objid           IN       NUMBER,
      p_create_objid           IN       NUMBER,
      p_mrchnt_rf_id           IN       VARCHAR2,
      p_cc_objid               IN       NUMBER,
      p_prog_id                IN       NUMBER,
      p_session_id             IN       VARCHAR2,
      p_esn                    IN       VARCHAR2,
      p_pay_type               IN       VARCHAR2,
      p_web_user_objid         IN       NUMBER,
      p_charge_reason_code     IN       VARCHAR2,
      p_charge_source_type     IN       VARCHAR2,
      p_web_csr_deact_reason   IN       VARCHAR2,
      p_attempt_no             IN       NUMBER,
      p_first_resp_code        IN       x_program_purch_hdr.x_ics_rcode%TYPE,
      p_second_resp_code       IN       x_program_purch_hdr.x_ics_rcode%TYPE,
      p_third_resp_code        IN       x_program_purch_hdr.x_ics_rcode%TYPE,
      p_first_resp_flag        IN       x_program_purch_hdr.x_ics_rflag%TYPE,
      p_second_resp_flag       IN       x_program_purch_hdr.x_ics_rflag%TYPE,
      p_third_resp_flag        IN       x_program_purch_hdr.x_ics_rflag%TYPE,
      o_result                 OUT      NUMBER,
      o_err_num                OUT      VARCHAR2,
      o_err_msg                OUT      VARCHAR2
   );
END billing_rule_cond_eval_pkg;
/