CREATE OR REPLACE PROCEDURE sa."BILLING_DEACT_RULE_ACTION" (
--------------------------------------------------------------------------------------------
--$RCSfile: BILLING_DEACT_RULE_ACTION.sql,v $
--$Revision: 1.7 $
--$Author: ddevaraj $
--$Date: 2015/05/27 18:36:34 $
--$ $Log: BILLING_DEACT_RULE_ACTION.sql,v $
--$ Revision 1.7  2015/05/27 18:36:34  ddevaraj
--$ FOR CR33039
--$
--$ Revision 1.6  2015/05/22 15:12:13  ddevaraj
--$ For 33039
--$
--$ Revision 1.5  2015/05/20 20:04:02  ddevaraj
--$ For CR33039
--$
--$ Revision 1.3  2012/12/10 16:42:38  mmunoz
--$ CR22380 Handset Protection added logic to skip action for WARRANTY program class, considering NULL in program class
--$
--$ Revision 1.2  2012/12/07 15:56:50  mmunoz
--$ CR22380 Handset Protection added logic to skip action for WARRANTY program class
--$
--------------------------------------------------------------------------------------------
 /*************************************************************************************************/
 /* */
 /* Name : billing_deact_rule_action */
 /* */
 /* Purpose : Action taken by deactivation of ESN */
 /* */
 /* */
 /* Platforms : Oracle 9i */
 /* */
 /* Author : RSI */
 /* */
 /* Date : 07-11-2006 */
 /* REVISIONS: */
 /* VERSION DATE WHO PURPOSE */
 /* ------- ---------- ----- -------------------------------------------- */
 /* 1.0 Initial Version - Splitting BILLING_DEACT_RULE_ENGINE */
 /* 1.1 CR7130 - Deactivation issue (WEBCSR,CBO) */
 /* 1.2/1.3 CR8663 Walmart Monthly Plans
 /* 1.4 CR10766
 /*************************************************************************************************/
 p_esn IN x_program_enrolled.x_esn%TYPE,
 p_rule_objid IN x_rule_create_trans.objid%TYPE,
 p_action_type IN x_rule_create_trans.set_trans2rule_act_mas%TYPE,
 p_action_param IN x_rule_create_trans.x_rule_act_param%TYPE,
 p_user IN table_user.login_name%TYPE,
 op_result OUT NUMBER,
 op_msg OUT VARCHAR2
)
IS
 l_coolingperiod NUMBER;
 l_graceperiod NUMBER;
 l_penalty NUMBER;
 l_days NUMBER;
 l_result NUMBER;
 l_first_name table_contact.first_name%TYPE;
 l_last_name table_contact.last_name%TYPE;
 l_program_name x_program_parameters.x_program_name%TYPE;
 --CR7130
 l_denrol_yes CHAR (1) := 'F';
 l_susp_yes CHAR (1) := 'F';
 l_wait_yes CHAR (1) := 'F';
 --CR7130
 l_sb_esn NUMBER := 0;
--CR10766
v_install_date number := 0;------for CR33039
BEGIN

 --- Parse the action parameters passed.
 billing_parse_action (p_action_param,
                       l_graceperiod,
                       l_penalty,
                       l_coolingperiod,
                       l_days,
                       op_result,
                       op_msg );

--------------for CR33039
 FOR enroll_rec IN (
                    --SELECT *
                    --FROM x_program_enrolled
                    --WHERE x_esn = p_esn
                    --AND x_enrollment_status IN ('ENROLLED', 'SUSPENDED')
                    --CR22380 Handset Protection Skip WARRANTY
                    SELECT pe.*
                    FROM  x_program_enrolled pe, x_program_parameters pp
                    WHERE pe.x_esn = p_esn
                    AND pe.x_enrollment_status IN ('ENROLLED', 'SUSPENDED')
                    and pp.objid = pe.pgm_enroll2pgm_parameter
                    AND NVL(PP.x_prog_class,'-1') = 'WARRANTY'
                   )
 LOOP

select round(trunc(sysdate)-max(X_EXPIRE_DT))
into v_install_date
from table_site_part
where x_service_id= p_esn
and part_status='Inactive';

