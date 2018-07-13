CREATE OR REPLACE FUNCTION sa."RESET_ESN_FUN" (
ip_esn IN VARCHAR2,
ip_reset_date IN DATE,
ip_order_num IN VARCHAR2,
ip_user_objid IN NUMBER,
ip_mod_objid IN NUMBER,
ip_bin_objid IN NUMBER,
ip_action_type IN VARCHAR2,
ip_initial_pi_status IN VARCHAR2,
ip_caller_program IN VARCHAR2,
ip_ship_date IN DATE
DEFAULT NULL -- Added to mark the correct ship date for refurb esns
)
RETURN BOOLEAN
IS
/******************************************************************************/
/* Copyright . 2002 Tracfone Wireless Inc. All rights reserved */
/* */
/* Name : SA.Reset_esn_fun */
/* */
/* Purpose : This function resets and esn's statuses and history depend*/
/* on the given action_type 'REFURBISHED','UNREPAIRABLE' and */
/* repaired. Also deactivates active phones when pre deafined*/
/* business rules allow it.                                  */
   /*                                                                            */
   /* PARAMETERS:                                                                */
   /* ip_esn                given esn                                            */
   /* ip_reset_date         repaired, unrapairable (void) and refurbished date   */
   /* ip_order_num          order num to be update in pi                         */
   /* ip_user_objid         user objid to be update                              */
   /* ip_mod_objid          mod_level objid  to be updated                       */
   /* ip_bin_objid          bin objid to be updated                              */
   /* ip_action_type        REFURBISHED, REPAIRED, UNREPAIRABLE                  */
   /* ip_initial_pi_status  intial pi status ( as new) '50' '59'                 */
   /* ip_caller_program     caller program                                       */
   /* ip_ship_date          ship date of esn                                     */
   /* RETURN:          TRUE if execution performed well                          */
   /*                  FALSE if execution failed                                 */
   /*                                                                            */
   /* ASSUMPTIONS:   It is the caller program responsability to COMMIT upon      */
   /*                sucessful execution of this function                        */
   /*                                                                            */
   /* Platforms    :   Oracle 8.0.6 AND newer versions                           */
   /* Revisions   :                                                              */
   /* Version  Date      Who       Purpose                                       */
   /* -------  --------  -------  ---------------------------------------------- */
   /* 1.0      05/10/2002 Mleon   Initial revision                               */
   /*                                                                            */
   /* 1.1      07/25/2002 Mleon   Modified updates to table_part_inst so that in */
   /*                             put parameters: ip_order_num ,ip_user_objid ,  */
   /*                             ip_mod_objid, ip_bin_objid can ba passed as    */
   /*                             NULL and the table_part_inst will update with  */
   /*                             existing x_order_num, user_objid, mod_level    */
   /*                             objid and inv_bin objid in table_Part_inst.    */
   /*                                                                            */
   /* 1.2      08/23/02   VAdapa  Added an update to TABLE_X_DISCOUNT_HIST to    */
   /*                             add 'R' to the esn if the esn is 'REFURBISHED' */
   /*                             or 'UNREPAIRABLE'                              */
   /*                                                                            */
   /* 1.3      01/30/03   VAdapa  Modified to mark the correct ship date for     */
   /*                             refurbished/repaired/unrepairable esns         */
   /* 1.4      03/17/03   SL      Clarify Upgrade                                */
   /* 1.5      12/06/03   ML      Removed hardcode piece (status and status code)*/
   /*                             from unrepairable part                         */
   /* 1.6      09/16/04   GP      CR3164 - Delete records from table             */
   /*                             TABLE_X_CONTACT_PART_INST which is read from   */
   /*                             "MyAccount"                                    */
   /* 1.7      01/10/05   VAdapa  CR3509 -Remove double minute upgrade enrollment*/
   /*                             for a REFURBISHED esn                          */
   /* 1.8      01/10/05   VAdapa  CR4000 -Remove double minute 3390 enrollment   */
   /*                             for a REFURBISHED esn    (PVCS Version 1.6)    */
   /* 1.9      06/03/05    GP     CR4109 - OTA Feature Phone Reset               */
   /* 1.10     07/26/05   SL      CR4282 disable NET10_300_GRP, NET10_600_GRP    */
   /* 1.11     08/01/05   VA      Fix for CR4282
   /* 1.12     08/01/05   VA      Correct fixed version
   /* 1.13     08/16/05   VA      CR4392 - Post Purchase Price Tests
   /* 1.14     09/26/05   VA      Fix_ORA01427 : Fix for ORA-01427: single-row subquery returns more than one row
   /* 1.15     01/09/06   VA    CR4879 - To remove double minute prepaid plan group enrollment for refurbished phones
   /* 1.16     05/17/06   VA  CR4981_4982 - Commented the statement that deletes from TABLE_X_OTA_FEATURES
   /* 1.17     05/18/06   VA  Removed the extra character
   /* 1.18     11/02/06   VA  CR5694 - Reactivations with clear tank flag
   /***************************************************************************************************/
   /*1.1    08/21/07        NGuada    CR6241 Clean ESN data for Refurbishing and Undeliverables       */
   /*1.2    09/18/07        CLindner/VAdapa    CR6731 Eliminate SIM Entry
   /* 1.3  09/17/08     LSATULURI  CR7167 NEW ACTION TYPE REFURB_WITH_SEQ    /***************************************************************************************************/
   /***************************************************************************************************/
   /*  CVS ************************************************************************************/
   /***************************************************************************************************/
   /*1.2-3  06/03/11 ICanavan CR16379 / CR16344 If ESN is being refurbished                     */
   /*                       then remove from TRIPLE minute program                            */


   CURSOR cur_cases
   IS
     SELECT tta.objid
     FROM table_case tta, table_condition
     WHERE     (table_condition.objid = tta.case_state2condition)
     AND (    (table_condition.S_title LIKE 'OPEN%')
     AND (tta.x_esn = ip_esn))
                and tta.objid not in -- CR21968
                (
      select tc.objid
      from table_case tc, table_x_part_request PR
      where tc.objid  = PR.REQUEST2CASE
      and tc.x_esn = ip_esn
      and tc.creation_time > trunc(sysdate) - 30
      and x_status  not like '%CANCEL%'
      and x_part_num_domain = 'PHONES'); -- CR21968

   CURSOR cur_ph IS
   SELECT *
     FROM table_part_inst
    WHERE part_serial_no = ip_esn AND x_domain || '' = 'PHONES';

   CURSOR cur_sitepart IS
   SELECT *
     FROM table_site_part
    WHERE x_service_id = ip_esn AND part_status || '' = 'Active';

   -- CR25549 SIMPLIFY THIS CURSOR
   CURSOR cur_remov_dmucard (ip_esnobjid IN NUMBER) IS
   SELECT *
     FROM table_x_group2esn
    WHERE groupesn2part_inst = ip_esnobjid;

   -- CR25549 add 3 cursors start
  CURSOR cur_grp_primary(ip_esn IN VARCHAR2) IS
  SELECT *
    FROM x_program_enrolled
    WHERE x_esn = ip_esn
      AND x_is_grp_primary = 1
      AND x_enrollment_status <> 'DEENROLLED'
      AND x_type = 'GROUP';

  CURSOR cur_grp_dependent(ip_esn IN VARCHAR2) IS
  SELECT *
    FROM x_program_enrolled
   WHERE pgm_enroll2pgm_group IN
     (SELECT objid FROM x_program_enrolled WHERE x_esn = ip_esn);

  CURSOR cur_account_primary(ip_esn IN VARCHAR2) IS
  SELECT pe.*
    FROM table_x_contact_part_inst cpi, table_part_inst pi, x_program_enrolled pe
   WHERE cpi.x_contact_part_inst2part_inst = pi.objid
     AND pi.part_serial_no = pe.x_esn
     AND pi.part_serial_no = ip_esn
     AND cpi.x_is_default = 1;

    -- CR25549 ADDED SAFELINK
  CURSOR cur_SLink (ip_esn IN VARCHAR2) IS
  SELECT lid, x_current_esn
    FROM X_SL_CURRENTVALS where x_current_esn = IP_ESN;

  -- CR25549 add a few new variables
  v_function_name        VARCHAR2 (80) := ip_caller_program || '.RESET_ESN_FUN()';
  is_acct_primary        BOOLEAN := FALSE;
  l_grp_depend_esn       VARCHAR2(20);
  rec_SLink              cur_SLink%ROWTYPE;
  rec_account_primary    cur_account_primary%ROWTYPE;
  rec_grp_dependent      cur_grp_dependent%ROWTYPE;
  rec_grp_primary        cur_grp_primary%ROWTYPE;
  rec_remov_dmucard      cur_remov_dmucard%ROWTYPE;
 rec_ph                 cur_ph%ROWTYPE;
  rec_sitepart           cur_sitepart%ROWTYPE;
  v_refurb_unrepair_date DATE;
  v_group_hist_seq       NUMBER;
  v_user_objid           NUMBER;
  return_value           BOOLEAN;
  v_completion_flag      BOOLEAN := NULL;
  do_reset               BOOLEAN := FALSE;
  v_action               VARCHAR2(100);
  v_action_type          VARCHAR2(11) := 'REFURBISHED';
  v_result               VARCHAR2(100) := '';
  ip_filename            VARCHAR2(11) := 'REFURB';
  v_count                NUMBER;
  v_update_group_objid   NUMBER;
  err_no                 VARCHAR2(100);
  err_str                VARCHAR2(100);
  v_preprocess_result    VARCHAR2(100) := NULL; -- CR21968
  v_NAE_flag   			 boolean; --CR21968
  v_act_count            NUMBER; --CR45234
  v_caller_program       VARCHAR2(100) := '.INBOUND_PHONE_OTHER_INV_PRC';

  gt       group_type := group_type(); --CR45234
  g        group_type := group_type(); --CR45234
  --
  mt       group_member_type := group_member_type(); --CR45234
  m        group_member_type := group_member_type(); --CR45234

