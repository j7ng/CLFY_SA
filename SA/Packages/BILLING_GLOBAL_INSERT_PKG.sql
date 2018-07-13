CREATE OR REPLACE PACKAGE sa."BILLING_GLOBAL_INSERT_PKG"
IS
   FUNCTION insert_action_params (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_GLOBAL_INSERT_PKG.insert_action_params                       	 	 */
/*                                                                                          	 */
/* Purpose      :   Inserting records in Action Params table									 */
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
      objid1                   x_rule_action_params_version.objid%TYPE,
      penalty                  x_rule_action_params_version.x_penalty%TYPE,
      cooling_period           x_rule_action_params_version.x_cooling_period%TYPE,
      grace_period             x_rule_action_params_version.x_grace_period%TYPE,
      rule_version1            x_rule_action_params_version.x_rule_version%TYPE,
      update_stamp             x_rule_action_params_version.x_update_stamp%TYPE,
      update_status            x_rule_action_params_version.x_update_status%TYPE,
      update_user              x_rule_action_params_version.x_update_user%TYPE,
      rule_param2prog_param1   x_rule_action_params_version.rule_param2prog_param%TYPE,
      rule_param2rule_trans1   x_rule_action_params_version.rule_param2rule_trans%TYPE,
      version2action_params1   x_rule_action_params_version.version2action_params%TYPE
   )
      RETURN NUMBER;

   FUNCTION insert_rule_create_trans (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_GLOBAL_INSERT_PKG.insert_rule_create_trans                     	 	 */
/*                                                                                          	 */
/* Purpose      :   Inserting records in rule create trans										 */
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
      objid1                    x_rule_create_trans_version.objid%TYPE,
      rule_set_name             x_rule_create_trans_version.x_rule_set_name%TYPE,
      rule_set_desc             x_rule_create_trans_version.x_rule_set_desc%TYPE,
      rule_act_param            x_rule_create_trans_version.x_rule_act_param%TYPE,
      rule_priority             x_rule_create_trans_version.x_rule_priority%TYPE,
      rule_version1             x_rule_create_trans_version.x_rule_version%TYPE,
      update_stamp              x_rule_create_trans_version.x_update_stamp%TYPE,
      update_status             x_rule_create_trans_version.x_update_status%TYPE,
      update_user               x_rule_create_trans_version.x_update_user%TYPE,
      set_trans2rule_cat_mas    x_rule_create_trans_version.set_trans2rule_cat_mas%TYPE,
      set_trans2rule_act_mas1   x_rule_create_trans_version.set_trans2rule_act_mas%TYPE,
      set_trans2rule_atm_mas1   x_rule_create_trans_version.set_trans2rule_atm_mas%TYPE,
      set_trans2rule_msg_mas1   x_rule_create_trans_version.set_trans2rule_msg_mas%TYPE,
      version2create_trans1     x_rule_create_trans_version.version2create_trans%TYPE,
      x_rule_notify_param       x_rule_create_trans_version.x_rule_notify_param%TYPE,
	  x_create_date				x_rule_create_trans_version.X_CREATE_DATE%TYPE
   )
      RETURN NUMBER;

   FUNCTION rule_cond_trans_version (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_GLOBAL_INSERT_PKG.rule_cond_trans_version                      	 	 */
/*                                                                                          	 */
/* Purpose      :   Inserting records in condition trans										 */
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
      objid1                    x_rule_cond_trans_version.objid%TYPE,
      rule_cond_1               x_rule_cond_trans_version.x_rule_cond_1%TYPE,
      rule_eval_1               x_rule_cond_trans_version.x_rule_eval_1%TYPE,
      rule_param_1              x_rule_cond_trans_version.x_rule_param_1%TYPE,
      rule_cond_2               x_rule_cond_trans_version.x_rule_cond_2%TYPE,
      rule_eval_2               x_rule_cond_trans_version.x_rule_eval_2%TYPE,
      rule_param_2              x_rule_cond_trans_version.x_rule_param_2%TYPE,
      rule_cond_query           x_rule_cond_trans_version.x_rule_cond_query%TYPE,
      rule_version1             x_rule_cond_trans_version.x_rule_version%TYPE,
      update_stamp              x_rule_cond_trans_version.x_update_stamp%TYPE,
      update_status             x_rule_cond_trans_version.x_update_status%TYPE,
      update_user               x_rule_cond_trans_version.x_update_user%TYPE,
      cond_trans2create_trans   x_rule_cond_trans_version.cond_trans2create_trans%TYPE,
      version2cond_trans        x_rule_cond_trans_version.version2cond_trans%TYPE,
	  rule_cond_desc			x_rule_cond_trans_version.x_rule_cond_desc%TYPE
   )
      RETURN NUMBER;

   FUNCTION billing_insert_prog_trans (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_GLOBAL_INSERT_PKG.billing_insert_prog_trans                    	 	 */
/*                                                                                          	 */
/* Purpose      :   Inserting records in x_program_trans																			 */
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
      RETURN NUMBER;

   PROCEDURE billing_get_log_info (


/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_GLOBAL_INSERT_PKG.billing_get_log_info                       	 	 */
/*                                                                                          	 */
/* Purpose      :   Get customer information																			 */
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
      p_requestor             IN       VARCHAR2, -- 'RULES','PAYMENTS','WEBCSR','WEB'
      p_web_objid             IN       table_web_user.objid%TYPE,
      p_enroll_objid          IN       x_program_enrolled.objid%TYPE,
      p_param_objid           IN       x_program_parameters.objid%TYPE,
      p_esn                   IN       x_program_enrolled.x_esn%TYPE,
      p_additional_param      IN       NUMBER, -- Incase of rules, this is the rule_Create_trans_objid
      op_first_name           OUT      table_contact.first_name%TYPE,
      op_last_name            OUT      table_contact.last_name%TYPE,
      op_esn_nick_name        OUT      table_x_contact_part_inst.x_esn_nick_name%TYPE,
      op_program_name         OUT      x_program_parameters.x_program_name%TYPE,
      op_details              OUT      VARCHAR2,
      op_additional_details   OUT      VARCHAR2
   );
   FUNCTION insert_rule_version (
      p_objid                 x_rule_version.objid%TYPE,
      p_rule_version_number   x_rule_version.x_rule_version_number%TYPE,
      p_rule_version_action   x_rule_version.x_rule_version_action%TYPE,
      p_update_user           x_rule_version.RULE_VER2TABLE_USER%TYPE,
      p_update_stamp          x_rule_version.x_update_stamp%TYPE
   )
      RETURN NUMBER;
END billing_global_insert_pkg;
/