CREATE OR REPLACE PROCEDURE sa."SP_CLARIFY_REFURB_PRC"
(
  ip_esn               IN VARCHAR2 , --  esn
  ip_reset_date        IN DATE , --  format_date
  ip_order_num         IN VARCHAR2 , --  ""
  ip_user_objid        IN NUMBER , --  app.UserObjId
  ip_mod_objid         IN NUMBER , --  ""
  ip_bin_objid         IN NUMBER , --  ""
  ip_action_type       IN VARCHAR2 , --   "REFURBISHED"
  ip_initial_pi_status IN VARCHAR2 , --"150"
  ip_caller_program    IN VARCHAR2 , -- "MANUAL REFURB"
  ip_ship_date         IN DATE , -- ''
  -- ip_filename            IN       VARCHAR2,
  op_result OUT VARCHAR2,
  i_ignore_esn_update_flag IN  VARCHAR2 DEFAULT 'N'  --CR44390 to Skip status update to 50
) IS
  --       InList1.AppendItem esn,format_date,"",app.UserObjId,"",""
  --       InList1.AppendItem "REFURBISHED","150","MANUAL REFURB",""
  /*******************************************************************************/
  /* Copyright . 2006 Tracfone Wireless Inc. All rights reserved              */
  /* */
  /* Name     :   sp_clarify_refurb_prc                                                                  */
  /* */
  /* Purpose  :   call reset_es_fun_clarify will be used from form 1025     */
  /* */
  /* Version  Date      Who       Purpose                                                                */
  /* -------  --------  -------  -----------------------------------------                                                                          */
  /* 1.0      04/28/2006 Nguada   Initial revision                                                                                         */
  /* 1.1      04/28/2006 Nguada   CR5174 Function Logic Imported                                         */
  /* 1.2      05/08/2006 Nguada   CR5174 Commit Added                                                           */
  /* 1.3      08/22/2006 ICanavan CR4946 Changed reporting from Error_table to              */
  /*                                   refurbish log file. Add explanations to refurbish failures report         */
  /* 1.4      08/24/06      VAdapa   CR4946 No changes                                                                         */
  /* 1.51-1.7, 1.8  09/05/06   ICanavan CR4946 add program name in ip_function.          */
  /*                                                   collect successes and errors                                                                 */
  /* 1.9         03/25/2007           ICanavan CR5082                                                                                 */
  /*                                 1. set x_end_date to sysdate in table_alert                   */
  /*                                 2. removed  table_x_autopay_details record                    */
  /*                                 3. removed table_x_pending_redemption record                  */
  /*                                 4. modified select  from table_x_group2esn                    */
  /*                                 5. removed Table_Case record by x_exn                         */
  /*1.10   06/26/07                  works in automated and in manual
  /***************************************************************************************************/
  /* NEW PVCS STRUCTURE /NEW_PLSQL?CODE                                                              */
  /*1.1/1.2    08/21/07        NGuada              CR6241 Clean ESN data for Refurbishing and Undeliverables       */
  /*1.3        09/18/07        CLindner/VAdapa   CR6731 Eliminate SIM Entry      */
  /*1.4        06/26/08        ICanavan          CR6870 De-Enroll customers from billing platform        */
  /*1.5-9      02/10/09        ICanavan          CR6870 Fix problem with readytoenroll customer account  */
  /*******************************************************************************************************/
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: SP_CLARIFY_REFURB_PRC.sql,v $
  --$Revision: 1.16 $
  --$Author: vyegnamurthy $
  --$Date: 2016/11/07 21:06:46 $
  --$ $Log: SP_CLARIFY_REFURB_PRC.sql,v $
  --$ Revision 1.16  2016/11/07 21:06:46  vyegnamurthy
  --$ CR45234
  --$
  --$ Revision 1.15  2016/11/07 18:18:25  vyegnamurthy
  --$ Made changes for defect CR45234
  --$
  --$ Revision 1.14  2016/10/25 18:38:21  vyegnamurthy
  --$ CR45234 prod code merge
  --$
  --$ Revision 1.13  2016/10/17 15:43:03  mgovindarajan
  --$ CR45464 - Skip updating status to 50 from 59 when branding
  --$
  --$ Revision 1.11  2016/04/21 17:22:35  hnaini
  --$ CR38580 Remove ESN from My Account After Return (Iphone 6S)
  --$
  --$ Revision 1.10  2015/05/22 20:29:32  vsugavanam
  --$
  --$ CR32367:Inserting a record in table_x_point_trans to notify the point generating process of the refurbish event on the ESN
  --$
  --$ Revision 1.9  2014/08/28 21:14:22  vkashmire
  --$ CR29489
  --$
  --$ Revision 1.8  2014/08/22 21:01:52  vkashmire
  --$ CR29489
  --$
  --$ Revision 1.7  2014/05/14 16:12:00  adasgupta
  --$ CR28598  refurb process is deleting the dummy myaccounts
  --$
  --$ Revision 1.6  2014/01/23 22:22:21  icanavan
  --$ ADDED SAFELINK
  --$
  --$ Revision 1.5  2013/09/23 18:06:52  icanavan
  --$ CR25549 similar to reset_esn_fun
  --$
  --$ Revision 1.4  2013/08/20 21:49:14  akhan
  --$ corrected the logic
  --$
  --$ Revision 1.3  2013/08/20 18:29:36  lsatuluri
  --$ Deleting the  default login name from table_web_user
  --$
  --$ Revision 1.2  2012/05/11 21:19:06  kacosta
  --$ CR19490 Warranty Exchanges Counter
  --$
  --$
  ---------------------------------------------------------------------------------------------
  CURSOR cur_cases IS
    SELECT tta.objid
      FROM table_case tta ,table_condition
     WHERE (table_condition.objid = tta.case_state2condition)
       AND ((table_condition.s_title LIKE 'OPEN%') AND (tta.x_esn = ip_esn));

  CURSOR cur_ph IS
    SELECT *
      FROM table_part_inst
     WHERE part_serial_no = ip_esn
       AND x_domain || '' = 'PHONES';

  CURSOR cur_sitepart IS
    SELECT *
      FROM table_site_part
     WHERE x_service_id = ip_esn
       AND part_status || '' = 'Active';

  CURSOR cur_remov_dmucard(ip_esnobjid IN NUMBER) IS
    SELECT *
      FROM table_x_group2esn
     WHERE groupesn2part_inst = ip_esnobjid;

  CURSOR cur_grp_primary(ip_esn IN VARCHAR2) IS
    SELECT *
      FROM x_program_enrolled
     WHERE x_esn = ip_esn
       AND x_is_grp_primary = 1
       AND x_enrollment_status <> 'DEENROLLED' -- CR6870 02062009
          --AND x_enrollment_status NOT IN ( 'DEENROLLED','READYTOREENROLL')
       AND x_type = 'GROUP';

  CURSOR cur_grp_dependent(ip_esn IN VARCHAR2) IS
    SELECT *
      FROM x_program_enrolled
     WHERE pgm_enroll2pgm_group
        IN (SELECT objid FROM x_program_enrolled WHERE x_esn = ip_esn);

  CURSOR cur_account_primary(ip_esn IN VARCHAR2) IS
    SELECT pe.*
      FROM table_x_contact_part_inst cpi
          ,table_part_inst           pi
          ,x_program_enrolled        pe
     WHERE cpi.x_contact_part_inst2part_inst = pi.objid
       AND pi.part_serial_no = pe.x_esn
       AND pi.part_serial_no = ip_esn
       AND cpi.x_is_default = 1;

  -- CR25549 ADDED SAFELINK
  CURSOR cur_SLink (ip_esn IN VARCHAR2) IS
  SELECT lid, x_current_esn
    FROM X_SL_CURRENTVALS where x_current_esn = IP_ESN;

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
  v_function_name        VARCHAR2(80) := ip_caller_program || 'SP_CLARIFY_REFURB_PRC()';
  v_result               VARCHAR2(100) := '';
  ip_filename            VARCHAR2(11) := 'REFURB';
  v_count                NUMBER;
  v_update_group_objid   NUMBER;
  -- Close Case Error Variables
  err_no  VARCHAR2(100);
  err_str VARCHAR2(100);
  -- CR4946 ADDED v_action_type variable
  -- CR5353 v_function_name VARCHAR2 (80) := ip_caller_program || '.RESET_ESN_FUN()';
  v_act_count                NUMBER; --CR45234
  gt       group_type := group_type(); --CR45234
  g        group_type := group_type(); --CR45234
  --
  mt       group_member_type := group_member_type(); --CR45234
  m        group_member_type := group_member_type(); --CR45234