BEGIN --OOOOOOOOOOOOOOOOOOOOOOOOO  MAIN  OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO

  OPEN cur_sitepart;

   FETCH cur_sitepart
    INTO rec_sitepart;

   OPEN cur_ph;
  FETCH cur_ph
   INTO rec_ph;

   IF cur_ph%NOTFOUND
   THEN
      CLOSE cur_ph;
      toss_util_pkg.insert_error_tab_proc
       (ip_action_type || ':No Action Taken',
          ip_esn,v_function_name,ip_action_type || ':ESN Not Found' );

      /** EXIT POINT ** PHONE WAS NOT found in table_part_inst **/
      return_value := FALSE;
      do_reset     := FALSE;

      /** AN Active record for that ESN was found on Table_site_part **/
   ELSIF cur_sitepart%FOUND
   THEN
      CLOSE cur_sitepart;

	    IF NVL(ip_action_type, 'X') <>  'REFURBISHED'
		  AND NVL(ip_caller_program, 'X') <> v_caller_program THEN --CR53568
                  -- CR21968
		    sa.NAE_Pre_Process_Prc(ip_esn  => ip_esn,
		    					   is_non_advanced_exchange => v_NAE_flag,
		    					   Proc_result => v_preprocess_result,
		    					   Proc_Error_Num => err_no,
		    					   Proc_Error_Text => err_str);

		    if (v_preprocess_result <> 'SUCCESS' )
		    then
		    				return false;
		    end if; -- CR21968
	     END IF; --CR53568


            dbms_output.put_line('ip_action_type:'||ip_action_type);
	    dbms_output.put_line('rec_sitepart.install_date:'||rec_sitepart.install_date);
	    dbms_output.put_line('ip_reset_date:'||ip_reset_date);
            dbms_output.put_line('ip_esn:'||ip_esn);
	    dbms_output.put_line('ip_caller_program:'||ip_caller_program);

      /** phone is active.  If phone is active and it needs to be marked as REPAIRED **/
      /** then skip the deactivation and reset routine and returned as a failed **/
      /** reset of a repaired phone logged exception **/
		IF       ip_action_type = 'REPAIRED' THEN
			     do_reset     := FALSE;
			     return_value := FALSE;
			     toss_util_pkg.insert_error_tab_proc ('ESN Is Active And Could Not Be Reset',
													  ip_esn,
													  v_function_name,
													  ip_action_type || ':Failed Reseting ESN(Active)');

			--CR37159 and CR36364
			/*
			The Posa returned / refurbished were not creating a data in the TABLE_X_CALL_TRANS, In above code,
			the NAE_Pre_Process_Prc is returns v_NAE_flag is TRUE for refurbished action types, if it is true
            the service deactivation process not happening. So the below code is added for the ip_action_type is
            Refurbished	and POSA returns.
			*/

		ELSIF  ip_action_type = 'REFURBISHED' AND
		       rec_sitepart.install_date < ip_reset_date AND ip_reset_date IS NOT NULL THEN

				service_deactivation.deactivate_any (ip_esn,ip_action_type,v_function_name,v_completion_flag );

					 /* no errors return while deactivating (sucess) */
					IF v_completion_flag = TRUE
					THEN
					   /** proceed and do reset routines **/
					   do_reset     := TRUE;
					   return_value := TRUE;
					ELSE
					   /** errors encountered while deactivating ( deactivated already **/
					   /** logged error inside the package skip resetting routine **/
					   do_reset     := FALSE;
					   return_value := FALSE;
					END IF;  --END R37159 and CR36364

		ELSE
			IF  ( v_NAE_flag) -- CR21968
                            AND NVL(ip_caller_program, 'X') <> v_caller_program 	then  --CR53568

					update table_site_part
					   set  part_status = 'Inactive'
					 where objid = rec_sitepart.objid;

					dbms_output.put_line('table_site_part row updated and row count:'||SQL%ROWCOUNT);
					dbms_output.put_line('rec_sitepart.objid :'||rec_sitepart.objid);

					  do_reset     := TRUE;
					  return_value := TRUE; -- CR21968

			ELSIF ( rec_sitepart.install_date < ip_reset_date AND ip_reset_date IS NOT NULL ) THEN
				service_deactivation.deactivate_any (ip_esn,ip_action_type,v_function_name,v_completion_flag );

						 /* no errors return while deactivating (sucess) */
						IF v_completion_flag = TRUE
						THEN
						   /** proceed and do reset routines **/
						   do_reset     := TRUE;
						   return_value := TRUE;
						ELSE
						   /** errors encountered while deactivating ( deactivated already **/
						   /** logged error inside the package skip resetting routine **/
						   do_reset     := FALSE;
						   return_value := FALSE;
						END IF;
			END IF; --CR 53568
		END IF;  /** of REPAIRED check **/
		  /** NO active record associated with the esn was found on table_site_part **/
		  /** let's reset it **/
	ELSE
		  return_value := TRUE;
		  do_reset := TRUE;
	END IF;
   /** Reset routine **/
   IF do_reset
   THEN
      /* CR25549 - Alerts */
      UPDATE table_alert SET end_date = SYSDATE WHERE alert2contract = rec_ph.objid;
      COMMIT ;
      /* CR25549 - Autopay */
      DELETE FROM table_x_autopay_details WHERE x_autopay_details2site_part = rec_sitepart.objid;
      COMMIT ;
      /* CR3164: Delete records used in "MyAccount" */
      DELETE FROM table_x_contact_part_inst WHERE x_contact_part_inst2part_inst = rec_ph.objid;

    --  CR38580:  Remove ESN from My Account After Return (Iphone 6S)
    -- remove attachment to the previous web accounts
    delete
    from   table_x_contact_part_inst
    where  x_contact_part_inst2part_inst in ( select objid
                                              FROM   table_part_inst
                                              where  part_serial_no = ip_esn);



      COMMIT ;

      IF ip_action_type = 'REFURBISHED'
      THEN
       v_action := ip_action_type || ':Update Table_Part_Inst';

       UPDATE table_part_inst
          SET x_part_inst_status = ip_initial_pi_status,
              status2x_code_table =
                (SELECT objid FROM table_x_code_table
                 WHERE x_code_number = ip_initial_pi_status),
              x_creation_date = NVL (ip_ship_date, x_creation_date),
              x_order_number = NVL (ip_order_num, x_order_number),
              created_by2user = NVL (ip_user_objid, created_by2user),
              last_pi_date = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
              last_cycle_ct = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
              next_cycle_ct = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
              last_mod_time = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
              last_trans_time = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
              date_in_serv = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
              repair_date = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
              n_part_inst2part_mod = NVL (ip_mod_objid, n_part_inst2part_mod),
              part_inst2inv_bin = NVL (ip_bin_objid, part_inst2inv_bin),
              x_part_inst2site_part = NULL,
              x_reactivation_flag = 0,
              warr_end_date = NULL,
              x_clear_tank = 0,
              x_part_inst2contact = NULL,
              part_inst2x_pers = NULL,
              part_inst2x_new_pers = NULL,
              x_iccid = null,
              part_bad_qty = CASE when ip_initial_pi_status = '150'
                                  then 0 else part_bad_qty
                                   end
        WHERE x_domain = 'PHONES' AND part_serial_no = ip_esn;

			-- expire the new account group member by esn
			m := mt.expire ( i_esn => ip_esn ); ----CR45234

  BEGIN
 SELECT COUNT (*)
   INTO v_act_count
   FROM x_account_group_member
  WHERE account_group_id = m.group_objid
    AND STATUS ='ACTIVE';