if v_install_date > 60 then

 --- Call the Suspend Action
 billing_rule_engine_action_pkg.suspend_esn_rule_action (p_esn,
 enroll_rec.objid, l_graceperiod, l_coolingperiod, l_penalty,
 p_rule_objid, 'SUSPENDED', op_result, op_msg );
 --- Update the rule engine call metrics
 billing_rule_engine_action_pkg.update_metrics_rules_engine (
 p_rule_objid, l_result, op_result, op_msg );
 --- Check the action to be performed
 /* Insert the record into billing log */
 END IF;
 --------------------------------------------------------------------------------------------------
 ---------------- Get the contact details for logging ---------------------------------------------
 SELECT first_name,
 last_name
 INTO l_first_name, l_last_name
 FROM table_contact
 WHERE objid = (
 SELECT web_user2contact
 FROM table_web_user
 WHERE objid = enroll_rec.pgm_enroll2web_user);
 ---------------- Get the program name for logging ------------------------------------------------
 SELECT x_program_name
 INTO l_program_name
 FROM x_program_parameters
 WHERE objid = enroll_rec.pgm_enroll2pgm_parameter;
 ---------------- Insert a billing Log ------------------------------------------------------------
 INSERT
 INTO x_billing_log(
 objid,
 x_log_category,
 x_log_title,
 x_log_date,
 x_details,
 x_program_name,
 x_nickname,
 x_esn,
 x_originator,
 x_contact_first_name,
 x_contact_last_name,
 x_agent_name,
 x_sourcesystem,
 billing_log2web_user
 ) VALUES(
 billing_seq ('X_BILLING_LOG'),
 'Program',
 'Program Suspended',
 SYSDATE,
 l_program_name || ' Suspended due to deactivation',
 l_program_name,
 billing_getnickname (enroll_rec.x_esn),
 enroll_rec.x_esn,
 'System',
 l_first_name,
 l_last_name,
 'System',
 enroll_rec.x_sourcesystem,
 enroll_rec.pgm_enroll2web_user
 );
 END LOOP;
 --------------for CR33039
 --CR7130
 FOR denrol_rec IN (SELECT objid
                    FROM x_rule_action_master
                    WHERE x_rule_act_name = 'De-Enroll')
 LOOP
 IF p_action_type = denrol_rec.objid --- DEEnroll Action
 THEN
 l_denrol_yes := 'T';
 EXIT;
 END IF;
 END LOOP;
 /*
 Perform the De-Enroll Action for all the programs
 enrolled by the ESN
 */
 IF l_denrol_yes = 'T'
 THEN

 --IF p_action_type = 21
 --CR7130
 FOR enroll_rec IN (
                    --SELECT *
                    --FROM x_program_enrolled
                    --WHERE x_esn = p_esn
                    --AND x_enrollment_status IN ('ENROLLED', 'SUSPENDED')
                    --CR22380 Handset Protection Skip WARRANTY
                    SELECT pe.*
                    FROM  x_program_enrolled pe, x_program_parameters pp
                    WHERE pe.x_esn = p_esn
                    AND pe.x_enrollment_status IN ('ENROLLED', 'SUSPENDED')
                    and pp.objid = pe.pgm_enroll2pgm_parameter
                    AND NVL(PP.x_prog_class,'-1') <> 'WARRANTY'
                   )
 LOOP

 --REL55
 l_sb_esn := 0;
 IF billing_job_pkg.is_SB_esn(NULL, p_esn) = 1
 THEN
 l_sb_esn := 1;
 ELSE
 l_sb_esn := 0;
 END IF;
 --REL55
 --- Call the De-Enrollment Action
 billing_rule_engine_action_pkg.de_enroll_rule_action (p_esn,
 enroll_rec.objid, l_coolingperiod, NULL, p_rule_objid, p_user,
 'Voluntary DeEnrollment Rules', op_result, op_msg );
 --- Update the rule engine call metrics
 billing_rule_engine_action_pkg.update_metrics_rules_engine (
 p_rule_objid, l_result, op_result, op_msg );
 --- Check the action to be performed
 /* Insert the record into billing log */
 --------------------------------------------------------------------------------------------------
 ---------------- Get the contact details for logging ---------------------------------------------
 SELECT first_name,
 last_name
 INTO l_first_name, l_last_name
 FROM table_contact
 WHERE objid = (
 SELECT web_user2contact
 FROM table_web_user
 WHERE objid = enroll_rec.pgm_enroll2web_user);
 ---------------- Get the program name for logging ------------------------------------------------
 SELECT x_program_name
 INTO l_program_name
 FROM x_program_parameters
 WHERE objid = enroll_rec.pgm_enroll2pgm_parameter;
 ---------------- Insert a billing Log ------------------------------------------------------------
 INSERT
 INTO x_billing_log(
 objid,
 x_log_category,
 x_log_title,
 x_log_date,
 x_details,
 x_program_name,
 x_nickname,
 x_esn,
 x_originator,
 x_contact_first_name,
 x_contact_last_name,
 x_agent_name,
 x_sourcesystem,
 billing_log2web_user
 ) VALUES(
 billing_seq ('X_BILLING_LOG'),
 'Program',
 'Program De-enrolled',
 SYSDATE,
 'System Deenrollment',
 l_program_name,
 billing_getnickname (enroll_rec.x_esn),
 enroll_rec.x_esn,
 'System',
 l_first_name,
 l_last_name,
 'System',
 enroll_rec.x_sourcesystem,
 enroll_rec.pgm_enroll2web_user
 );
 -- Added by Ruchi
 -- Notify Enrollment Cancellation when deenrolled
 -- CR8663
 --IF billing_job_pkg.is_SB_esn(NULL, p_esn) <> 1 --REL55
 IF l_sb_esn <> 1
 THEN
 INSERT
 INTO x_program_notify(
 objid,
 x_esn,
 x_program_name,
 x_program_status,
 x_notify_process,
 x_notify_status,
 x_source_system,
 x_process_date,
 x_language,
 x_remarks,
 pgm_notify2pgm_objid,
 pgm_notify2contact_objid,
 pgm_notify2web_user,
 pgm_notify2pgm_enroll,
 x_message_name
 ) VALUES(
 billing_seq ('X_PROGRAM_NOTIFY'),
 enroll_rec.x_esn,
 l_program_name,
 'DEENROLLED',
 'DE_ENROLL_JOB',
 'PENDING',
 enroll_rec.x_sourcesystem,
 SYSDATE,
 enroll_rec.x_language,
 'DEENROLLED SUCESSFULLY',
 enroll_rec.pgm_enroll2pgm_group,
 enroll_rec.pgm_enroll2contact,
 enroll_rec.pgm_enroll2web_user,
 enroll_rec.objid,
 'Enrollment Cancellation'
 );
 END IF;