BEGIN
  --   ip_filename    := 'REFURB' || to_char ( sysdate );
  dbms_output.put_line(ip_esn);

  OPEN cur_sitepart;

  FETCH cur_sitepart
    INTO rec_sitepart;

  OPEN cur_ph;

  FETCH cur_ph
    INTO rec_ph;

  IF cur_ph%NOTFOUND THEN
    CLOSE cur_ph;

    /* EXIT POINT -  PHONE NOT found in table_part_inst */
    v_result := 'TABLE_PART_INST ESN Not Found';

    INSERT INTO x_refurb_log
      (esn,status,file_name,log_date,log_text)
    VALUES
      (ip_esn,'FAIL',ip_filename,SYSDATE,'RE:  TABLE_PART_INST ESN Not Found');

    return_value := FALSE;
    do_reset     := FALSE;
    /* AN Active record for that ESN was found on Table_site_part */
  ELSIF cur_sitepart%FOUND THEN
    CLOSE cur_sitepart;

    sa.service_deactivation.deactivate_any
     (ip_esn ,v_action_type ,v_function_name ,v_completion_flag);

    /* no errors return while deactivating (sucess) */
    IF v_completion_flag = TRUE THEN
      /* proceed and do reset routines */
      return_value := TRUE;
      do_reset     := TRUE;
    ELSE
      /* skip reseting routine - errors encountered while deactivating */
      /* deactivated already logged error inside the package           */
      -- cr4946
      v_result := 'Skipping reset routine.  Already deactivated';

      INSERT INTO x_refurb_log
        (esn,status,file_name,log_date,log_text)
      VALUES
        (ip_esn,'FAIL',ip_filename,SYSDATE,'RE:  Skipping reset routine.  Already deactivated');

      return_value := FALSE;
      do_reset     := FALSE;
    END IF;
  ELSE
    return_value := TRUE;
    do_reset     := TRUE;
  END IF;

  /* Reset routine */
  IF do_reset THEN
    /* CR4109 - OTA Feature Phone Reset */
    -- CR25549 one place where this is updated (KEEP IT)
    DELETE FROM table_x_ota_features
     WHERE x_ota_features2part_inst = rec_ph.objid;

    /* CR5082 - Alerts */
    UPDATE table_alert
       SET end_date = SYSDATE
     WHERE alert2contract = rec_ph.objid;

    /* CR5082 - Autopay */
    DELETE FROM table_x_autopay_details
    --WHERE x_autopay_details2x_part_inst = rec_ph.objid;
     WHERE x_autopay_details2site_part = rec_sitepart.objid;
    /* CR11778*/
    /* CR5082 - Pending Redemption  */

    -- CR25549 two approaches to remove records from table_x_pending_redemption.
    -- There were always 2 but I moved one.
    DELETE FROM table_x_pending_redemption
     WHERE x_pend_red2site_part = rec_sitepart.objid;

    DELETE FROM table_x_pending_redemption
     WHERE pend_redemption2esn IN
      (SELECT objid
         FROM table_part_inst
        WHERE part_serial_no = ip_esn AND x_domain = 'PHONES');

    COMMIT;

    /* CR5082 - Table_Case  */ --
    -- CR25549 This is a duplicate
    -- UPDATE table_case SET x_esn = x_esn || 'R' WHERE x_esn = rec_ph.part_serial_no;

    -- CR4946 PROCEDURE IS ONLY Refurbished -- IF ip_action_type = 'REFURBISHED' THEN
    v_action := v_action_type || ':Update Table_Part_Inst';
    dbms_output.put_line('v_action' || v_action);

    UPDATE table_part_inst
       SET x_part_inst_status   = DECODE(NVL(i_ignore_esn_update_flag,'N'), 'N', ip_initial_pi_status, x_part_inst_status) --CR44390 to skip status update to 50
          ,status2x_code_table  =
           (SELECT objid FROM table_x_code_table
             WHERE x_code_number = ip_initial_pi_status)
          ,x_creation_date       = NVL(ip_ship_date ,x_creation_date)
          ,x_order_number        = NVL(ip_order_num ,x_order_number)
          ,created_by2user       = NVL(ip_user_objid ,created_by2user)
          ,last_pi_date          = TO_DATE('01-01-1753' ,'DD-MM-YYYY')
          ,last_cycle_ct         = TO_DATE('01-01-1753' ,'DD-MM-YYYY')
          ,next_cycle_ct         = TO_DATE('01-01-1753' ,'DD-MM-YYYY')
          ,last_mod_time         = TO_DATE('01-01-1753' ,'DD-MM-YYYY')
          ,last_trans_time       = TO_DATE('01-01-1753' ,'DD-MM-YYYY')
          ,date_in_serv          = TO_DATE('01-01-1753' ,'DD-MM-YYYY')
          ,repair_date           = TO_DATE('01-01-1753' ,'DD-MM-YYYY')
          ,n_part_inst2part_mod  = NVL(ip_mod_objid ,n_part_inst2part_mod)
          ,part_inst2inv_bin     = NVL(ip_bin_objid ,part_inst2inv_bin)
          ,x_part_inst2site_part = NULL
          ,x_reactivation_flag   = 0
          ,warr_end_date         = NULL
          ,x_part_inst2contact   = NULL
          ,part_inst2x_pers      = NULL
          ,part_inst2x_new_pers  = NULL
          ,x_clear_tank          = 0
          ,x_iccid               = NULL --CR6731
           --CR19490 Start kacosta 05/11/2012
          ,part_bad_qty = CASE
                            WHEN ip_initial_pi_status = '150' THEN
                             0
                            ELSE
                             part_bad_qty
                          END
    --CR19490 End kacosta 05/11/2012
     WHERE x_domain = 'PHONES'
       AND part_serial_no = ip_esn;

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

    COMMIT;

    -- Remove links between lines or pins with ESN
    UPDATE table_part_inst
       SET part_to_esn2part_inst = NULL
     WHERE part_to_esn2part_inst IN
       (SELECT objid
          FROM table_part_inst
         WHERE part_serial_no = ip_esn AND x_domain = 'PHONES');




         --CR38580:  Remove ESN from My Account After Return (Iphone 6S)
             -- cr38580 remove attachment to the previous web accounts
    delete
    from   table_x_contact_part_inst
    where  x_contact_part_inst2part_inst in ( select objid
                                              FROM   table_part_inst
                                              where  part_serial_no = ip_esn);


    COMMIT;

    -- Remove Pending Units
    -- CR25549 going to move this one up by the other
    -- DELETE FROM table_x_pending_redemption
    -- WHERE pend_redemption2esn IN (SELECT objid
    -- FROM table_part_inst WHERE part_serial_no = ip_esn AND x_domain = 'PHONES');



    -- Close all pending cases and Remove Relations
    FOR rec_case IN cur_cases LOOP
      clarify_case_pkg.close_case
       (rec_case.objid ,ip_user_objid ,NULL ,NULL ,NULL ,err_no ,err_str);
    END LOOP;

    -- Remove Relations to Cases
    -- CR25549 one place where this is updated (KEEP IT)
    UPDATE table_case
       SET x_esn = x_esn || 'R'
     WHERE x_esn = ip_esn;

    COMMIT;

    -- Reset ild Features
    -- CR25549 one place where this is updated (remove IT)
    -- UPDATE table_x_ota_features
    -- SET x_ild_carr_status = 'Inactive'
    -- WHERE x_ota_features2part_inst IN
    -- (SELECT objid FROM table_part_inst
    -- WHERE part_serial_no = ip_esn AND x_domain = 'PHONES');
    -- COMMIT;
    v_action := v_action_type || ':Update Table_Site_Part';

    UPDATE table_site_part
       SET x_refurb_flag = 1
     WHERE x_service_id = ip_esn;

    COMMIT;
    v_action := v_action_type || ':Insert Table_X_Pi_Hist';

    IF toss_util_pkg.insert_pi_hist_fun
      (ip_esn ,'PHONES' ,v_action_type ,v_function_name)
    THEN
      NULL;
    END IF;

    v_action := v_action_type || ':Reset Double Minute Upgrade to a Regular phone';

    FOR rec_remov_dmucard IN cur_remov_dmucard(rec_ph.objid) LOOP
      sp_seq('x_group_hist' ,v_group_hist_seq);

      INSERT INTO table_x_group_hist
        (objid
        ,x_start_date
        ,x_end_date
        ,x_action_date
        ,x_action_type
        ,x_annual_plan
        ,grouphist2part_inst
        ,grouphist2x_promo_group)
      VALUES
        (v_group_hist_seq
        ,rec_remov_dmucard.x_start_date
        ,rec_remov_dmucard.x_end_date
        ,SYSDATE
        ,'REMOVE'
        ,rec_remov_dmucard.x_annual_plan
        ,rec_remov_dmucard.groupesn2part_inst
        ,rec_remov_dmucard.groupesn2x_promo_group);

      DELETE FROM table_x_group2esn
       WHERE objid = rec_remov_dmucard.objid;
    END LOOP;

    COMMIT;

    /* CR6870 - X_Program_Enrolled  */
    FOR rec_grp_primary IN cur_grp_primary(rec_ph.part_serial_no) LOOP
      dbms_output.put_line('gonna insert rec_grp_primary' || rec_grp_primary.x_esn);

      INSERT INTO x_program_trans
        (objid
        ,x_enrollment_status
        ,x_enroll_status_reason
        ,x_trans_date
        ,x_action_text
        ,x_action_type
        ,x_reason
        ,x_sourcesystem
        ,x_esn
        ,x_exp_date
        ,x_cooling_exp_date
        ,x_update_status
        ,x_update_user
        ,pgm_tran2pgm_entrolled
        ,pgm_trans2web_user)
      VALUES
        (billing_seq('X_PROGRAM_TRANS')
        ,'DEENROLLED'
        ,'Refurbished'
        ,SYSDATE
        ,'Refurbish DeEnrollment'
        ,'DE_ENROLL'
        ,'Sp_Clarify_Refurb_Prc.'
        ,rec_grp_primary.x_sourcesystem
        ,rec_grp_primary.x_esn
        ,SYSDATE
        ,SYSDATE
        ,'I'
        ,'SP_CLARIFY_REFURB_PRC'
        ,rec_grp_primary.objid
        ,rec_grp_primary.pgm_enroll2web_user);

      COMMIT;
      dbms_output.put_line('Insert x_billing log' || rec_ph.part_serial_no);

      INSERT INTO x_billing_log
        (objid
        ,x_log_category
        ,x_log_title
        ,x_log_date
        ,x_details
        ,x_nickname
        ,x_esn
        ,x_originator
        ,x_agent_name
        ,x_sourcesystem
        ,billing_log2web_user)
      VALUES
        (billing_seq('X_BILLING_LOG')
        ,'Program'
        ,'Sp_Clarify_Refurb_Prc'
        ,SYSDATE
        ,(SELECT x_program_name
            FROM x_program_parameters
           WHERE objid = rec_grp_primary.pgm_enroll2pgm_parameter) || '    - Refurbished'
        ,billing_getnickname(rec_grp_primary.x_esn)
        ,rec_grp_primary.x_esn
        ,'System'
        ,'System'
        ,rec_grp_primary.x_sourcesystem
        ,rec_grp_primary.pgm_enroll2web_user);

      COMMIT;
      v_count := 1;

      FOR rec_grp_dependent IN cur_grp_dependent(rec_ph.part_serial_no) LOOP
        IF v_count = 1 THEN
          dbms_output.put_line('rec_grp_dependent' || rec_ph.part_serial_no);
          v_update_group_objid := rec_grp_dependent.objid;

          -- cr6870 added x_payment_type
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

          l_grp_depend_esn := rec_grp_dependent.x_esn;

          INSERT INTO x_billing_log
            (objid
            ,x_log_category
            ,x_log_title
            ,x_log_date
            ,x_details
            ,x_nickname
            ,x_esn
            ,x_originator
            ,x_agent_name
            ,x_sourcesystem
            ,billing_log2web_user)
          VALUES
            (billing_seq('X_BILLING_LOG')
            ,'Program'
            ,'Assign Dependent to be Primary of F V P'
            ,SYSDATE
            ,(SELECT x_program_name
                FROM x_program_parameters
               WHERE objid = rec_grp_dependent.pgm_enroll2pgm_parameter) || '    - Refurbished'
            ,billing_getnickname(rec_grp_dependent.x_esn)
            ,rec_grp_dependent.x_esn
            ,'System'
            ,'System'
            ,rec_grp_dependent.x_sourcesystem
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

    /* CR6870 - X_Program_Enrolled  */
    FOR rec_account_primary IN cur_account_primary(rec_ph.part_serial_no) LOOP
      is_acct_primary := TRUE;

      INSERT INTO x_program_trans
        (objid
        ,x_enrollment_status
        ,x_enroll_status_reason
        ,x_trans_date
        ,x_action_text
        ,x_action_type
        ,x_reason
        ,x_sourcesystem
        ,x_esn
        ,x_exp_date
        ,x_cooling_exp_date
        ,x_update_status
        ,x_update_user
        ,pgm_tran2pgm_entrolled
        ,pgm_trans2web_user)
      VALUES
        (billing_seq('X_PROGRAM_TRANS')
        ,'DEENROLLED'
        ,'Refurbished'
        ,SYSDATE
        ,'Refurbish DeEnrollment'
        ,'DE_ENROLL'
        ,'Sp_Clarify_Refurb_Prc.'
        ,rec_account_primary.x_sourcesystem
        ,rec_account_primary.x_esn
        ,SYSDATE
        ,SYSDATE
        ,'I'
        ,'SYSTEM'
        ,rec_account_primary.objid
        ,rec_account_primary.pgm_enroll2web_user);

      COMMIT;

      INSERT INTO x_billing_log
        (objid
        ,x_log_category
        ,x_log_title
        ,x_log_date
        ,x_details
        ,x_nickname
        ,x_esn
        ,x_originator
        ,x_agent_name
        ,x_sourcesystem
        ,billing_log2web_user)
      VALUES
        (billing_seq('X_BILLING_LOG')
        ,'Program'
        ,'Refurbished'
        ,SYSDATE
        ,(SELECT x_program_name
            FROM x_program_parameters
           WHERE objid = rec_account_primary.pgm_enroll2pgm_parameter) || '    - Refurbished'
        ,billing_getnickname(rec_account_primary.x_esn)
        ,rec_account_primary.x_esn
        ,'System'
        ,'System'
        ,rec_account_primary.x_sourcesystem
        ,rec_account_primary.pgm_enroll2web_user);

      COMMIT;
    END LOOP;

    COMMIT;

    /* CR6870 - X_Program_Enrolled  */
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

    COMMIT ;

     -----  CR28598 adasgupta	start ----
     -----  Delete from table_web_user where login_name like ip_esn||'%';

         UPDATE table_web_user
         SET login_name   = objid|| '-' ||login_name ,
             s_login_name = objid|| '-' ||s_login_name
         WHERE login_name LIKE ip_esn||'@%';

         COMMIT ;
    -----  CR28598 adasgupta	end ----


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
    /* CR6870 - X_Program_Enrolled  END */

    -- SECOND ATTEMPT
    DELETE FROM table_x_contact_part_inst
     WHERE x_contact_part_inst2part_inst
     in (select objid from table_part_inst where part_serial_no = ip_esn ) ;

     COMMIT ;

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
  END IF; -- of do_reset

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

  IF cur_SLink%ISOPEN THEN
    CLOSE cur_SLink;
  END IF;
  IF cur_account_primary%ISOPEN THEN
    CLOSE cur_account_primary;
  END IF;
  IF cur_grp_primary%ISOPEN THEN
    CLOSE cur_grp_primary;
  END IF;
  IF cur_grp_dependent%ISOPEN THEN
    CLOSE cur_grp_dependent;
  END IF;
  IF cur_sitepart%ISOPEN THEN
    CLOSE cur_sitepart;
  END IF;
  IF cur_ph%ISOPEN THEN
    CLOSE cur_ph;
  END IF;
  IF cur_cases%ISOPEN THEN
    CLOSE cur_cases ;
  END IF ;
  IF cur_remov_dmucard %ISOPEN THEN
    CLOSE cur_remov_dmucard ;
  END IF ;

  /* EXIT POINT */
  IF return_value -- CR4946 want to see success and failures
   THEN
    op_result := 'Success';
    v_result  := 'SUCCESS';

    INSERT INTO x_refurb_log
      (esn,status,file_name,log_date,log_text)
    VALUES
      (ip_esn ,'SUCCESS' ,ip_filename ,SYSDATE ,'');

    COMMIT;
    dbms_output.put_line(ip_esn);
    dbms_output.put_line(op_result);
    dbms_output.put_line(v_result);
  ELSE
    op_result := 'Fail: ' || v_result;
  END IF;
EXCEPTION
  WHEN others THEN
    op_result := 'Fail: SYSTEM ERROR';

    -- cr4946 toss_util_pkg.insert_error_tab_procedure(v_action, ip_esn, v_function_name);
    INSERT INTO x_refurb_log
      (esn ,status ,file_name ,log_date ,log_text)
    VALUES
      (ip_esn ,'FAIL' ,ip_filename ,SYSDATE ,'RE:  SYSTEM ERROR');

    dbms_output.put_line(ip_esn);
    dbms_output.put_line(op_result);
    dbms_output.put_line(v_result);
END;
/