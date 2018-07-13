CREATE OR REPLACE PACKAGE BODY sa."BILLING_GLOBAL_INSERT_PKG"
IS
   FUNCTION billing_insert_prog_trans (
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
           VALUES (p_trans_objid, p_enrollment_status, p_enroll_status_reason, p_float_given, p_cooling_given, p_grace_period_given, p_trans_date, p_action_text, p_action_type, p_reason, p_sourcesystem, p_esn, p_exp_date, p_cooling_exp_date, p_update_status, p_update_user, p_pgm_tran2pgm_entrolled, p_pgm_trans2web_user, p_pgm_trans2site_part);

      RETURN 0;
      COMMIT;
   EXCEPTION
      WHEN
       OTHERS
      THEN
        dbms_output.put_line(SQLERRM);
         RETURN 1;
   END billing_insert_prog_trans;

   FUNCTION rule_cond_trans_version (
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
      RETURN NUMBER
   IS
   BEGIN
      INSERT INTO x_rule_cond_trans_version(
   	  		 OBJID, X_RULE_COND_1, X_RULE_EVAL_1,
   			 X_RULE_PARAM_1, X_RULE_COND_2, X_RULE_EVAL_2,
   			 X_RULE_PARAM_2, X_RULE_COND_QUERY, X_RULE_VERSION,
   			 X_UPDATE_STAMP, X_UPDATE_STATUS, X_UPDATE_USER,
   			 COND_TRANS2CREATE_TRANS, VERSION2COND_TRANS, X_RULE_COND_DESC)
           	 VALUES (objid1, rule_cond_1, rule_eval_1, rule_param_1, rule_cond_2, rule_eval_2, rule_param_2, rule_cond_query, rule_version1, update_stamp, update_status, update_user, cond_trans2create_trans, version2cond_trans, rule_cond_desc);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 1;
   END rule_cond_trans_version;

   FUNCTION insert_rule_create_trans (
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
      RETURN NUMBER
   IS
   BEGIN
      INSERT INTO x_rule_create_trans_version (
   	  		 OBJID, X_RULE_SET_NAME, X_RULE_SET_DESC,
   			 X_RULE_ACT_PARAM, X_RULE_PRIORITY, X_RULE_VERSION,
   			 X_UPDATE_STAMP, X_UPDATE_STATUS, X_UPDATE_USER,
   			 SET_TRANS2RULE_CAT_MAS, SET_TRANS2RULE_ACT_MAS, SET_TRANS2RULE_ATM_MAS,
   			 SET_TRANS2RULE_MSG_MAS, VERSION2CREATE_TRANS, X_RULE_NOTIFY_PARAM,X_CREATE_DATE)
           VALUES (objid1, rule_set_name, rule_set_desc, rule_act_param, rule_priority, rule_version1, update_stamp, update_status, update_user, set_trans2rule_cat_mas, set_trans2rule_act_mas1, set_trans2rule_atm_mas1, set_trans2rule_msg_mas1, version2create_trans1, x_rule_notify_param, x_create_date);

      RETURN 0;
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 1;
   END insert_rule_create_trans;

   FUNCTION insert_action_params (
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
      RETURN NUMBER
   IS
   BEGIN
      INSERT INTO x_rule_action_params_version (
   	  		 OBJID, X_PENALTY, X_COOLING_PERIOD,
   			 X_GRACE_PERIOD, X_RULE_VERSION, X_UPDATE_STAMP,
   			 X_UPDATE_STATUS, X_UPDATE_USER, RULE_PARAM2PROG_PARAM,
   			 RULE_PARAM2RULE_TRANS, VERSION2ACTION_PARAMS)
           VALUES (objid1, penalty, cooling_period, grace_period, rule_version1, update_stamp, update_status, update_user, rule_param2prog_param1, rule_param2rule_trans1, version2action_params1);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (   SQLCODE
                               || SQLERRM);
         RETURN 1;
   END insert_action_params;

   PROCEDURE billing_get_log_info (
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
   )
   IS
      l_details               VARCHAR2 (4000);

      CURSOR condition_details_c (c_rule_trans NUMBER)
      IS
         SELECT x_rule_cond_desc
           FROM x_rule_cond_trans
          WHERE cond_trans2create_trans = c_rule_trans;

      condition_details_rec   condition_details_c%ROWTYPE;
   BEGIN
      -- Processing for rules.
      IF (p_requestor = 'RULES')
      THEN
         -- Get the first name, last name and ESN Nick name for the inputs.
         SELECT a.first_name, a.last_name, billing_getnickname (p_esn)
           INTO op_first_name, op_last_name, op_esn_nick_name
           FROM table_contact a
          WHERE objid = (SELECT web_user2contact
                           FROM table_web_user
                          WHERE objid = p_web_objid);

         IF (p_param_objid IS NULL or p_param_objid = 0)
         THEN
            SELECT b.x_program_name
              INTO op_program_name
              FROM x_program_enrolled a, x_program_parameters b
             WHERE a.pgm_enroll2pgm_parameter = b.objid
               AND a.objid = p_enroll_objid;
         ELSE
            SELECT x_program_name
              INTO op_program_name
              FROM x_program_parameters
             WHERE objid = p_param_objid;
         END IF;

         OPEN condition_details_c (p_additional_param);

         LOOP
            FETCH condition_details_c INTO condition_details_rec;
            EXIT WHEN condition_details_c%NOTFOUND;

            IF (   l_details = ''
                OR l_details IS NULL
               )
            THEN
               l_details := condition_details_rec.x_rule_cond_desc;
            ELSE
               l_details :=    l_details
                            || ' AND '
                            || condition_details_rec.x_rule_cond_desc;
            END IF;
         END LOOP;

         CLOSE condition_details_c;
         /*
		 IF (l_details IS NOT NULL)
		 THEN
         op_details :=
                  'Condition matched is '
               || l_details
               || ' and Action Taken is ';
		 ELSE
		 op_details :=
                  'Action Taken is ';
		 END IF;
         */
		 op_details := 'Action Taken is ';

         IF (p_additional_param IS NOT NULL and p_additional_param != 0)
         THEN
            BEGIN
               SELECT x_rule_act_name
                 INTO l_details
                 FROM x_rule_action_master
                WHERE objid = (SELECT set_trans2rule_act_mas
                                 FROM x_rule_create_trans
                                WHERE objid = p_additional_param);
               op_details :=    op_details
                             || l_details;
            END;
		 ELSE
		 	 op_details :='';
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END billing_get_log_info;

   FUNCTION insert_rule_version (
      p_objid                 x_rule_version.objid%TYPE,
      p_rule_version_number   x_rule_version.x_rule_version_number%TYPE,
      p_rule_version_action   x_rule_version.x_rule_version_action%TYPE,
      p_update_user           x_rule_version.RULE_VER2TABLE_USER%TYPE,
      p_update_stamp          x_rule_version.x_update_stamp%TYPE
   )
      RETURN NUMBER
   IS
   BEGIN
      INSERT INTO x_rule_version (
   	  		 OBJID, X_RULE_VERSION_NUMBER, X_RULE_VERSION_ACTION,
   			 RULE_VER2TABLE_USER, X_UPDATE_STAMP)
           VALUES (p_objid, p_rule_version_number, p_rule_version_action, p_update_user, p_update_stamp);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line (   SQLCODE
                               || SQLERRM);
         RETURN 1;
   END insert_rule_version;
END billing_global_insert_pkg;
/