EXCEPTION
WHEN OTHERS THEN
v_act_count:=0;
END;

 IF NVL(v_act_count,0)=0 THEN
			-- expire the new account group by group objid (based on the old esn)
			g := gt.expire ( i_group_objid => m.group_objid );  ----CR45234
END IF;
        /* CR29489 changes starts  */
        IF ip_initial_pi_status = '150' THEN
          declare
            lv_return integer;
          begin
            lv_return  := sa.DEVICE_UTIL_PKG.F_REMOVE_REAL_ESN_LINK(ip_esn);
            dbms_output.put_line('ESN ='|| ip_esn || ' relation removed ');
          end;
        END IF;
        /* CR29489 changes ends  */
        COMMIT ;

         v_action := ip_action_type || ':Update Table_Site_Part';

       -- Remove links between lines or pins with ESN
       UPDATE table_part_inst
          SET part_to_esn2part_inst = NULL
        WHERE part_to_esn2part_inst in
         (select objid from table_part_inst where part_serial_no = ip_esn and x_domain = 'PHONES');
       COMMIT;
       -- Remove Pending Units
       DELETE FROM table_x_pending_redemption
       WHERE pend_redemption2esn in
         (select objid from table_part_inst
           where part_serial_no = ip_esn
             and x_domain = 'PHONES');
       COMMIT;
       -- CR25549 added this JIC the above delete not remove all
       DELETE FROM table_x_pending_redemption
        WHERE x_pend_red2site_part = rec_sitepart.objid;
       COMMIT ;
       -- Close all pending cases and Remove Relations
       FOR rec_case in cur_cases loop
          CLARIFY_CASE_PKG.CLOSE_CASE (rec_case.objid,ip_user_objid,null,null,null,err_no,err_str);
       END loop;
       -- Remove Relations to Cases
       UPDATE table_case set x_esn = x_esn||'R' WHERE x_esn = ip_esn;
       COMMIT;
       -- Reset ild Features
      /* CR25549 - OTA Feature Phone Reset Change this from RESET to DELETE*/
      -- UPDATE table_x_ota_features set x_ild_carr_status = 'Inactive' where x_ota_features2part_inst
      -- IN (select objid from table_part_inst where part_serial_no = ip_esn and x_domain = 'PHONES');
      DELETE FROM table_x_ota_features  WHERE x_ota_features2part_inst = rec_ph.objid;
      COMMIT;
      UPDATE table_site_part  SET x_refurb_flag = 1 WHERE x_service_id = ip_esn;
      v_action := ip_action_type || ':Insert Table_X_Pi_Hist';

      IF toss_util_pkg.insert_pi_hist_fun (ip_esn,'PHONES',ip_action_type,v_function_name )
      THEN
        NULL;
      END IF;

     -- v_action := ip_action_type || ':Reset of Double Mintue Upgrade phone to a Regular phone';
     /* CR25549 - Reset all  group promos */
     v_action := ip_action_type || ':Reset All Group promos';

     FOR rec_remov_dmucard IN cur_remov_dmucard (rec_ph.objid)
     LOOP
         sp_seq ('x_group_hist', v_group_hist_seq);
         INSERT INTO table_x_group_hist
            (objid,x_start_date,x_end_date,
             x_action_date,x_action_type,x_annual_plan,
             grouphist2part_inst,grouphist2x_promo_group )
          VALUES
            (v_group_hist_seq,rec_remov_dmucard.x_start_date,rec_remov_dmucard.x_end_date,
             SYSDATE,'REMOVE',rec_remov_dmucard.x_annual_plan,
             rec_remov_dmucard.groupesn2part_inst,rec_remov_dmucard.groupesn2x_promo_group );
          DELETE FROM table_x_group2esn WHERE objid = rec_remov_dmucard.objid;
      END LOOP;
      COMMIT ;

      /* REFURB_WITH_SEQ CR7167 */
      ----------- BILLING
      /* CR25549 - X_Program_Enrolled  */
      FOR rec_grp_primary IN cur_grp_primary(rec_ph.part_serial_no) LOOP
         dbms_output.put_line('gonna insert rec_grp_primary' || rec_grp_primary.x_esn);

         INSERT INTO x_program_trans
            (objid ,x_enrollment_status,x_enroll_status_reason ,x_trans_date
            ,x_action_text ,x_action_type,x_reason ,x_sourcesystem
            ,x_esn ,x_exp_date,x_cooling_exp_date ,x_update_status
            ,x_update_user ,pgm_tran2pgm_entrolled,pgm_trans2web_user)
         VALUES
            (billing_seq('X_PROGRAM_TRANS'),'DEENROLLED','Refurbished',SYSDATE
            ,'Refurbish DeEnrollment' ,'DE_ENROLL','Reset_ESN_Fun' ,rec_grp_primary.x_sourcesystem
            ,rec_grp_primary.x_esn,SYSDATE,SYSDATE ,'I'
            ,'RESET_ESN_FUN' ,rec_grp_primary.objid,rec_grp_primary.pgm_enroll2web_user);

            COMMIT;
            dbms_output.put_line('Insert x_billing log' || rec_ph.part_serial_no);

          INSERT INTO x_billing_log
            (objid,x_log_category,x_log_title,x_log_date
            ,x_details,
            x_nickname,x_esn,x_originator,
            x_agent_name,x_sourcesystem,billing_log2web_user)
          VALUES
            (billing_seq('X_BILLING_LOG') ,'Program','Reset_ESN_Fun',SYSDATE
            ,(SELECT x_program_name
                FROM x_program_parameters
               WHERE objid = rec_grp_primary.pgm_enroll2pgm_parameter) || '    - Refurbished'
            ,billing_getnickname(rec_grp_primary.x_esn),rec_grp_primary.x_esn,'System',
            'System',rec_grp_primary.x_sourcesystem,rec_grp_primary.pgm_enroll2web_user);
          COMMIT;
          v_count := 1;

          FOR rec_grp_dependent IN cur_grp_dependent(rec_ph.part_serial_no) LOOP
            IF v_count = 1 THEN
              dbms_output.put_line('rec_grp_dependent' || rec_ph.part_serial_no);
              v_update_group_objid := rec_grp_dependent.objid;

              -- CR25549 added x_payment_type
              UPDATE x_program_enrolled
                 SET x_is_grp_primary      = 1
                    ,x_enrollment_status   = 'SUSPENDED'
                    ,x_reason              = rec_grp_primary.x_esn || '-Refurbished need pmt info'
                    ,pgm_enroll2pgm_group  = NULL
                    ,x_wait_exp_date       = SYSDATE + 30
                    ,pgm_enroll2x_pymt_src = NULL
                    ,x_amount              = rec_grp_primary.x_amount
                    ,x_charge_date         = rec_grp_primary.x_charge_date
                    ,x_next_charge_date    = rec_grp_primary.x_next_charge_date
                    ,x_payment_type        = 'PENDING_FS'
                WHERE objid = rec_grp_dependent.objid;
            COMMIT ;
            l_grp_depend_esn := rec_grp_dependent.x_esn;

            INSERT INTO x_billing_log
            (objid ,x_log_category
            ,x_log_title ,x_log_date
            ,x_details
            ,x_nickname
            ,x_esn ,x_originator
            ,x_agent_name ,x_sourcesystem
            ,billing_log2web_user)
          VALUES
            (billing_seq('X_BILLING_LOG') ,'Program'
            ,'Assign Dependent to be Primary of F V P' ,SYSDATE
            ,(SELECT x_program_name FROM x_program_parameters
               WHERE objid = rec_grp_dependent.pgm_enroll2pgm_parameter) || '    - Refurbished'
            ,billing_getnickname(rec_grp_dependent.x_esn)
            ,rec_grp_dependent.x_esn ,'System'
            ,'System' ,rec_grp_dependent.x_sourcesystem
            ,rec_grp_dependent.pgm_enroll2web_user);
          COMMIT;
        ELSE
          UPDATE x_program_enrolled
            SET x_enrollment_status   = 'SUSPENDED'
                ,x_reason              = rec_grp_primary.x_esn || '-Refurbished need pmt info'
                ,pgm_enroll2pgm_group  = v_update_group_objid
                ,x_wait_exp_date       = SYSDATE + 30
                ,pgm_enroll2x_pymt_src = NULL
           WHERE objid = rec_grp_dependent.objid;
        END IF;
        COMMIT;
        v_count := v_count + 1;

      END LOOP;
    END LOOP;
    COMMIT;

    /* CR25549 - X_Program_Enrolled  */
    FOR rec_account_primary IN cur_account_primary(rec_ph.part_serial_no) LOOP
      is_acct_primary := TRUE;

      INSERT INTO x_program_trans
        (objid,x_enrollment_status,x_enroll_status_reason
        ,x_trans_date,x_action_text,x_action_type
        ,x_reason,x_sourcesystem,x_esn
        ,x_exp_date,x_cooling_exp_date,x_update_status
        ,x_update_user,pgm_tran2pgm_entrolled,pgm_trans2web_user)
      VALUES
        (billing_seq('X_PROGRAM_TRANS'),'DEENROLLED','Refurbished'
        ,SYSDATE,'Refurbish DeEnrollment','DE_ENROLL'
        ,'Sp_Clarify_Refurb_Prc.',rec_account_primary.x_sourcesystem,rec_account_primary.x_esn
        ,SYSDATE,SYSDATE,'I'
        ,'SYSTEM',rec_account_primary.objid,rec_account_primary.pgm_enroll2web_user);
      COMMIT;

      INSERT INTO x_billing_log
        (objid,x_log_category,x_log_title,x_log_date
        ,x_details
        ,x_nickname,x_esn
        ,x_originator,x_agent_name,x_sourcesystem,billing_log2web_user)
      VALUES
        (billing_seq('X_BILLING_LOG'),'Program','Refurbished',SYSDATE
        ,(SELECT x_program_name
            FROM x_program_parameters
           WHERE objid = rec_account_primary.pgm_enroll2pgm_parameter) || '    - Refurbished'
        ,billing_getnickname(rec_account_primary.x_esn),rec_account_primary.x_esn
        ,'System','System',rec_account_primary.x_sourcesystem,rec_account_primary.pgm_enroll2web_user);
      COMMIT;
    END LOOP;
    COMMIT;

    /* CR25549 - X_Program_Enrolled  */
    UPDATE x_program_enrolled
       SET x_is_grp_primary      = 0
          ,x_enrollment_status   = 'DEENROLLED'
          ,x_reason              = 'Refurbished phone'
          ,pgm_enroll2x_pymt_src = NULL
     WHERE x_esn = ip_esn;

    /* CR3164: Delete records used in "MyAccount" CR6870 - move this delete to last from first */
    Delete from table_x_contact_part_inst
     Where x_contact_part_inst2part_inst = rec_ph.objid;
    commit ;
      -- CR25549 do it third TIME
      DELETE FROM table_x_contact_part_inst WHERE x_contact_part_inst2part_inst in
      (select objid from table_part_inst where part_serial_no = IP_ESN );
      COMMIT ;

  -----  CR28598 adasgupta             start ----
  -----  Delete from table_web_user where login_name like ip_esn||'%';

         UPDATE table_web_user
         SET login_name   = objid|| '-' ||login_name ,
             s_login_name = objid|| '-' ||s_login_name
         WHERE login_name LIKE ip_esn||'@%';

         COMMIT ;
   ----- -----  CR28598 adasgupta  end ----

    dbms_output.put_line('Deleted from web_user as well');

    IF is_acct_primary THEN
      UPDATE table_x_contact_part_inst
         SET x_is_default = 1
       WHERE x_is_default = 0
         AND x_contact_part_inst2part_inst =
          (SELECT objid FROM table_part_inst
            WHERE part_serial_no = l_grp_depend_esn
              AND x_part_inst_status || '' = '52');
    END IF;
    COMMIT;

    -- CR25549 insert record in X_SL_HIST and a trigger will expire it in X_SL_CURVALS
    FOR rec_SLink IN cur_SLink(ip_esn) LOOP
      insert into X_SL_HIST
        (OBJID, LID, X_ESN,
          X_EVENT_DT, X_INSERT_DT, X_EVENT_VALUE,
            X_EVENT_CODE, USERNAME, X_SOURCESYSTEM)
      values
        (sa.SEQ_X_SL_HIST.nextval, rec_SLink.LID, '-1',
          sysdate, sysdate, 'Enrollment Esn Assignment - Refurbished',
          700, 'REFURB', 'CLARIFY');
      commit;
    END LOOP;

    /* CR25549 - X_Program_Enrolled  END */
    -- BILLING END, BILLING IS ALL NEW FOR CR25549

   /*CR32367 VS:052215: Inserting a flag record to notify point genereration
    program of the refurbish event on the ESN*/
    BEGIN
     insert into table_x_point_trans (
                            objid,
                            x_trans_date,
                            x_min,
                            x_esn,
                            x_points,
                            x_points_category,
                            x_points_action,
                            points_action_reason,
                            point_trans2ref_table_objid,
                            ref_table_name,
                            point_trans2service_plan,
                            point_trans2point_account,
                            point_trans2purchase_objid,
                            purchase_table_name,
                            point_trans2site_part
                            )
                          values
                            (sa.seq_x_point_trans.nextval,
                             sysdate,
                             null,
                             ip_esn,
                             0,
                             'REWARD_POINTS',
                             'REFURB',
                             ' A refurbish event occured on the ESN on: '||ip_reset_date,
                             null, --point_trans2ref_table_objid
                             null, --ref_table_name
                             null, --point_trans2service_plan
                             null, --point_trans2point_account
                             null, --point_trans2purchase_objid
                             null, --purchase_table_name
                             null  --point_trans2site_part
                            );
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        sa.ota_util_pkg.err_log ( p_action => 'Refurb flag point rec insert',
                                  p_error_date => sysdate,
                                  p_key => NULL,
                                  p_program_name => 'sp_clarify_refurb_prc',
                                  p_error_text => 'ip_esn='||ip_esn ||'Refurb point insert failed with issue'
                                                                    ||', ERR='|| SUBSTR(sqlerrm, 1, 4000)
                                  );

        END ;
    /*********CR32367 changes end here ******/

    -----------------------------------
    -- Not sure what the difference is for a REFURB_WITH_SEQ vs ip_action_type = 'REFURBISHED',
    -- all except for the TABLE_PART_INST which is slightly different
