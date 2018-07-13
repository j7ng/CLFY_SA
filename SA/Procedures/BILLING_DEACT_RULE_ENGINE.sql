CREATE OR REPLACE PROCEDURE sa."BILLING_DEACT_RULE_ENGINE" (
--------------------------------------------------------------------------------------------
--$RCSfile: BILLING_DEACT_RULE_ENGINE.sql,v $
--$Revision: 1.11 $
--$Author: rpednekar $
--$Date: 2017/01/20 22:13:43 $
--$ $Log: BILLING_DEACT_RULE_ENGINE.sql,v $
--$ Revision 1.11  2017/01/20 22:13:43  rpednekar
--$ CR46079 - Modified if condition to skip de-enrollment for NET10 minchange.
--$
--$ Revision 1.10  2016/11/04 14:34:24  sraman
--$ CR45180 to skip deenrollment for MINCHANGE for ST and SM brands
--$
--$ Revision 1.9  2016/10/07 15:40:20  sraman
--$ CR45180 to skip deenrollment for MINCHANGE
--$
--$ Revision 1.7  2016/02/17 21:27:51  rpednekar
--$ CR37949 - Added if condition to skip de-enrollment for NET10 upgrade.
--$
--$ Revision 1.5  2012/12/07 18:21:58  mmunoz
--$ CR22380 Handset Protection added logic to skip action for WARRANTY program class rules
--$
--------------------------------------------------------------------------------------------
/*************************************************************************************************/
/* */
/* Name : SA.billing_deact_rule_engine */
/* */
/* Purpose : De-enrollment of ESN by deactivation of ESN */
/* */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*  1.1     26-Jun-06                Added UserName for logging purposes                         */
/*  1.2     05/20/09                 CR8663 changes                                                                                           */
/*  1.3     06/09/09                 CR8663_IV FIX CURSOR CWL  */
/*  1.4     06/22/09                 Correct CR# CR10766
/*  1.5     06/26/12                 CR20451 | CR20854: Add TELCEL Brand
/*************************************************************************************************/
   p_esn                 IN       x_program_enrolled.x_esn%TYPE,
   p_deact_reason_code   IN       VARCHAR2,
   p_user                IN       VARCHAR2,
                        --This field actually contains the objid of Table_user
   op_result             OUT      NUMBER,
   op_msg                OUT      VARCHAR2
)
IS
   l_coolingperiod         NUMBER;
   l_graceperiod           NUMBER;
   l_penalty               NUMBER;
   l_days                  NUMBER;
   o_result                NUMBER;
   RESULT                  NUMBER;
   l_date                  DATE                               DEFAULT SYSDATE;
   l_user                  table_user.login_name%TYPE             := 'System';
   l_first_name            table_contact.first_name%TYPE;
   l_last_name             table_contact.last_name%TYPE;
   l_program_name          x_program_parameters.x_program_name%TYPE;
   l_err_num               NUMBER;
   l_err_msg               VARCHAR2 (255);
   l_default_flag          BOOLEAN                                   := FALSE;
   l_counter               NUMBER;
   bgeneralrulesexecflag   BOOLEAN                                   := FALSE;
   bpgm_class_flag         BOOLEAN                                   := FALSE;
   -- CR15325 PMistry 02/28/201 SIM Exchange Start
   -- CR20451 | CR20854: Add TELCEL Brand added this field bo.org_flow to the cursor
   cursor CUR_ESN_BRAND is
            select bo.org_id brand_name, bo.org_flow
            from   TABLE_PART_INST PI, TABLE_MOD_LEVEL ML, TABLE_PART_NUM PN, table_bus_org bo
            where  1 = 1
            and    ML.OBJID             = PI.N_PART_INST2PART_MOD
            and    PN.OBJID             = ML.PART_INFO2PART_NUM
            and    BO.OBJID             = PN.PART_NUM2BUS_ORG
            and    PI.PART_SERIAL_NO    = P_ESN;

    REC_ESN_BRAND CUR_ESN_BRAND%rowtype;

   -- CR15325 PMistry 02/28/201 SIM Exchange End

