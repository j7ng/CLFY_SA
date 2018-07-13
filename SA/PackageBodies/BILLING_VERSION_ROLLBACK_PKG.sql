CREATE OR REPLACE PACKAGE BODY sa.billing_version_rollback_pkg
IS
   FUNCTION version_rule_cond_trans (
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
      RETURN NUMBER
   IS
   BEGIN
      INSERT INTO x_rule_cond_trans (
   	  		 OBJID, X_RULE_COND_1, X_RULE_EVAL_1,
   			 X_RULE_PARAM_1, X_RULE_COND_2, X_RULE_EVAL_2,
   			 X_RULE_PARAM_2, X_RULE_COND_QUERY, X_UPDATE_STAMP,
   			 X_UPDATE_STATUS, X_UPDATE_USER, X_RULE_COND_DESC,
   			 COND_TRANS2CREATE_TRANS)
           VALUES (objid1, rule_cond_1, rule_eval_1, rule_param_1, rule_cond_2, rule_eval_2, rule_param_2, rule_cond_query, update_stamp, update_status, update_user, rule_cond_desc, cond_trans2create_trans);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 1;
   END version_rule_cond_trans;

   FUNCTION version_rule_create_trans (
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
	  x_create_date				x_rule_create_trans.X_CREATE_DATE%TYPE
   )
      RETURN NUMBER
   IS
   BEGIN
      INSERT INTO x_rule_create_trans (
   	  		 OBJID, X_RULE_SET_NAME, X_RULE_SET_DESC,
   			 X_RULE_ACT_PARAM, X_RULE_PRIORITY, X_UPDATE_STAMP,
   			 X_UPDATE_STATUS, X_UPDATE_USER, SET_TRANS2RULE_CAT_MAS,
   			 SET_TRANS2RULE_ACT_MAS, SET_TRANS2RULE_ATM_MAS, SET_TRANS2RULE_MSG_MAS,
   			 X_RULE_NOTIFY_PARAM,X_CREATE_DATE)
           VALUES (objid1, rule_set_name, rule_set_desc, rule_act_param, rule_priority, update_stamp, update_status, update_user, set_trans2rule_cat_mas, set_trans2rule_act_mas1, set_trans2rule_atm_mas1, set_trans2rule_msg_mas1, version2create_trans1, x_create_date);

      RETURN 0;
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 1;
   END version_rule_create_trans;

   FUNCTION verion_action_params (
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
      RETURN NUMBER
   IS
   BEGIN
      INSERT INTO x_rule_action_params (
   	  		 OBJID, X_PENALTY, X_COOLING_PERIOD,
   			 X_GRACE_PERIOD, X_UPDATE_STAMP, X_UPDATE_STATUS,
   			 X_UPDATE_USER, RULE_PARAM2PROG_PARAM, RULE_PARAM2RULE_TRANS)
           VALUES (objid1, penalty, cooling_period, grace_period, update_stamp, update_status, update_user, rule_param2prog_param1, rule_param2rule_trans1);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (   SQLCODE
                               || SQLERRM);
         RETURN 1;
   END verion_action_params;
END billing_version_rollback_pkg;
/