ELSIF ip_action_type = 'REFURB_WITH_SEQ'
      THEN
        v_action := ip_action_type || ':Update Table_Part_Inst';
         UPDATE table_part_inst
            SET x_part_inst_status = ip_initial_pi_status,
                status2x_code_table = (SELECT objid FROM table_x_code_table
                      WHERE x_code_number = ip_initial_pi_status),
                x_creation_date = NVL (ip_ship_date, x_creation_date),
                x_order_number = NVL (ip_order_num, x_order_number),
                created_by2user = NVL (ip_user_objid, created_by2user),
                last_pi_date = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                last_cycle_ct = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                next_cycle_ct = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                last_mod_time = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                last_trans_time = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                date_in_serv = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                repair_date = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                n_part_inst2part_mod = NVL (ip_mod_objid, n_part_inst2part_mod),
                part_inst2inv_bin = NVL (ip_bin_objid, part_inst2inv_bin),
                x_part_inst2site_part = NULL,
                x_reactivation_flag = 0,
                warr_end_date = NULL,
                x_clear_tank = 0,
                x_part_inst2contact = NULL,
                part_inst2x_pers = NULL,
                part_inst2x_new_pers = NULL,
                x_iccid = null, --CR6731
                X_SEQUENCE =0 ---CR7167
          WHERE x_domain = 'PHONES' AND part_serial_no = ip_esn;
          /* CR29489 changes starts  */
          IF ip_initial_pi_status = '150' THEN
            declare
              lv_return integer;
            begin
              lv_return  := sa.DEVICE_UTIL_PKG.F_REMOVE_REAL_ESN_LINK(ip_esn);
              dbms_output.put_line('ESN ='|| ip_esn || ' relation removed ');
            end;
          END IF;
        /* CR29489 changes ends  */
          COMMIT ;
         v_action := ip_action_type || ':Update Table_Site_Part';

       -- Remove links between lines or pins with ESN
       UPDATE table_part_inst
       SET part_to_esn2part_inst = NULL
       WHERE part_to_esn2part_inst in
         (select objid from table_part_inst
           where part_serial_no = ip_esn
             and x_domain = 'PHONES');
       COMMIT;

       -- Remove Pending Units
       DELETE FROM table_x_pending_redemption
       WHERE pend_redemption2esn in
         (select objid from table_part_inst
           where part_serial_no = ip_esn
             and x_domain = 'PHONES');
       COMMIT;

       -- CR25549 added this JIC the above delete not remove all
       DELETE FROM table_x_pending_redemption
       WHERE x_pend_red2site_part = rec_sitepart.objid;
       COMMIT ;
       -- Close all pending cases and Remove Relations
       FOR rec_case in cur_cases loop
          CLARIFY_CASE_PKG.CLOSE_CASE (rec_case.objid,ip_user_objid,null,null,null,err_no,err_str);
       END loop;
       -- Remove Relations to Cases
       UPDATE table_case set x_esn = x_esn||'R'  where x_esn = ip_esn;
       COMMIT;
       -- Reset ild Features
      /* CR25549 - OTA Feature Phone Reset Change this from RESET to DELETE*/
      -- UPDATE table_x_ota_featuresset x_ild_carr_status = 'Inactive' where x_ota_features2part_inst
      -- IN (select objid from table_part_inst where part_serial_no = ip_esn and x_domain = 'PHONES');
      DELETE FROM table_x_ota_features  WHERE x_ota_features2part_inst = rec_ph.objid;
      COMMIT;
      UPDATE table_site_part
         SET x_refurb_flag = 1
       WHERE x_service_id = ip_esn;
      v_action := ip_action_type || ':Insert Table_X_Pi_Hist';
      COMMIT ;
      IF toss_util_pkg.insert_pi_hist_fun (ip_esn,'PHONES',ip_action_type,v_function_name )
      THEN
        NULL;
      END IF;

      -- v_action := ip_action_type || ':Reset of Double Mintue Upgrade phone to a Regular phone';
      /* CR25549 - Reset all  group promos */
      v_action := ip_action_type || ':Reset All Group promos';

      FOR rec_remov_dmucard IN cur_remov_dmucard (rec_ph.objid)
      LOOP
         sp_seq ('x_group_hist', v_group_hist_seq);
         INSERT INTO table_x_group_hist
            (objid,x_start_date,x_end_date,
             x_action_date,x_action_type,x_annual_plan,
             grouphist2part_inst,grouphist2x_promo_group )
          VALUES (v_group_hist_seq,rec_remov_dmucard.x_start_date,rec_remov_dmucard.x_end_date,
                  SYSDATE,'REMOVE',rec_remov_dmucard.x_annual_plan,
                   rec_remov_dmucard.groupesn2part_inst,rec_remov_dmucard.groupesn2x_promo_group );
          COMMIT ;
           DELETE FROM table_x_group2esn WHERE objid = rec_remov_dmucard.objid;
           COMMIT ;
        END LOOP;

        /* CR25549 - X_Program_Enrolled  */
        FOR rec_grp_primary IN cur_grp_primary(rec_ph.part_serial_no) LOOP
          dbms_output.put_line('gonna insert rec_grp_primary' || rec_grp_primary.x_esn);

          INSERT INTO x_program_trans
            (objid ,x_enrollment_status,x_enroll_status_reason ,x_trans_date
            ,x_action_text ,x_action_type,x_reason ,x_sourcesystem
            ,x_esn ,x_exp_date,x_cooling_exp_date ,x_update_status
            ,x_update_user ,pgm_tran2pgm_entrolled,pgm_trans2web_user)
          VALUES
            (billing_seq('X_PROGRAM_TRANS'),'DEENROLLED','Refurbished',SYSDATE
            ,'Refurbish DeEnrollment' ,'DE_ENROLL','Reset_ESN_Fun' ,rec_grp_primary.x_sourcesystem
            ,rec_grp_primary.x_esn,SYSDATE,SYSDATE ,'I'
            ,'RESET_ESN_FUN' ,rec_grp_primary.objid,rec_grp_primary.pgm_enroll2web_user);
            COMMIT;
            dbms_output.put_line('Insert x_billing log' || rec_ph.part_serial_no);
          INSERT INTO x_billing_log
            (objid,x_log_category,x_log_title,x_log_date
            ,x_details,
            x_nickname,x_esn,x_originator,
            x_agent_name,x_sourcesystem,billing_log2web_user)
          VALUES
            (billing_seq('X_BILLING_LOG') ,'Program','Reset_ESN_Fun',SYSDATE
            ,(SELECT x_program_name
                FROM x_program_parameters
               WHERE objid = rec_grp_primary.pgm_enroll2pgm_parameter) || '    - Refurbished'
            ,billing_getnickname(rec_grp_primary.x_esn),rec_grp_primary.x_esn,'System',
            'System',rec_grp_primary.x_sourcesystem,rec_grp_primary.pgm_enroll2web_user);
          COMMIT;
          v_count := 1;

          FOR rec_grp_dependent IN cur_grp_dependent(rec_ph.part_serial_no) LOOP
            IF v_count = 1 THEN
              dbms_output.put_line('rec_grp_dependent' || rec_ph.part_serial_no);
              v_update_group_objid := rec_grp_dependent.objid;
              -- CR25549 added x_payment_type

                UPDATE x_program_enrolled
                   SET x_is_grp_primary      = 1
                      ,x_enrollment_status   = 'SUSPENDED'
                      ,x_reason              = rec_grp_primary.x_esn || '-Refurbished need pmt info'
                      ,pgm_enroll2pgm_group  = NULL
                      ,x_wait_exp_date       = SYSDATE + 30
                      ,pgm_enroll2x_pymt_src = NULL
                      ,x_amount              = rec_grp_primary.x_amount
                      ,x_charge_date         = rec_grp_primary.x_charge_date
                      ,x_next_charge_date    = rec_grp_primary.x_next_charge_date
                      ,x_payment_type        = 'PENDING_FS'
                  WHERE objid = rec_grp_dependent.objid;
              COMMIT ;
              l_grp_depend_esn := rec_grp_dependent.x_esn;

          INSERT INTO x_billing_log
            (objid ,x_log_category            ,x_log_title ,x_log_date
            ,x_details
            ,x_nickname
            ,x_esn ,x_originator
            ,x_agent_name ,x_sourcesystem
            ,billing_log2web_user)
          VALUES
            (billing_seq('X_BILLING_LOG') ,'Program'
            ,'Assign Dependent to be Primary of F V P' ,SYSDATE
            ,(SELECT x_program_name
                FROM x_program_parameters
               WHERE objid = rec_grp_dependent.pgm_enroll2pgm_parameter) || '    - Refurbished'
            ,billing_getnickname(rec_grp_dependent.x_esn)
            ,rec_grp_dependent.x_esn ,'System'
            ,'System' ,rec_grp_dependent.x_sourcesystem
            ,rec_grp_dependent.pgm_enroll2web_user);
          COMMIT;
        ELSE
          UPDATE x_program_enrolled
             SET x_enrollment_status   = 'SUSPENDED'
                ,x_reason              = rec_grp_primary.x_esn || '-Refurbished need pmt info'
                ,pgm_enroll2pgm_group  = v_update_group_objid
                ,x_wait_exp_date       = SYSDATE + 30
                ,pgm_enroll2x_pymt_src = NULL
           WHERE objid = rec_grp_dependent.objid;
           COMMIT;
        END IF;

        v_count := v_count + 1;
      END LOOP;
    END LOOP;


    /* CR25549 - X_Program_Enrolled  */
    FOR rec_account_primary IN cur_account_primary(rec_ph.part_serial_no) LOOP
      is_acct_primary := TRUE;

      INSERT INTO x_program_trans
        (objid,x_enrollment_status,x_enroll_status_reason
        ,x_trans_date,x_action_text,x_action_type
        ,x_reason,x_sourcesystem,x_esn
        ,x_exp_date,x_cooling_exp_date,x_update_status
        ,x_update_user,pgm_tran2pgm_entrolled,pgm_trans2web_user)
      VALUES
        (billing_seq('X_PROGRAM_TRANS'),'DEENROLLED','Refurbished'
        ,SYSDATE,'Refurbish DeEnrollment','DE_ENROLL'
        ,'Sp_Clarify_Refurb_Prc.',rec_account_primary.x_sourcesystem,rec_account_primary.x_esn
        ,SYSDATE,SYSDATE,'I'
        ,'SYSTEM',rec_account_primary.objid,rec_account_primary.pgm_enroll2web_user);

      COMMIT;

      INSERT INTO x_billing_log
        (objid,x_log_category,x_log_title,x_log_date
       ,x_details
        ,x_nickname,x_esn
        ,x_originator,x_agent_name,x_sourcesystem,billing_log2web_user)
      VALUES
        (billing_seq('X_BILLING_LOG'),'Program','Refurbished',SYSDATE
        ,(SELECT x_program_name
            FROM x_program_parameters
           WHERE objid = rec_account_primary.pgm_enroll2pgm_parameter) || '    - Refurbished'
        ,billing_getnickname(rec_account_primary.x_esn),rec_account_primary.x_esn
        ,'System','System',rec_account_primary.x_sourcesystem,rec_account_primary.pgm_enroll2web_user);

      COMMIT;
    END LOOP;

    /* CR25549 - X_Program_Enrolled  */
    UPDATE x_program_enrolled
       SET x_is_grp_primary      = 0
          ,x_enrollment_status   = 'DEENROLLED'
          ,x_reason              = 'Refurbished phone'
          ,pgm_enroll2x_pymt_src = NULL
     WHERE x_esn = ip_esn;
     COMMIT ;
    /* CR3164: Delete records used in "MyAccount" CR6870 - move this delete to last from first */
    DELETE FROM table_x_contact_part_inst
     WHERE x_contact_part_inst2part_inst = rec_ph.objid;

    commit ;

    -- CR25549 do it third TIME
    DELETE FROM table_x_contact_part_inst
     WHERE x_contact_part_inst2part_inst in
      (select objid from table_part_inst where part_serial_no = IP_ESN );
    COMMIT ;

     -----  CR28598 adasgupta          start ----
     -----  Delete from table_web_user where login_name like ip_esn||'%';

         UPDATE table_web_user
         SET login_name   = objid|| '-' ||login_name ,
             s_login_name = objid|| '-' ||s_login_name
         WHERE login_name LIKE ip_esn||'@%';

         COMMIT ;
    -----  CR28598 adasgupta           end ----

    dbms_output.put_line('Deleted from web_user as well');

    IF is_acct_primary THEN
      UPDATE table_x_contact_part_inst
         SET x_is_default = 1
       WHERE x_is_default = 0
         AND x_contact_part_inst2part_inst =
          (SELECT objid FROM table_part_inst
            WHERE part_serial_no = l_grp_depend_esn
              AND x_part_inst_status || '' = '52');
    END IF;
    COMMIT;

    -- CR25549 insert record in X_SL_HIST and a trigger will expire it in X_SL_CURVALS
    FOR rec_SLink IN cur_SLink(ip_esn) LOOP
      insert into X_SL_HIST
        (OBJID, LID, X_ESN,
          X_EVENT_DT, X_INSERT_DT, X_EVENT_VALUE,
            X_EVENT_CODE, USERNAME, X_SOURCESYSTEM)
      values
        (sa.SEQ_X_SL_HIST.nextval, rec_SLink.LID, '-1',
          sysdate, sysdate, 'Enrollment Esn Assignment - Refurbished',
          700, 'REFURB', 'CLARIFY');
      commit;
    END LOOP;

    /*CR32367 VS:052215: Inserting a flag record to notify point genereration
    program of the refurbish event on the ESN*/
    BEGIN
     insert into table_x_point_trans (
                            objid,
                            x_trans_date,
                            x_min,
                            x_esn,
                            x_points,
                            x_points_category,
                            x_points_action,
                            points_action_reason,
                            point_trans2ref_table_objid,
                            ref_table_name,
                            point_trans2service_plan,
                            point_trans2point_account,
                            point_trans2purchase_objid,
                            purchase_table_name,
                            point_trans2site_part
                            )
                          values
                            (sa.seq_x_point_trans.nextval,
                             sysdate,
                             null,
                             ip_esn,
                             0,
                             'REWARD_POINTS',
                             'REFURB',
                             ' A refurbish event occured on the ESN on: '||ip_reset_date,
                             null, --point_trans2ref_table_objid
                             null, --ref_table_name
                             null, --point_trans2service_plan
                             null, --point_trans2point_account
                             null, --point_trans2purchase_objid
                             null, --purchase_table_name
                             null  --point_trans2site_part
                            );
        COMMIT;
        EXCEPTION
        WHEN OTHERS THEN
        sa.ota_util_pkg.err_log ( p_action => 'Refurb flag point rec insert',
                                  p_error_date => sysdate,
                                  p_key => NULL,
                                  p_program_name => 'sp_clarify_refurb_prc',
                                  p_error_text => 'ip_esn='||ip_esn ||'Refurb point insert failed with issue'
                                                                    ||', ERR='|| SUBSTR(sqlerrm, 1, 4000)
                                  );

        END ;
    /*********CR32367 changes end here ******/
      /* END REFURB_WITH_SEQ CR7167 */
      /** unrepairable **/
      ELSIF ip_action_type = 'UNREPAIRABLE'
      THEN
         v_action := ip_action_type || ':Update Table_Part_Inst';

         UPDATE table_part_inst
            SET x_part_inst_status = ip_initial_pi_status,
                status2x_code_table =
                  (SELECT objid FROM table_x_code_table WHERE x_code_number = ip_initial_pi_status),
                x_creation_date = NVL (ip_ship_date, x_creation_date),
                x_order_number = NVL (ip_order_num, x_order_number),
                created_by2user = NVL (ip_user_objid, created_by2user),
                last_pi_date = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
               last_cycle_ct = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                next_cycle_ct = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                last_mod_time = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                last_trans_time = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                date_in_serv = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                repair_date = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                n_part_inst2part_mod = NVL (ip_mod_objid, n_part_inst2part_mod),
                part_inst2inv_bin = NVL (ip_bin_objid, part_inst2inv_bin),
                x_reactivation_flag = 0,
                warr_end_date = NULL,
                x_part_inst2site_part = NULL,
                x_clear_tank = 0,
                x_part_inst2contact = NULL,
                part_inst2x_pers = NULL,
                part_inst2x_new_pers = NULL,
                x_iccid = null
          WHERE x_domain = 'PHONES' AND part_serial_no = ip_esn;

        /* CR29489 changes starts  */
        IF ip_initial_pi_status = '150' THEN
          declare
            lv_return integer;
          begin
            lv_return  := sa.DEVICE_UTIL_PKG.F_REMOVE_REAL_ESN_LINK(ip_esn);
            dbms_output.put_line('ESN ='|| ip_esn || ' relation removed ');
          end;
        END IF;
        /* CR29489 changes ends  */

         /** should move these two to an internal function **/
         v_action := ip_action_type || ':Update Table_Site_Part';

        UPDATE table_site_part
           SET x_refurb_flag = 1 WHERE x_service_id = ip_esn;
        v_action := 'Unrepairable:Insert Table_X_Pi_Hist';
        IF toss_util_pkg.insert_pi_hist_fun (ip_esn,'PHONES',ip_action_type,v_function_name)
        THEN
           NULL;
        END IF;

      /* REPAIRED **/
      ELSIF ip_action_type = 'REPAIRED'
      THEN
         v_action := ip_action_type || ':Update Table_Part_Inst';
         /** should move  this to  toss_util_pkg **/
         UPDATE table_part_inst
            SET x_part_inst_status = ip_initial_pi_status,
                status2x_code_table =
               (SELECT objid FROM table_x_code_table WHERE x_code_number = ip_initial_pi_status),
                x_creation_date = NVL (ip_ship_date, x_creation_date),
                x_order_number = NVL (ip_order_num, x_order_number),
                created_by2user = NVL (ip_user_objid, created_by2user),
                last_pi_date = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                last_cycle_ct = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                next_cycle_ct = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                last_mod_time = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                last_trans_time = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                date_in_serv = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                repair_date = TO_DATE ('01-01-1753', 'DD-MM-YYYY'),
                n_part_inst2part_mod = NVL (ip_mod_objid, n_part_inst2part_mod),
                part_inst2inv_bin = NVL (ip_bin_objid, part_inst2inv_bin),
                x_reactivation_flag = 0,
                warr_end_date = NULL,
                x_part_inst2site_part = NULL,
                x_clear_tank = 0,
                x_part_inst2contact = NULL,
                x_iccid = null
          WHERE x_domain = 'PHONES' AND part_serial_no = ip_esn;

        /* CR29489 changes starts  */
        IF ip_initial_pi_status = '150' THEN
          declare
            lv_return integer;
          begin
            lv_return  := sa.DEVICE_UTIL_PKG.F_REMOVE_REAL_ESN_LINK(ip_esn);
            dbms_output.put_line('ESN ='|| ip_esn || ' relation removed ');
          end;
        END IF;
        /* CR29489 changes ends */

         v_action := ip_action_type || ':Insert Table_X_Pi_Hist';
         IF toss_util_pkg.insert_pi_hist_fun
          (ip_esn,'PHONES',ip_action_type,v_function_name)
         THEN
            NULL;
         END IF;
      END IF;
   END IF;         -- of do_reset

   IF cur_SLINK%ISOPEN
   THEN
      CLOSE cur_SLINK;
   END IF;
   IF cur_sitepart%ISOPEN
   THEN
      CLOSE cur_sitepart;
   END IF;
   IF cur_ph%ISOPEN
   THEN
      CLOSE cur_ph;
   END IF;
-- CR25549 NEW ADDITIONS
   IF cur_cases%ISOPEN
   THEN
      CLOSE cur_cases;
   END IF;
   IF cur_remov_dmucard%ISOPEN
   THEN
       CLOSE cur_remov_dmucard;
   END IF ;
   IF cur_grp_primary%ISOPEN
   THEN
       CLOSE cur_grp_primary;
   END IF ;
   IF cur_grp_dependent%ISOPEN
   THEN
      CLOSE cur_grp_dependent;
   END IF ;
   IF cur_account_primary%ISOPEN
   THEN
      CLOSE cur_account_primary;
    END IF ;

   /*** EXIT POINT **/
   RETURN return_value;
EXCEPTION
   WHEN OTHERS
   THEN
      toss_util_pkg.insert_error_tab_proc (v_action, ip_esn, v_function_name);
      RETURN FALSE;
END reset_esn_fun;
/