--CR22380 Handset Protection function is_pgm__pgmclass added
   function is_pgmclass_rule (
      ip_pp_objid    in X_PROGRAM_PARAMETERS.objid%type,
      ip_prog_class  in X_PROGRAM_PARAMETERS.x_prog_class%type
   )
   return boolean is
      v_flag    boolean := FALSE;
      v_cnt     number := 0;
   begin
      --Check if the program belongs to prog_class
      select count(*)
      INTO   v_cnt
      FROM   x_program_parameters pp
      WHERE  pp.objid = ip_pp_objid
      AND    PP.x_prog_class = ip_prog_class;

      if v_cnt > 0
      then
          v_flag := TRUE;
      end if;
      RETURN v_flag;
   end;
BEGIN
--DBMS_OUTPUT.disable;
--DBMS_OUTPUT.enable(1000000);
--DBMS_OUTPUT.PUT_LINE('ESN '||p_esn);
   -- Assume a success.
   op_result := 0;
   op_msg := 'Success';

   -- Get the user attempting the deactivation
   BEGIN
      SELECT login_name
        INTO l_user
        FROM table_user
       WHERE objid = p_user;
   EXCEPTION
      WHEN OTHERS
      THEN
-- Incase of any error retrieving user name, Assume 'System'
         l_user := 'System';
   END;

   -- NEW CHANGE STRAIGHT TALK - CR8663
   -- Check if ESN is enrolled in SWITCH BASE PLAN
   -- FIX CURSOR CWL 06/08/09 CR8663 --CR10766
   SELECT COUNT (*)
     INTO l_counter
     FROM x_program_enrolled pe, x_program_parameters pp
    WHERE 1 = 1
      AND pe.pgm_enroll2pgm_parameter = pp.objid
--      AND pp.x_prog_class = 'SWITCHBASE' CR22380 commented out
      AND pp.x_prog_class IN ('SWITCHBASE', 'WARRANTY')  --CR22380 Handset Protection Adding WARRANTY
      AND pe.x_enrollment_status IN ('ENROLLED', 'SUSPENDED')
      AND pe.x_esn = p_esn;

   -- End of NEW CHANGE STRAIGHT TALK - CR8663
   -- Get all the rules created for Deactivation category.
   FOR idx IN (SELECT ct.set_trans2rule_act_mas, ct.set_trans2rule_cat_mas,
                      ct.x_update_status, ct.objid, ct.x_rule_act_param, ct.x_rule_set_name
                 FROM x_rule_create_trans ct, x_rule_attempt_master rat
                WHERE ct.set_trans2rule_atm_mas = rat.objid
                  AND ct.set_trans2rule_cat_mas =
                               (SELECT objid
                                  FROM x_rule_category_master
                                 WHERE x_rule_cat_name = 'DeActivation Rules')
                  AND rat.x_rule_amt_desc = 'General'
                  AND ct.x_update_status != 'D')
   LOOP

--DBMS_OUTPUT.PUT_LINE(chr(10)||chr(10)|| 'X_RULE_ACT_NAME: '||idx.set_trans2rule_act_mas ||'    x_rule_set_name: '||idx.x_rule_set_name ||'    x_rule_act_param: '||idx.x_rule_act_param||'    idx.objid: '||idx.objid);

      --- For each of the rules, Get all the conditions.
      FOR idx1 IN (SELECT *
                     FROM x_rule_cond_trans rct
                    WHERE rct.cond_trans2create_trans = idx.objid
                      AND rct.x_update_status != 'D')
      LOOP

         --Dbms_output.PUT_LINE(chr(10)||'    RULE_COND : '|| IDX1.X_RULE_COND_DESC ||chr(10)||'    x_rule_cond_query: '||idx1.x_rule_cond_query|| '    X_RULE_PARAM_1: '|| idx1.X_RULE_PARAM_1 ||'    DEACT_REASON: ' || p_deact_reason_code ||'    idx1.objid: ' || idx1.objid );

         -- NEW CHANGE STRAIGHT TALK - CR8663
         IF (l_counter > 0)
         THEN
            --Dbms_output.PUT_LINE('    Before if idx1.x_rule_cond_query = NAME_AUTOPAY_PGM_ENROLL   l_counter= '||l_counter);
