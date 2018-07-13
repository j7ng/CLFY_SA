CREATE OR REPLACE PACKAGE sa.billing_version_rollback_pkg
IS
   FUNCTION verion_action_params (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   verion_action_params													 	 */
/*                                                                                          	 */
/* Purpose      :   Used for creation of version for action parameters							 */
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

      objid1                   x_rule_action_params.objid%TYPE,
      penalty                  x_rule_action_params.x_penalty%TYPE,
      cooling_period           x_rule_action_params.x_cooling_period%TYPE,
      grace_period             x_rule_action_params.x_grace_period%TYPE,
      update_stamp             x_rule_action_params.x_update_stamp%TYPE,
      update_status            x_rule_action_params.x_update_status%TYPE,
      update_user              x_rule_action_params.x_update_user%TYPE,
      rule_param2prog_param1   x_rule_action_params.rule_param2prog_param%TYPE,
      rule_param2rule_trans1   x_rule_action_params.rule_param2rule_trans%TYPE
   )
      RETURN NUMBER;

   FUNCTION version_rule_create_trans (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   version_rule_create_trans												 	 */
/*                                                                                          	 */
/* Purpose      :   Used for creation of version for creat trans								 */
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

      objid1                    x_rule_create_trans.objid%TYPE,
      rule_set_name             x_rule_create_trans.x_rule_set_name%TYPE,
      rule_set_desc             x_rule_create_trans.x_rule_set_desc%TYPE,
      rule_act_param            x_rule_create_trans.x_rule_act_param%TYPE,
      rule_priority             x_rule_create_trans.x_rule_priority%TYPE,
      update_stamp              x_rule_create_trans.x_update_stamp%TYPE,
      update_status             x_rule_create_trans.x_update_status%TYPE,
      update_user               x_rule_create_trans.x_update_user%TYPE,
      set_trans2rule_cat_mas    x_rule_create_trans.set_trans2rule_cat_mas%TYPE,
      set_trans2rule_act_mas1   x_rule_create_trans.set_trans2rule_act_mas%TYPE,
      set_trans2rule_atm_mas1   x_rule_create_trans.set_trans2rule_atm_mas%TYPE,
      set_trans2rule_msg_mas1   x_rule_create_trans.set_trans2rule_msg_mas%TYPE,
      version2create_trans1     x_rule_create_trans.x_rule_notify_param%TYPE,
	  x_create_date				x_rule_create_trans.x_create_date%TYPE
   )
      RETURN NUMBER;

   FUNCTION version_rule_cond_trans (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   version_rule_cond_trans														 *											 	 */
/*                                                                                          	 */
/* Purpose      :   Used for creation of version for condition trans							 */
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


      objid1                    x_rule_cond_trans.objid%TYPE,
      rule_cond_1               x_rule_cond_trans.x_rule_cond_1%TYPE,
      rule_eval_1               x_rule_cond_trans.x_rule_eval_1%TYPE,
      rule_param_1              x_rule_cond_trans.x_rule_param_1%TYPE,
      rule_cond_2               x_rule_cond_trans.x_rule_cond_2%TYPE,
      rule_eval_2               x_rule_cond_trans.x_rule_eval_2%TYPE,
      rule_param_2              x_rule_cond_trans.x_rule_param_2%TYPE,
      rule_cond_query           x_rule_cond_trans.x_rule_cond_query%TYPE,
      update_stamp              x_rule_cond_trans.x_update_stamp%TYPE,
      update_status             x_rule_cond_trans.x_update_status%TYPE,
      update_user               x_rule_cond_trans.x_update_user%TYPE,
      rule_cond_desc            x_rule_cond_trans.x_rule_cond_desc%TYPE,
      cond_trans2create_trans   x_rule_cond_trans.cond_trans2create_trans%TYPE
   )
      RETURN NUMBER;
END billing_version_rollback_pkg;
/