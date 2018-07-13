CREATE OR REPLACE PACKAGE sa."BILLING_RULE_ENGINE_PKG"
IS
   PROCEDURE attempt_resp_code (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid         IN       NUMBER,
      p_mrchnt_rf_id       IN       VARCHAR2,
      p_esn                IN       VARCHAR2,
      p_attempt_no         IN       NUMBER,
      p_first_resp_code    IN       x_program_purch_hdr.x_ics_rcode%TYPE,
      p_second_resp_code   IN       x_program_purch_hdr.x_ics_rcode%TYPE,
      p_third_resp_code    IN       x_program_purch_hdr.x_ics_rcode%TYPE,
      p_first_resp_flag    IN       x_program_purch_hdr.x_ics_rflag%TYPE,
      p_second_resp_flag   IN       x_program_purch_hdr.x_ics_rflag%TYPE,
      p_third_resp_flag    IN       x_program_purch_hdr.x_ics_rflag%TYPE,
      o_result             OUT      NUMBER,
      o_err_num            OUT      VARCHAR2,
      o_err_msg            OUT      VARCHAR2
   );

   PROCEDURE tot_num_dec_cust (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   );

   PROCEDURE tot_num_dec_esn (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid   IN       NUMBER,
      p_esn          IN       VARCHAR2,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   );

   PROCEDURE tot_num_rev_cust (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   );

   PROCEDURE tot_num_rev_esn (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid   IN       NUMBER,
      p_esn          IN       VARCHAR2,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   );

   PROCEDURE tot_redebit_attmt_esn (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid   IN       NUMBER,
      p_esn          IN       VARCHAR2,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   );

   PROCEDURE auto_num_payment_resp_esn (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      p_mrchnt_rf_id     IN       VARCHAR2,
      p_esn              IN       VARCHAR2,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   );

   PROCEDURE auto_num_payment_resp_cust (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      p_mrchnt_rf_id     IN       VARCHAR2,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   );

   PROCEDURE auto_tot_redebit_attmt_esn (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid   IN       NUMBER,
      p_esn          IN       VARCHAR2,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   );

   PROCEDURE auto_tot_redebit_attmt_cust (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   );

   PROCEDURE auto_tot_num_rev_esn (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid   IN       NUMBER,
      p_esn          IN       VARCHAR2,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   );

   PROCEDURE auto_tot_num_rev_cust (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   );

   PROCEDURE auto_num_dec_cust (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   );

   PROCEDURE num_payment_resp_esn (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      p_esn              IN       VARCHAR2,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   );

   PROCEDURE num_payment_resp_cust (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   );

   PROCEDURE tot_amt_added_aft_enroll (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid       IN       NUMBER,
      p_esn              IN       VARCHAR2,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   );

   PROCEDURE tot_amt_added_last30day (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid       IN       NUMBER,
      p_esn              IN       VARCHAR2,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   );

   PROCEDURE tot_amt_added_session (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid   IN       NUMBER,
      p_session_id   IN       VARCHAR2,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   );

   PROCEDURE tot_redebit_attmt_cust (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   );

   PROCEDURE auto_fail_enroll_attmt_prog (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid       IN       NUMBER,
      p_prog_id          IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   );

   PROCEDURE auto_fail_enroll_attmt_day (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   );

   PROCEDURE auto_fail_enroll_attmt_cust (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   );

   PROCEDURE payment_method (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
     p_cond_objid   IN       NUMBER,
      p_pay_type     IN       VARCHAR2,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   );

   PROCEDURE name_autopay_pgm_enroll (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid   IN       NUMBER,
      p_enroll_id    IN       NUMBER,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   );

   PROCEDURE cc_blocked_ftr_enroll (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cc_objid   IN       NUMBER, --from program purchase header
      o_result     OUT      NUMBER,
      o_err_num    OUT      VARCHAR2,
      o_err_msg    OUT      VARCHAR2
   );

   PROCEDURE esn_blocked_ftr_enroll (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   esn_blocked_ftr_enroll											 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_esn   IN       NUMBER,
      o_result     OUT      NUMBER,
      o_err_num    OUT      VARCHAR2,
      o_err_msg    OUT      VARCHAR2
   );

  PROCEDURE customer_blocked_ftr_enroll (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   customer_blocked_ftr_enroll											 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      o_result     OUT      NUMBER,
      o_err_num    OUT      VARCHAR2,
      o_err_msg    OUT      VARCHAR2
   );

   PROCEDURE esn_in_cooling_prd (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_enroll_objid   IN       NUMBER, --from program purchase header
      p_esn            IN       VARCHAR2, --from program purchase header
      o_result         OUT      NUMBER,
      o_err_num        OUT      VARCHAR2,
      o_err_msg        OUT      VARCHAR2
   );

   PROCEDURE esn_prog_length (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid     IN       NUMBER,
      p_enroll_objid   IN       NUMBER, --from program purchase header
      p_esn            IN       VARCHAR2, --from program purchase header
      o_result         OUT      NUMBER,
      o_err_num        OUT      VARCHAR2,
      o_err_msg        OUT      VARCHAR2
   );

   PROCEDURE cc_black_listed (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cc_objid   IN       NUMBER, --from program purchase header
      o_result     OUT      NUMBER,
      o_err_num    OUT      VARCHAR2,
      o_err_msg    OUT      VARCHAR2
   );

   PROCEDURE cc_not_blocked_ftr_enroll (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cc_objid   IN       NUMBER, --program purchase header
      o_result     OUT      NUMBER,
      o_err_num    OUT      VARCHAR2,
      o_err_msg    OUT      VARCHAR2
   );

   PROCEDURE esn_not_in_cooling_prd (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_enroll_objid   IN       NUMBER, --program purchase header
      p_esn            IN       VARCHAR2, --program purchase header
      o_result         OUT      NUMBER,
      o_err_num        OUT      VARCHAR2,
      o_err_msg        OUT      VARCHAR2
   );

   PROCEDURE cc_not_black_listed (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cc_objid   IN       NUMBER, --program purchase header
      o_result     OUT      NUMBER,
      o_err_num    OUT      VARCHAR2,
      o_err_msg    OUT      VARCHAR2
   );

   PROCEDURE pnow_payment_attempt_reversal (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_enroll_objid   IN       NUMBER,
      p_cond_objid     IN       NUMBER,
      o_result         OUT      NUMBER,
      o_err_num        OUT      VARCHAR2,
      o_err_msg        OUT      VARCHAR2
   );

   PROCEDURE auto_name_prog_trying (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_prog_objid   IN       NUMBER,
      p_cond_objid   IN       NUMBER,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   );

   PROCEDURE web_csr_is_enroll_group (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_prog_objid   IN       NUMBER,
      p_esn          IN       VARCHAR2,
      p_cond_objid   IN       NUMBER,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   );

   PROCEDURE charge_back_reason_code (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   charge_back_reason_code												 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_reason_code   IN       VARCHAR2,
      p_cond_objid    IN       NUMBER,
      o_result        OUT      NUMBER,
      o_err_num       OUT      VARCHAR2,
      o_err_msg       OUT      VARCHAR2
   );

   PROCEDURE charge_back_fund_src_type (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_source_type   IN       VARCHAR2,
      p_cond_objid    IN       NUMBER,
      o_result        OUT      NUMBER,
      o_err_num       OUT      VARCHAR2,
      o_err_msg       OUT      VARCHAR2
   );

   PROCEDURE web_csr_deactivation_reason (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_reason       IN       VARCHAR2,
      p_cond_objid   IN       NUMBER,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   );

   PROCEDURE current_autopay_status (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_enroll_objid   IN       NUMBER,
      p_cond_objid     IN       NUMBER,
      o_result         OUT      NUMBER,
      o_err_num        OUT      VARCHAR2,
      o_err_msg        OUT      VARCHAR2
   );

   PROCEDURE pnow_for_past_due (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_enroll_objid   IN       NUMBER,
      p_cond_objid     IN       NUMBER,
      o_result         OUT      NUMBER,
      o_err_num        OUT      VARCHAR2,
      o_err_msg        OUT      VARCHAR2
   );

   PROCEDURE pnow_for_ftr_cyl (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_enroll_objid   IN       NUMBER,
      p_cond_objid     IN       NUMBER,
      o_result         OUT      NUMBER,
      o_err_num        OUT      VARCHAR2,
      o_err_msg        OUT      VARCHAR2
   );

   PROCEDURE current_response_code (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
   p_cond_objid     IN       NUMBER,
   p_mrchnt_rf_id   IN       VARCHAR2,
   o_result         OUT      NUMBER,
   o_err_num        OUT      VARCHAR2,
   o_err_msg        OUT      VARCHAR2
);
PROCEDURE TOT_NUM_FAIL_RESP_IN_CYL (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   																			 */
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
      p_cond_objid     IN       NUMBER,
      p_enroll_objid   IN       NUMBER,
      o_result         OUT      NUMBER,
      o_err_num        OUT      VARCHAR2,
      o_err_msg        OUT      VARCHAR2
   );
END billing_rule_engine_pkg;
/