-- Check for Straight Talk Plan
            IF idx1.x_rule_cond_query = 'NAME_AUTOPAY_PGM_ENROLL'
            THEN

               -- CR15325 PMistry 02/28/201 SIM Exchange Start
               open CUR_ESN_BRAND;
               FETCH CUR_ESN_BRAND into REC_ESN_BRAND;
               close CUR_ESN_BRAND;

--CR22380 Handset Protection begin
               bpgm_class_flag := FALSE;

               IF (     idx1.x_rule_cond_query = 'NAME_AUTOPAY_PGM_ENROLL'
                   and  idx1.X_RULE_EVAL_1     = 'IS_EQ_TO')
               THEN
                   bpgm_class_flag  := is_pgmclass_rule(to_number(trim(idx1.X_RULE_PARAM_1)),'WARRANTY');
               END IF;
--CR22380 Handset Protection end

         --Dbms_output.PUT_LINE('    bpgm_class_flag: '||case when bpgm_class_flag then 'TRUE' else 'FALSE' end );

               -- if nvl(REC_ESN_BRAND.BRAND_NAME,'X') = 'STRAIGHT_TALK'
               if  (nvl(REC_ESN_BRAND.ORG_FLOW,'X') = '3'
               and P_DEACT_REASON_CODE = 'ST SIM EXCHANGE')
               or  (bpgm_class_flag)                                        ----CR22380 Handset Protection Skip rules for WARRANTY
               then
                  --Dbms_output.PUT_LINE('     condition match then NULL');
                  null;
				--- Start added for CR37949 to skip deenrollment for NET10 upgrade
				Elsif  (nvl(REC_ESN_BRAND.ORG_FLOW,'X') = '2'  -- NET10
               and UPPER(P_DEACT_REASON_CODE) IN ( 'UPGRADE','MINCHANGE')	)	--CR46079 -- ADDED REASON CODE MINCHANGE
               or  (bpgm_class_flag)
               then
					NULL;

				-- End added for CR37949 to skip deenrollment for NET10 upgrade

				--- Start added for CR45180 to skip deenrollment for MINCHANGE
				Elsif  UPPER(p_deact_reason_code) = 'MINCHANGE' AND NVL(REC_ESN_BRAND.ORG_FLOW,'X') = '3' THEN
					NULL;
				-- End added for CR45180 to skip deenrollment for MINCHANGE

               else
                   bgeneralrulesexecflag := TRUE;
                   --Dbms_output.PUT_LINE('    CALLING billing_deact_rule_action  NOT match   bgeneralrulesexecflag: TRUE');
                   billing_deact_rule_action (p_esn,
                                              idx.objid,
                                              idx.set_trans2rule_act_mas,
                                              idx.x_rule_act_param,
                                              l_user,
                                              op_result,
                                              op_msg
                                             );
               end if;
               -- CR15325 PMistry 02/28/201 SIM Exchange end
            END IF;                                                    --idx1.x_rule_cond_query = 'NAME_AUTOPAY_PGM_ENROLL'
            --Dbms_output.PUT_LINE('    After End if idx1.x_rule_cond_query = NAME_AUTOPAY_PGM_ENROLL   l_counter= '||l_counter);

         ELSE
            --Dbms_output.PUT_LINE('Checking rules when l_counter= '||l_counter);
            -- Additional Check to ensure that the rules are belonging to WEBCSR_DEACTIVATION
            IF idx1.x_rule_cond_query = 'WEB_CSR_DEACTIVATION_REASON'
            THEN
               -- Call the WebCSR Deaction Rule Engine
               billing_rule_engine_pkg.web_csr_deactivation_reason
                                                        (p_deact_reason_code,
                                                         idx1.objid,
                                                         o_result,
                                                         op_result,
                                                         op_msg
                                                        );

               --dbms_output.put_line('Check Return = ' || o_result);
               --- Check for the response.
               IF o_result = 0
               THEN
                  /* If no conditions matched, EXIT out of the loop. */
                  op_msg := 'No Rule Condition Match';
                  op_result := -100;
                  --dbms_output.put_line('billing_rule_engine_pkg.web_csr_deactivation_reason => ' || op_msg);
                  EXIT;
               END IF;
            END IF;
         END IF;
      END LOOP;

      --dbms_output.put_line('    Overall Status Check :    op_result IS ' || op_result || ',   o_result: ' || o_result);
      IF (op_result IS NULL)
      THEN
         /*   Conditions have matched.
                    Get the parameters defined for the necessary Actions
               */
         --- Set a flag to indicate General Rules are executed.
         bgeneralrulesexecflag := TRUE;
         --Dbms_output.PUT_LINE('    CALLING billing_deact_rule_action General Rules are executed   bgeneralrulesexecflag: TRUE');

         billing_deact_rule_action (p_esn,
                                    idx.objid,
                                    idx.set_trans2rule_act_mas,
                                    idx.x_rule_act_param,
                                    l_user,
                                    op_result,
                                    op_msg
                                   );

      END IF;
   END LOOP;

   ---- Check if we need to execute Default Rules
   IF (bgeneralrulesexecflag = FALSE)
   THEN
      -- Get all the rules created for Deactivation category.
      FOR idx IN (SELECT ct.set_trans2rule_act_mas,
                         ct.set_trans2rule_cat_mas, ct.x_update_status,
                         ct.objid, ct.x_rule_act_param
                    FROM x_rule_create_trans ct, x_rule_attempt_master rat
                   WHERE ct.set_trans2rule_atm_mas = rat.objid
                     AND ct.set_trans2rule_cat_mas =
                               (SELECT objid
                                  FROM x_rule_category_master
                                 WHERE x_rule_cat_name = 'DeActivation Rules')
                     AND rat.x_rule_amt_desc = 'Default'
                     AND ct.x_update_status != 'D')
      LOOP
         --Dbms_output.PUT_LINE('    CALLING billing_deact_rule_action to execute Default Rules '||idx.objid);

         billing_deact_rule_action (p_esn,
                                    idx.objid,
                                    idx.set_trans2rule_act_mas,
                                    idx.x_rule_act_param,
                                    l_user,
                                    op_result,
                                    op_msg
                                   );

      END LOOP;
   END IF;

   COMMIT;
--DBMS_OUTPUT.enable(1000000);
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      NULL;
-- Dont do anything.
   WHEN OTHERS
   THEN
      op_result := -100;
      op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
      --Dbms_output.PUT_LINE('EXCEPTION '||op_result||'  '||op_msg);
      -- Put in the values into the output variables.
      l_err_num := SQLCODE;
      l_err_msg := SUBSTR (SQLERRM, 1, 100);

------------------------ Exception Logging --------------------------------------------------------------------
---  Incase of any Exceptions, Log the data in the Error Log table for debugging purposes.
      INSERT INTO x_program_error_log
                  (x_source, x_error_code, x_error_msg,
                   x_date,
                   x_description,
                   x_severity
                  )
           VALUES ('BILLING_DEACT_RULE_ENGINE', l_err_num, l_err_msg,
                   SYSDATE,
                      'ESN '
                   || p_esn
                   || ' Deactivation Reason '
                   || p_deact_reason_code,
                   2                                                 -- MEDIUM
                  );
------------------------ Exception Logging --------------------------------------------------------------------

END billing_deact_rule_engine;
/