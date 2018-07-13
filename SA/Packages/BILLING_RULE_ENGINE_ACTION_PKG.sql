CREATE OR REPLACE PACKAGE sa."BILLING_RULE_ENGINE_ACTION_PKG"
IS
   PROCEDURE block_funds_action (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   block_funds_action													 	 	 */
/*                                                                                          	 */
/* Purpose      :   Blocking funds action        												 */
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
      p_esn        IN       x_metrics_block_status.x_esn%TYPE,
      p_reason     IN       x_metrics_block_status.x_reason%TYPE,
      p_rule_cat   IN       x_metrics_block_status.x_rule_category%TYPE,
      op_result    OUT      NUMBER,
      op_msg       OUT      VARCHAR2
   );

   PROCEDURE de_act_esn_rule_action (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   de_act_esn_rule_action													 	 */
/*                                                                                          	 */
/* Purpose      :   Deactivate ESN action														 */
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
      p_esn            IN       x_program_deact_pend.x_esn%TYPE,
      p_enroll_objid   IN       x_program_deact_pend.deact_pend2prog_enroll%TYPE,
      --     p_penality_amt   IN       number,
      p_reason         IN       x_program_deact_pend.x_deact_reason%TYPE,
      p_rule_cat       IN       x_program_deact_pend.x_rule_cat%TYPE,
      op_result        OUT      NUMBER,
      op_msg           OUT      VARCHAR2
   );

   PROCEDURE retry_redebit_rule_action (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   retry_redebit_rule_action												 	 */
/*                                                                                          	 */
/* Purpose      :   Retry re-debit action														 */
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
      p_purch_objid    IN       x_program_purch_hdr.objid%TYPE,
      p_redebit_days   IN       NUMBER,
      p_reason         IN       x_metrics_redebits.x_reason%TYPE,
      p_rule_cat       IN       x_metrics_redebits.x_rule_category%TYPE,
      op_result        OUT      NUMBER,
      op_msg           OUT      VARCHAR2
   );

   PROCEDURE de_enroll_rule_action (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   de_enroll_rule_action													 	 */
/*                                                                                          	 */
/* Purpose      :   De-enroll action															 */
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
      p_esn                 IN       x_program_enrolled.x_esn%TYPE,
      p_enrolled_objid      IN       x_program_enrolled.objid%TYPE,
      p_cool_period         IN       NUMBER,
      p_penalty_part_num    IN       table_part_num.objid%TYPE,
      p_create_tran_objid   IN       x_rule_create_trans.objid%TYPE,
      p_reason              IN       x_program_penalty_pend.x_penalty_reason%TYPE,
      p_rule_cat            IN       x_program_trans.x_action_text%TYPE,
      op_result             OUT      NUMBER,
      op_msg                OUT      VARCHAR2
   );

   PROCEDURE reject_enroll_rule_action (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   reject_enroll_rule_action												 	 */
/*                                                                                          	 */
/* Purpose      :   Reject enrollment action													 */
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
      p_esn              IN       x_metrics_reject_enroll.x_esn%TYPE,
      p_program_objid    IN       x_program_parameters.objid%TYPE,
      p_web_user_objid   IN       x_metrics_reject_enroll.reject_enrol2web_user%TYPE,
      p_reject_reason    IN       x_metrics_reject_enroll.x_reject_reason%TYPE,
      p_rule_cat         IN       x_metrics_reject_enroll.x_rule_cat%TYPE,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

   PROCEDURE set_cooling_period_rule_action (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   set_cooling_period_rule_action											 	 */
/*                                                                                          	 */
/* Purpose      :   Set cooling period action													 */
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
      p_enrolled_objid   IN       x_program_enrolled.objid%TYPE,
      p_cool_period      IN       NUMBER,
      p_reason           IN       x_program_penalty_pend.x_penalty_reason%TYPE,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

   PROCEDURE set_grace_period_rule_action (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   set_grace_period_rule_action											 	 */
/*                                                                                          	 */
/* Purpose      :   Set grace period action														 */
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
      p_esn                   IN       x_program_enrolled.x_esn%TYPE,
      p_pgmenrolled2program   IN       x_program_enrolled.objid%TYPE,
      p_grace_period          IN       NUMBER,
      op_result               OUT      NUMBER,
      op_msg                  OUT      VARCHAR2
   );

   PROCEDURE set_penalty_rule_action (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   set_penalty_rule_action													 	 */
/*                                                                                          	 */
/* Purpose      :   Set penalty action																				 */
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
      p_esn                 IN       x_program_enrolled.x_esn%TYPE,
      p_create_tran_objid   IN       x_rule_create_trans.objid%TYPE,
      p_prog_enroll_objid   IN       x_program_enrolled.objid%TYPE,
      p_reason              IN       x_program_penalty_pend.x_penalty_reason%TYPE,
      p_penalty_part_num    IN       table_part_num.objid%TYPE,
      op_result             OUT      NUMBER,
      op_msg                OUT      VARCHAR2
   );

   PROCEDURE suspend_esn_rule_action (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   suspend_esn_rule_action													 	 */
/*                                                                                          	 */
/* Purpose      :   Suspend ESN action															 */
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
      p_esn                 IN       x_program_enrolled.x_esn%TYPE,
      p_enrolled_objid      IN       x_program_enrolled.objid%TYPE,
      p_grace_period        IN       NUMBER,
      p_cooling_period      IN       NUMBER,
      p_penalty_part_num    IN       table_part_num.objid%TYPE,
      p_create_tran_objid   IN       x_rule_create_trans.objid%TYPE,
      p_reason              IN       x_program_penalty_pend.x_penalty_reason%TYPE,
      op_result             OUT      NUMBER,
      op_msg                OUT      VARCHAR2
   );

   PROCEDURE update_metrics_rules_engine (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   update_metrics_rules_engine												 	 */
/*                                                                                          	 */
/* Purpose      :   Update metrics																			 */
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
      p_rule_trans_objid   IN       x_rule_create_trans.objid%TYPE,
      p_metrics_count      OUT      NUMBER,
      op_result            OUT      NUMBER,
      op_msg               OUT      VARCHAR2
   );

   PROCEDURE prevent_cc_rule_action (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   prevent_cc_rule_action													 	 */
/*                                                                                          	 */
/* Purpose      :   Prevent credit card action													 */
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
      p_credit_objid   IN       table_x_credit_card.objid%TYPE,
      p_reason         IN       x_metrics_cc_block.x_reason%TYPE,
      p_rule_cat       IN       x_metrics_cc_block.x_rule_category%TYPE,
      op_result        OUT      NUMBER,
      op_msg           OUT      VARCHAR2
   );

   PROCEDURE prevent_ach_rule_action (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   prevent_ach_rule_action													 	 */
/*                                                                                          	 */
/* Purpose      :   Prevent ACH action															 */
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
      p_ach_objid   IN       table_x_bank_account.objid%TYPE,
      p_reason      IN       x_metrics_ach_block.x_reason%TYPE,
      p_rule_cat    IN       x_metrics_cc_block.x_rule_category%TYPE,
      op_result     OUT      NUMBER,
      op_msg        OUT      VARCHAR2
   );

   PROCEDURE prevent_customer_rule_action (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   prevent_customer_rule_action											 	 */
/*                                                                                          	 */
/* Purpose      :   Prevent customer action														 */
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
      p_web_user_objid   IN       x_metrics_block_status.block_status2web_user%TYPE,
      p_reason           IN       x_metrics_block_status.x_reason%TYPE,
      p_rule_cat         IN       x_metrics_cc_block.x_rule_category%TYPE,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

   PROCEDURE prevent_esn_rule_action (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   prevent_esn_rule_action													 	 */
/*                                                                                          	 */
/* Purpose      :   Prevent ESN action															 */
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
      p_esn            IN       x_metrics_block_status.x_esn%TYPE,
      p_pgm_enrolled   IN       x_metrics_block_status.block_status2pgm_enroll%TYPE,
      p_reason         IN       x_metrics_block_status.x_reason%TYPE,
      p_rule_cat       IN       x_metrics_cc_block.x_rule_category%TYPE,
      op_result        OUT      NUMBER,
      op_msg           OUT      VARCHAR2
   );

   PROCEDURE set_wait_grace_period_action (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   set_wait_grace_period_action											 	 */
/*                                                                                          	 */
/* Purpose      :   Set waite period action														 */
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
      p_grace_period   IN       NUMBER,
      p_wait_days      IN       NUMBER,
	  p_cooling_period  IN       NUMBER,
      p_user            IN       VARCHAR2,
      op_result        OUT      NUMBER,
      op_msg           OUT      VARCHAR2
   );

   PROCEDURE set_cooling_others (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   set_cooling_others													 	 	 */
/*                                                                                          	 */
/* Purpose      :   Set cooling others action													 */
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
      p_web_user_objid   IN       x_program_enrolled.pgm_enroll2web_user%TYPE,
      p_tran_objid       IN       x_rule_action_params.rule_param2rule_trans%TYPE,
      p_reason           IN       VARCHAR2 DEFAULT 'DEENROLLED',
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

   PROCEDURE suspend_action_others (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   suspend_action_others													 	 */
/*                                                                                          	 */
/* Purpose      :   Suspend others action														 */
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
      p_web_user_objid   IN       x_program_enrolled.pgm_enroll2web_user%TYPE,
      p_esn              IN       x_program_enrolled.x_esn%TYPE,
      p_tran_objid       IN       x_rule_action_params.rule_param2rule_trans%TYPE,
      p_reason           IN       x_program_penalty_pend.x_penalty_reason%TYPE,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

   FUNCTION billing_get_penalty_amt (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_penalty_amt													 	 */
/*                                                                                          	 */
/* Purpose      :   Get penalty amount															 */
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
      p_penalty_part_num   IN   table_part_num.objid%TYPE
   )
      RETURN NUMBER;

   PROCEDURE deactivate_esn (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   deactivate_esn      													 	 */
/*                                                                                          	 */
/* Purpose      :   Deactivates an ESN															 */
/*                                                                                          	 */
/*                                                                                          	 */
/* Platforms    :   Oracle 9i                                                    				 */
/*                                                                                          	 */
/* Author       :   RSI                                                            	  			 */
/*                                                                                          	 */
/* Date         :   08-15-2006																	 */
/* REVISIONS:                                                         							 */
/* VERSION  DATE        WHO          PURPOSE                                  					 */
/* -------  ---------- 	-----  		 --------------------------------------------   			 */
/*  1.0                       		 Initial  Revision                               			 */
/*                                                                                          	 */
/*                                                                                          	 */
/*************************************************************************************************/

      p_esn              IN       x_program_enrolled.x_esn%TYPE,
      p_reason           IN       VARCHAR2,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

END billing_rule_engine_action_pkg;
/