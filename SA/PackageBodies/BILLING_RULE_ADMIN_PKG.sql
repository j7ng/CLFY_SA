CREATE OR REPLACE PACKAGE BODY sa."BILLING_RULE_ADMIN_PKG"
IS
   PROCEDURE billing_rule_version (p_user in NUMBER, op_result OUT NUMBER, op_msg OUT VARCHAR2)
   IS
      l_objid            NUMBER;
      l_objid1           NUMBER;
      l_objid2           NUMBER;
      pass               NUMBER;
      pass1              NUMBER;
	  pass2              NUMBER;
      pass3              NUMBER;
      l_version_number   NUMBER;
      sqlcod             NUMBER;
   BEGIN
      -- Get the new version number to be assigned.
      SELECT billing_rule_version_no.NEXTVAL
        INTO l_version_number
        FROM DUAL;


      --- Get all the records from the x_rule_create_trans table
      FOR rec IN  (SELECT *
                     FROM x_rule_create_trans
                   )
      LOOP
         pass1 :=
               billing_global_insert_pkg.insert_rule_create_trans (
                  billing_seq ('X_RULE_CREATE_TRANS_VERSION'),
                  rec.x_rule_set_name,
                  rec.x_rule_set_desc,
                  rec.x_rule_act_param,
                  rec.x_rule_priority,
                  l_version_number,
                  rec.x_update_stamp,
                  rec.x_update_status,
                  rec.x_update_user,
                  rec.set_trans2rule_cat_mas,
                  rec.set_trans2rule_act_mas,
                  rec.set_trans2rule_atm_mas,
                  rec.set_trans2rule_msg_mas,
                  rec.objid,
                  rec.x_rule_notify_param,
				  rec.x_create_date
               );
       END LOOP;

       FOR idx2 IN  (SELECT *
                         FROM x_rule_action_params
                        --WHERE rule_param2rule_trans = rec.objid
                     )
         LOOP
            pass3 :=
                  billing_global_insert_pkg.insert_action_params (
                     billing_seq ('X_RULE_ACTION_PARAMS_VERSION'),
                     idx2.x_penalty,
                     idx2.x_cooling_period,
                     idx2.x_grace_period,
                     l_version_number,
                     idx2.x_update_stamp,
                     idx2.x_update_status,
                     idx2.x_update_user,
                     idx2.rule_param2prog_param,
                     idx2.RULE_PARAM2RULE_TRANS,
                     idx2.objid
                  );
         END LOOP;

         FOR idx IN  (SELECT *
                        FROM x_rule_cond_trans
                       --WHERE cond_trans2create_trans = rec.objid
                     )
         LOOP
            pass :=
                  billing_global_insert_pkg.rule_cond_trans_version (
                     billing_seq ('X_RULE_COND_TRANS_VERSION'),
                     idx.x_rule_cond_1,
                     idx.x_rule_eval_1,
                     idx.x_rule_param_1,
                     idx.x_rule_cond_2,
                     idx.x_rule_eval_2,
                     idx.x_rule_param_2,
                     idx.x_rule_cond_query,
                     l_version_number,
                     idx.x_update_stamp,
                     idx.x_update_status,
                     idx.x_update_user,
                     idx.cond_trans2create_trans,
                     idx.objid,
					 idx.x_rule_cond_desc
                  );
         END LOOP;

  	  	 pass2:=
		      billing_global_insert_pkg.INSERT_RULE_VERSION (
			      billing_seq ('X_RULE_VERSION'),
				  l_version_number,
				  'CREATE_VERSION',
				  p_user,
				  SYSDATE);
		COMMIT;

   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -900;
         op_msg :=    SQLCODE
                   || SUBSTR (SQLERRM, 1, 100);
         sqlcod := SQLCODE;

         IF (sqlcod = -1400)
         THEN
            op_result := -1400;
            op_msg := 'Entered is NULL';
         END IF;
   END billing_rule_version;

   PROCEDURE billing_version_rollback (
      p_version_no   IN       NUMBER,
	  p_user         in       NUMBER,
      op_result      OUT      NUMBER,
      op_msg         OUT      VARCHAR2
   )
   IS
   	  l_objid   NUMBER;
      l_objid1  NUMBER;
      l_objid2  NUMBER;
      pass1    NUMBER;
      pass2    NUMBER;
      pass3    NUMBER;
	  pass4    NUMBER;
      sqlcod   NUMBER;
   BEGIN
          -- EXECUTE IMMEDIATE 'delete  from X_RULE_CREATE_TRANS';
		 delete  from X_RULE_CREATE_TRANS ;
       --   EXECUTE IMMEDIATE 'delete  from X_RULE_COND_TRANS';
		 delete  from X_RULE_COND_TRANS;
       --  EXECUTE IMMEDIATE 'delete  from X_RULE_ACTION_PARAMS';
		 delete  from X_RULE_ACTION_PARAMS;

      FOR idx1 IN  (SELECT *
                      FROM x_rule_create_trans_version
                     WHERE x_rule_version = p_version_no)
      LOOP
	     --l_objid1 := billing_seq ('X_RULE_CREATE_TRANS');
         pass1 :=
               billing_version_rollback_pkg.version_rule_create_trans (
                  idx1.VERSION2CREATE_TRANS,--idx1.objid,
                  idx1.x_rule_set_name,
                  idx1.x_rule_set_desc,
                  idx1.x_rule_act_param,
                  idx1.x_rule_priority,
                  idx1.x_update_stamp,
                  idx1.x_update_status,
                  idx1.x_update_user,
                  idx1.set_trans2rule_cat_mas,
                  idx1.set_trans2rule_act_mas,
                  idx1.set_trans2rule_atm_mas,
                  idx1.set_trans2rule_msg_mas,
                  idx1.x_rule_notify_param,
				  idx1.x_create_date
               );
        END LOOP;

		FOR idx2 IN  (SELECT *
                     FROM x_rule_cond_trans_version
                     WHERE x_rule_version = p_version_no)

        LOOP
         		   pass2 :=
               			 billing_version_rollback_pkg.version_rule_cond_trans (
                  		 --l_objid2,--idx2.objid,
                         idx2.VERSION2COND_TRANS,
                  		 idx2.x_rule_cond_1,
                  		 idx2.x_rule_eval_1,
                  		 idx2.x_rule_param_1,
                  		 idx2.x_rule_cond_2,
                  		 idx2.x_rule_eval_2,
                  		 idx2.x_rule_param_2,
                  		 idx2.x_rule_cond_query,
                  		 idx2.x_update_stamp,
                  		 idx2.x_update_status,
                  		 idx2.x_update_user,
				  		 idx2.x_rule_cond_desc,
                  		 --l_objid1--
                         idx2.cond_trans2create_trans
                        --idx2.version2cond_trans -- OLD
               	  );
	   END LOOP;

       FOR idx3 IN  (SELECT *
                      FROM x_rule_action_params_version
                      WHERE x_rule_version = p_version_no)
	   LOOP
	     			--l_objid := billing_seq ('X_RULE_ACTION_PARAMS');
   			pass3 :=
               		billing_version_rollback_pkg.verion_action_params (
                    idx3.VERSION2ACTION_PARAMS,
                  	idx3.x_penalty,
                  	idx3.x_cooling_period,
                  	idx3.x_grace_period,
                  	idx3.x_update_stamp,
                  	idx3.x_update_status,
                  	idx3.x_update_user,
                  	idx3.rule_param2prog_param,
                    idx3.rule_param2rule_trans
               		);
       END LOOP;


-- 	  	 pass4:=
-- 		      billing_global_insert_pkg.INSERT_RULE_VERSION (
-- 			      billing_seq ('X_RULE_VERSION'),
-- 				  p_version_no,
-- 				  'ROLLBACK_VERSION',
-- 				  p_user,
-- 				  SYSDATE);
	 COMMIT;

   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg :=    SQLCODE
                   || SUBSTR (SQLERRM, 1, 100);
         sqlcod := SQLCODE;

         IF (sqlcod = -1400)
         THEN
            op_result := -1400;
            op_msg := 'Entered is NULL';
         END IF;
   END billing_version_rollback;

   PROCEDURE billing_rule_clean (op_result OUT NUMBER, op_msg OUT VARCHAR2)
   IS
   BEGIN
      EXECUTE IMMEDIATE 'delete  from X_RULE_CREATE_TRANS';
      EXECUTE IMMEDIATE 'delete  from X_RULE_COND_TRANS';
      EXECUTE IMMEDIATE 'delete  from X_RULE_ACTION_PARAMS';
   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg :=    SQLCODE
                   || SUBSTR (SQLERRM, 1, 100);
   END billing_rule_clean;
END billing_rule_admin_pkg;
/