--CR8663
 --------------------------------------------------------------------------------------------------
 END LOOP;
 END IF;
 --------------------------------------------- SUSPEND ACTION ----------------------------------------------------
 --CR7130
 FOR susp_rec IN (SELECT objid
                  FROM x_rule_action_master
                  WHERE x_rule_act_name = 'Suspend Customer')
 LOOP
 IF p_action_type = susp_rec.objid --- DEEnroll Action
 THEN
 l_susp_yes := 'T';
 EXIT;
 END IF;
 END LOOP;
 /*
 Perform the De-Enroll Action for all the programs
 enrolled by the ESN
 */
 IF l_susp_yes = 'T'
 THEN
--IF p_action_type = 22
 --CR7130
 --- Suspend Action
 /*
 Perform the Suspend Action for all the programs
 enrolled by the ESN
 */
 FOR enroll_rec IN (
                    --SELECT *
                    --FROM x_program_enrolled
                    --WHERE x_esn = p_esn
                    --AND x_enrollment_status IN ('ENROLLED', 'SUSPENDED')
                    --CR22380 Handset Protection Skip WARRANTY
                    SELECT pe.*
                    FROM  x_program_enrolled pe, x_program_parameters pp
                    WHERE pe.x_esn = p_esn
                    AND pe.x_enrollment_status IN ('ENROLLED', 'SUSPENDED')
                    and pp.objid = pe.pgm_enroll2pgm_parameter
                    AND NVL(PP.x_prog_class,'-1') <> 'WARRANTY'
                   )
 LOOP

 --- Call the Suspend Action
 billing_rule_engine_action_pkg.suspend_esn_rule_action (p_esn,
 enroll_rec.objid, l_graceperiod, l_coolingperiod, l_penalty,
 p_rule_objid, 'ESN DEACTIVATION', op_result, op_msg );
 --- Update the rule engine call metrics
 billing_rule_engine_action_pkg.update_metrics_rules_engine (
 p_rule_objid, l_result, op_result, op_msg );
 --- Check the action to be performed
 /* Insert the record into billing log */
 --------------------------------------------------------------------------------------------------
 ---------------- Get the contact details for logging ---------------------------------------------
 SELECT first_name,
 last_name
 INTO l_first_name, l_last_name
 FROM table_contact
 WHERE objid = (
 SELECT web_user2contact
 FROM table_web_user
 WHERE objid = enroll_rec.pgm_enroll2web_user);
 ---------------- Get the program name for logging ------------------------------------------------
 SELECT x_program_name
 INTO l_program_name
 FROM x_program_parameters
 WHERE objid = enroll_rec.pgm_enroll2pgm_parameter;
 ---------------- Insert a billing Log ------------------------------------------------------------
 INSERT
 INTO x_billing_log(
 objid,
 x_log_category,
 x_log_title,
 x_log_date,
 x_details,
 x_program_name,
 x_nickname,
 x_esn,
 x_originator,
 x_contact_first_name,
 x_contact_last_name,
 x_agent_name,
 x_sourcesystem,
 billing_log2web_user
 ) VALUES(
 billing_seq ('X_BILLING_LOG'),
 'Program',
 'Program Suspended',
 SYSDATE,
 l_program_name || ' Suspended due to deactivation',
 l_program_name,
 billing_getnickname (enroll_rec.x_esn),
 enroll_rec.x_esn,
 'System',
 l_first_name,
 l_last_name,
 'System',
 enroll_rec.x_sourcesystem,
 enroll_rec.pgm_enroll2web_user
 );
 END LOOP;
 ------------------added for CR33039

 -------------------end CR33039
 END IF;
 --------------------------------------------- SETWAITGRACEPERIOD ACTION ----------------------------------------------------
 --CR7130
 FOR wait_rec IN (SELECT objid
                  FROM x_rule_action_master
                  WHERE x_rule_act_name = 'Set Wait Period')
 LOOP
 IF p_action_type = wait_rec.objid --- DEEnroll Action
 THEN
 l_wait_yes := 'T';
 EXIT;
 END IF;
 END LOOP;
 /*
 Perform the De-Enroll Action for all the programs
 enrolled by the ESN
 */
 IF l_wait_yes = 'T'
 THEN

 --IF p_action_type = 29
 --CR7130
 --- Set Wait Grace Period action
 /*
 Perform the SetWaitGracePeriod Action for all the programs
 enrolled by the ESN
 */
 FOR enroll_rec IN (
                    --SELECT *
                    --FROM x_program_enrolled
                    --WHERE x_esn = p_esn
                    --AND x_enrollment_status IN ('ENROLLED', 'SUSPENDED')
                    --CR22380 Handset Protection Skip WARRANTY
                    SELECT pe.*
                    FROM  x_program_enrolled pe, x_program_parameters pp
                    WHERE pe.x_esn = p_esn
                    AND pe.x_enrollment_status IN ('ENROLLED', 'SUSPENDED')
                    and pp.objid = pe.pgm_enroll2pgm_parameter
                    AND NVL(PP.x_prog_class,'-1') <> 'WARRANTY'
                   )
 LOOP

 --- Call the SetWaitPeriod Action
 billing_rule_engine_action_pkg.set_wait_grace_period_action (
 enroll_rec.objid, l_graceperiod, l_days, l_coolingperiod, p_user,
 op_result, op_msg );
 --- Update the rule engine call metrics
 billing_rule_engine_action_pkg.update_metrics_rules_engine (
 p_rule_objid, l_result, op_result, op_msg );
 --- Check the action to be performed
 /* Insert the record into billing log */
 --------------------------------------------------------------------------------------------------
 ---------------- Get the contact details for logging ---------------------------------------------
 SELECT first_name,
 last_name
 INTO l_first_name, l_last_name
 FROM table_contact
 WHERE objid = (
 SELECT web_user2contact
 FROM table_web_user
 WHERE objid = enroll_rec.pgm_enroll2web_user);
 ---------------- Get the program name for logging ------------------------------------------------
 SELECT x_program_name
 INTO l_program_name
 FROM x_program_parameters
 WHERE objid = enroll_rec.pgm_enroll2pgm_parameter;
 ---------------- Insert a billing Log ------------------------------------------------------------
 INSERT
 INTO x_billing_log(
 objid,
 x_log_category,
 x_log_title,
 x_log_date,
 x_details,
 x_program_name,
 x_nickname,
 x_esn,
 x_originator,
 x_contact_first_name,
 x_contact_last_name,
 x_agent_name,
 x_sourcesystem,
 billing_log2web_user
 ) VALUES(
 billing_seq ('X_BILLING_LOG'),
 'Program',
 'Program Wait Period',
 SYSDATE,
 l_program_name || ' Wait Period due to deactivation',
 l_program_name,
 billing_getnickname (enroll_rec.x_esn),
 enroll_rec.x_esn,
 'System',
 l_first_name,
 l_last_name,
 'System',
 enroll_rec.x_sourcesystem,
 enroll_rec.pgm_enroll2web_user
 );
 END LOOP;
 END IF;
 op_result := 0;
 op_msg := 'Success';
 EXCEPTION
 WHEN OTHERS
 THEN
 op_result := - 100;
 op_msg := SQLERRM;
END BILLING_DEACT_RULE_ACTION;
/