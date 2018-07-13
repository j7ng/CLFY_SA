CREATE OR REPLACE PROCEDURE sa."BILLING_GET_CP_RULE_ENGINE" (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_cp_denroll_rule_engine                     								 */
/*                                                                                          	 */
/* Purpose      :   Returns cooling period to be set for de-enrollment							 */
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
/*                                                                                    	 */
/*                                                                                          	 */
/*************************************************************************************************/
   p_esn                 IN       x_program_enrolled.x_esn%TYPE,
   p_source_system		 IN		  VARCHAR2,
   p_language			 IN		  VARCHAR2,
   p_webuser_objid		 IN		  x_program_enrolled.PGM_ENROLL2WEB_USER%TYPE,
   p_prog_enrolled_objid IN		  x_program_enrolled.OBJID%TYPE,
   op_cooling_period	 OUT	  NUMBER,
   op_result             OUT      NUMBER,
   op_msg                OUT      VARCHAR2
)
IS
--   l_coolingperiod          NUMBER;
   l_max_cooling_period     NUMBER := -1;   -- Put the default max cooling period to a -ve number.
   l_cycle_days             NUMBER;         -- Days remaining for cycle days
   l_program_id             x_program_parameters.objid%TYPE;

   o_result                 NUMBER;

   l_cooling_period         x_program_enrolled.x_cooling_period%TYPE;
   l_enrollment_status      x_program_enrolled.x_enrollment_status%TYPE;


BEGIN
   -- Get the program parameter for the enrollment.
   select pgm_enroll2pgm_parameter, X_COOLING_PERIOD, x_enrollment_status
     into l_program_id, l_cooling_period, l_enrollment_status
     from x_program_enrolled
    where objid = p_prog_enrolled_objid;

   -- If the program is in SUSPENDED state, show only the subsequent cooling period.
   if (    l_enrollment_status = 'SUSPENDED' AND l_cooling_period is not null ) then
        op_cooling_period := l_cooling_period;
        op_msg            := 'Applying subsequent cooling period';
        return;
   end if;

   -- Get all the conditions for General Rules - ordered by rule priority for SetCoolingPeriod Action.
   FOR idx IN  (SELECT ct.set_trans2rule_act_mas, ct.set_trans2rule_cat_mas,
                       ct.x_update_status, ct.objid, ct.x_rule_act_param, act.X_RULE_ACT_EXE_FLAG_CODE
                  FROM x_rule_create_trans ct, x_rule_attempt_master rat, x_rule_action_master act
                 WHERE ct.SET_TRANS2RULE_ATM_MAS = rat.objid
                   AND ct.SET_TRANS2RULE_ACT_MAS = act.objid
                   AND ct.set_trans2rule_cat_mas = ( select objid from x_rule_category_master where X_RULE_CAT_NAME = 'Voluntary DeEnrollment Rules' )
                   AND rat.x_rule_amt_desc = 'General'
                   AND act.X_RULE_ACT_NAME = 'Set Cooling Period'
                   AND ct.x_update_status != 'D'
                   ORDER by ct.SET_TRANS2RULE_ACT_MAS, ct.X_RULE_PRIORITY )
   LOOP

	  BILLING_RULE_COND_EVAL_PKG.BILLING_RULE_COND_EVAL (
	                           p_prog_enrolled_objid,
                               idx.objid,
                               NULL,
                               0,
                               l_program_id,
                               NULL,
                               p_esn,
                               NULL,
                               p_webuser_objid,
                               NULL,
                               NULL,
                               NULL,
                               0,
                               0,
                               0,
                               0,
                               NULL,
                               NULL,
                               NULL,
                               o_result,
                               op_result,
                               op_msg
	  );
	  IF o_result = 0 THEN
          op_msg := 'No Rule Condition Match';
          op_result := -100;

	  ELSIF o_result = 1 THEN
            -- Condition has passed. Check if the execute_only_once flag has been set. If the the condition has been set
            -- return the value from the procedure.
            l_max_cooling_period := GREATEST ( l_max_cooling_period,
                                           to_number(NVL(Substr(idx.x_rule_act_param,Instr(idx.x_rule_act_param,'=')+1),0))
                                         );

            IF idx.X_RULE_ACT_EXE_FLAG_CODE = 1 THEN       -- Execute only once flag is set. Use current cooling period value.
                    EXIT;
            END IF;
	  END IF;

   END LOOP;


   if ( l_max_cooling_period = -1 ) THEN     -- No general rules matched. Check for Default Rules

   FOR idx IN  (SELECT ct.set_trans2rule_act_mas, ct.set_trans2rule_cat_mas,
                       ct.x_update_status, ct.objid, ct.x_rule_act_param, act.X_RULE_ACT_EXE_FLAG_CODE
                  FROM x_rule_create_trans ct, x_rule_attempt_master rat, x_rule_action_master act
                 WHERE ct.SET_TRANS2RULE_ATM_MAS = rat.objid
                   AND ct.SET_TRANS2RULE_ACT_MAS = act.objid
                   AND ct.set_trans2rule_cat_mas = ( select objid from x_rule_category_master where X_RULE_CAT_NAME = 'Voluntary DeEnrollment Rules' )
                   AND rat.x_rule_amt_desc = 'Default'
                   AND act.X_RULE_ACT_NAME = 'Set Cooling Period'
                   AND ct.x_update_status != 'D'
                   ORDER by ct.SET_TRANS2RULE_ACT_MAS, ct.X_RULE_PRIORITY )
       LOOP
            -- No condition matches required. Check the max values only.
            l_max_cooling_period := GREATEST ( l_max_cooling_period,
                                          to_number(NVL(Substr(idx.x_rule_act_param,Instr(idx.x_rule_act_param,'=')+1),0))
                                         );


            IF idx.X_RULE_ACT_EXE_FLAG_CODE = 1 THEN       -- Execute only once flag is set. Use current cooling period value.
                    EXIT;
            END IF;

       END LOOP;
   end if;

   IF l_max_cooling_period = -1 THEN             -- No matches in General or default rules. Special case: Return 0
        op_cooling_period := 0;
   ELSE
       op_cooling_period := l_max_cooling_period;
   END IF;

   ---------------- Find out if the enrollment is for "DeEnroll at cycle Date". --------------------------
   BEGIN
       select NVL ( trunc(x_next_charge_date+1 - sysdate) , 0 )
       into   l_cycle_days
       from   x_program_enrolled a, x_program_parameters b
       where  a.pgm_enroll2pgm_parameter = b.objid
         and  X_DE_ENROLL_CUTOFF_CODE = 0
         and  a.objid = p_prog_enrolled_objid;

       op_cooling_period := GREATEST ( op_cooling_period, l_cycle_days );


   EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
   END;

   -------------------------------------------------------------------------------------------------------

   op_result := 0;
   op_msg := 'Success';

EXCEPTION
   WHEN OTHERS
   THEN
      op_cooling_period := -100;  -- Return -ve cooling period to indicate an error.
      op_result := -100;
      op_msg :=    SQLCODE
                || SUBSTR (SQLERRM, 1, 100);
END billing_get_cp_rule_engine;
/