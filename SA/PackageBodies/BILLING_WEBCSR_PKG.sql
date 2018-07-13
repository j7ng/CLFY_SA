CREATE OR REPLACE PACKAGE BODY sa."BILLING_WEBCSR_PKG" AS
  /********************************************************************************************/
  /* Copyright 2009 Tracfone Wireless Inc. All rights reserved */
  /* */
  /* NAME : SA.BILLING_WEBCSR_PKB */
  /* PURPOSE : */
  /* */
  /* FREQUENCY: */
  /* PLATFORMS: Oracle 8.0.6 AND newer versions. */
  /* */
  /* REVISIONS: */
  /* VERSION DATE WHO PURPOSE */
  /* ------- ---------- ----- --------------------------------------------- */
  /* 1.0 Initial Revision */
  /* 1.1-4 /* 1.5 04/30/09 VAdapa WALMART STRAIGHT_TALK CR8663 */
  /* 1.5.1.0 09/10/09 VAdapa ST_BUNDLE1 */
  /* 1.5.1.1 10/05/09 Merge with BRAND_SEP_II */
  /* 1.5.1.2 11/02/09 CR12155 ST_BUNDLE_III */
  /* 1.5.1.3 11/16/09 CR12155 ST_BUNDLE_III modified transfer_esn_c */
  /* cursor in PROCEDURE transfer_esn_prog_to_diff_esn */
  /* 1.4 1.3 08/20/10 Natalio Guada CR13581 */
  /* 1.5 10/21/10 Skuthadi CR14659 */
  /* 1.7 08/04/11 Pmistry CR13249 */
  /********************************************************************************************/
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: BILLING_WEBCSR_PKG.sql,v $
  --$Revision: 1.41 $
  --$Author: mshah $
  --$Date: 2017/03/27 21:10:06 $
  --$ $Log: BILLING_WEBCSR_PKG.sql,v $
  --$ Revision 1.41  2017/03/27 21:10:06  mshah
  --$ CR49066 - Billing Upgrade job changes
  --$
  --$ Revision 1.40  2017/02/16 20:05:05  abustos
  --$ CR47566 - Old esn should only be upgraded to new when status is ENROLLED
  --$
  --$ Revision 1.39  2015/12/17 22:46:38  vnainar
  --$ CR38927 program class check added for ild de enroll
  --$
  --$ Revision 1.38  2015/12/16 23:20:07  vnainar
  --$ CR38927 brand check added for ild de enrollment
  --$
  --$ Revision 1.37  2015/12/14 23:29:28  vnainar
  --$ CR38927 configuration added to consider non recurring programs also
  --$
  --$ Revision 1.36  2015/12/10 15:13:46  vnainar
  --$ CR38927 procedure transfer_esn_prog_to_diff_esn updated to assign output values only in case of LIFELINE
  --$
  --$ Revision 1.35  2015/12/08 03:59:39  vnainar
  --$ CR38927 merged with PROD version
  --$
  --$ Revision 1.34  2015/12/04 00:24:11  arijal
  --$ CR38927 sl upgrade
  --$
  --$ Revision 1.33  2015/12/02 12:11:08  vnainar
  --$ CR38927 logging added for program change
  --$
  --$ Revision 1.32  2015/12/01 23:40:17  vnainar
  --$ CR38927 updated x_program_enrolled
  --$
  --$ Revision 1.31  2015/11/24 14:16:10  vnainar
  --$ CR38927 x_sl_subs update added
  --$
  --$ Revision 1.30  2015/11/18 15:30:35  vnainar
  --$ CR38927 pgm change added for upgrades
  --$
  --$ Revision 1.29  2015/11/17 22:22:20  arijal
  --$ CR38927 sl upgrade((((((
  --$
  --$ Revision 1.27  2015/11/06 22:24:12  arijal
  --$ CR30860  SL SMARTPHONE UPGRADE ..........
  --$
  --$ Revision 1.26  2015/11/05 21:21:09  arijal
  --$ CR30860  SL SMARTPHONE UPGRADE ..........
  --$
  --$ Revision 1.25  2015/11/05 20:17:44  arijal
  --$ CR30860  SL SMARTPHONE UPGRADE ..........
  --$
  --$ Revision 1.23  2015/11/04 23:33:59  arijal
  --$ CR30860  SL SMARTPHONE UPGRADE ..........
  --$
  --$ Revision 1.22  2015/11/04 14:51:42  arijal
  --$ CR30860  SL SMARTPHONE UPGRADE ..........
  --$
  --$ Revision 1.21  2015/11/03 23:35:39  arijal
  --$ CR30860  SL SMARTPHONE UPGRADE ..........
  --$
  --$ Revision 1.20  2015/11/03 18:30:54  arijal
  --$ sl smartphone upgrade cr30860
  --$
  --$ Revision 1.19  2015/11/03 00:53:03  vyegnamurthy
  --$ CR30860
  --$
  --$ Revision 1.18  2014/09/23 16:44:42  vkashmire
  --$ CR29079-hpp transfer logs added
  --$
  --$ Revision 1.17  2014/09/22 18:25:12  vkashmire
  --$ CR29079 - hpp transfer changes
  --$
  --$ Revision 1.16  2014/08/22 20:57:12  vkashmire
  --$ CR22313 HPP Phase 2
  --$ CR29489 HPP BYOP
  --$ CR27087
  --$ CR29638
  --$
  --$ Revision 1.15  2014/04/15 19:53:45  ymillan
  --$ CR27745
  --$
  --$ Revision 1.14  2014/04/01 15:16:54  ymillan
  --$ CR27745
  --$
  --$ Revision 1.13  2014/04/01 15:01:56  ymillan
  --$ CR27745
  --$
  --$ Revision 1.12  2012/12/04 21:06:28  mmunoz
  --$ CR22380 Handset Protection  merged with rev 1.11 CR22660 Port Package
  --$
  --$ Revision 1.11  2012/11/16 16:22:55  kacosta
  --$ CR22660 Port Package
  --$
  --$ Revision 1.10  2012/11/16 16:11:38  kacosta
  --$ CR22660 Port Package
  --$
  --$ Revision 1.9  2012/10/23 18:52:47  kacosta
  --$ CR22152 ST Promo Logic Enrollment Issue
  --$
  --$ Revision 1.8  2012/05/31 14:05:36  kacosta
  --$ CR20740 Modify Ship Confirm Logic - Added fix to resolve ORA-06502: PL/SQL: NUMERIC OR VALUE error: character string buffer too small
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
  --CR22152 Start Kacosta 10/23/2012
  --********************************************************************************
  -- Procedure to check and transfer enrolled promotions
  --********************************************************************************
  --
  PROCEDURE transfer_enrolled_program_prom(p_old_esn IN x_enroll_promo_grp2esn.x_esn%TYPE
                                           --CR22660 Start kacosta 11/16/2012
                                          ,p_program_parameters_objid IN x_program_parameters.objid%TYPE
                                           --CR22660 End kacosta 11/16/2012
                                          ,p_new_esn       IN x_enroll_promo_grp2esn.x_esn%TYPE
                                          ,p_error_code    OUT PLS_INTEGER
                                          ,p_error_message OUT VARCHAR2) IS
    --
    l_cv_subprogram_name CONSTANT VARCHAR2(61) := 'billing_webcsr_pkg.transfer_enrolled_program_prom';
    l_exc_business_failure EXCEPTION;
    l_i_error_code    PLS_INTEGER := 0;
    l_n_promo_objid   table_x_promotion.objid%TYPE;
    l_v_error_message VARCHAR2(32767) := 'SUCCESS';
    l_v_position      VARCHAR2(32767) := l_cv_subprogram_name || '.1';
    l_v_note          VARCHAR2(32767) := 'Start executing ' || l_cv_subprogram_name;
    l_v_script_id     x_enroll_promo_rule.x_script_id%TYPE;
    l_v_promo_code    table_x_promotion.x_promo_code%TYPE;
    --
  BEGIN
    --
    --DBMS_OUTPUT.PUT_LINE(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE,' MM/DD/YYYY HH:MI:SS AM'));
    --DBMS_OUTPUT.PUT_LINE('p_old_esn                 : ' || NVL(p_old_esn,'Value is null'));
    --DBMS_OUTPUT.PUT_LINE('p_program_parameters_objid: ' || NVL(TO_CHAR(p_program_parameters_objid),'Value is null'));
    --DBMS_OUTPUT.PUT_LINE('p_new_esn                 : ' || NVL(p_new_esn,'Value is null'));
    --
    l_v_position := l_cv_subprogram_name || '.2';
    l_v_note     := 'Calling enroll_promo_pkg.sp_get_eligible_promo_esn3';
    --
    --DBMS_OUTPUT.PUT_LINE(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE,' MM/DD/YYYY HH:MI:SS AM'));
    --
    --CR22660 Start kacosta 11/16/2012
    --enroll_promo_pkg.sp_get_eligible_promo_esn2(p_esn           => p_old_esn
    enroll_promo_pkg.sp_get_eligible_promo_esn3(p_esn => p_old_esn
                                                --CR22660 End kacosta 11/16/2012
                                                --CR22660 Start kacosta 11/16/2012
                                               ,p_program_objid => p_program_parameters_objid
                                                --CR22660 End kacosta 11/16/2012
                                               ,p_promo_objid => l_n_promo_objid
                                               ,p_promo_code  => l_v_promo_code
                                               ,p_script_id   => l_v_script_id
                                               ,p_error_code  => l_i_error_code
                                               ,p_error_msg   => l_v_error_message);
    --
    --CR22660 Start kacosta 11/16/2012
    --IF (l_i_error_code <> 0) THEN
    IF (l_i_error_code NOT IN (0
                              ,306)) THEN
      --CR22660 End kacosta 11/16/2012
      --
      l_v_error_message := 'Calling enroll_promo_pkg.sp_get_eligible_promo_esn3 error message: ' || l_v_error_message;
      --
      RAISE l_exc_business_failure;
      --
      --CR22660 Start kacosta 11/16/2012
    ELSIF (l_i_error_code = 306) THEN
      --
      l_i_error_code := 0;
      --
      --CR22660 End kacosta 11/16/2012
    END IF;
    --
    IF (l_n_promo_objid IS NOT NULL) THEN
      --
      l_v_position := l_cv_subprogram_name || '.3';
      l_v_note     := 'Retrieving case for old and new ESNs';
      --
      --DBMS_OUTPUT.PUT_LINE(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE,' MM/DD/YYYY HH:MI:SS AM'));
      --
      FOR case_rec IN (SELECT objid
                         FROM (SELECT tbc.objid
                                 FROM table_case tbc
                                 JOIN table_condition tcd
                                   ON tbc.case_state2condition = tcd.objid
                                 JOIN table_x_case_detail xcd
                                   ON tbc.objid = xcd.detail2case
                                WHERE tbc.x_esn = p_new_esn
                                  AND tcd.s_title <> 'CLOSED'
                                  AND xcd.x_name = 'CURRENT_ESN'
                                  AND xcd.x_value = p_old_esn
                                ORDER BY creation_time)
                        WHERE ROWNUM <= 1) LOOP
        --
        l_v_position := l_cv_subprogram_name || '.4';
        l_v_note     := 'Calling enroll_promo_pkg.sp_transfer_promo_enrollment';
        --
        --DBMS_OUTPUT.PUT_LINE(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE,' MM/DD/YYYY HH:MI:SS AM'));
        --
        enroll_promo_pkg.sp_transfer_promo_enrollment(p_case_objid => case_rec.objid
                                                     ,p_new_esn    => p_new_esn
                                                     ,p_error_code => l_i_error_code
                                                     ,p_error_msg  => l_v_error_message);
        --
        IF (l_i_error_code <> 0) THEN
          --
          l_v_error_message := 'Calling enroll_promo_pkg.sp_transfer_promo_enrollment error message: ' || l_v_error_message;
          --
          RAISE l_exc_business_failure;
          --
        END IF;
        --
      END LOOP;
      --
    END IF;
    --
    l_v_position := l_cv_subprogram_name || '.5';
    l_v_note     := 'End executing ' || l_cv_subprogram_name;
    --
    --DBMS_OUTPUT.PUT_LINE(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE,' MM/DD/YYYY HH:MI:SS AM'));
    --DBMS_OUTPUT.PUT_LINE('p_error_code   : ' || NVL(TO_CHAR(l_i_error_code),'Value is null'));
    --DBMS_OUTPUT.PUT_LINE('p_error_message: ' || NVL(l_v_error_message,'Value is null'));
    --
    p_error_code    := l_i_error_code;
    p_error_message := l_v_error_message;
    --
  EXCEPTION
    WHEN l_exc_business_failure THEN
      --
      ROLLBACK;
      --
      p_error_code    := l_i_error_code;
      p_error_message := l_v_error_message;
      --
      ota_util_pkg.err_log(p_action       => l_v_note
                          ,p_error_date   => SYSDATE
                          ,p_key          => 'Old ESN: ' || p_old_esn || ' New ESN: ' || p_new_esn
                          ,p_program_name => l_v_position
                          ,p_error_text   => p_error_message);
      --
      l_v_position := l_cv_subprogram_name || '.6';
      l_v_note     := 'End executing with business error ' || l_cv_subprogram_name;
      --
      --DBMS_OUTPUT.PUT_LINE(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE,' MM/DD/YYYY HH:MI:SS AM'));
      --DBMS_OUTPUT.PUT_LINE('p_error_code   : ' || NVL(TO_CHAR(p_error_code),'Value is null'));
      --DBMS_OUTPUT.PUT_LINE('p_error_message: ' || NVL(p_error_message,'Value is null'));
      --
    WHEN others THEN
      --
      ROLLBACK;
      --
      p_error_code    := SQLCODE;
      p_error_message := SQLERRM;
      --
      ota_util_pkg.err_log(p_action       => l_v_note
                          ,p_error_date   => SYSDATE
                          ,p_key          => 'Old ESN: ' || p_old_esn || ' New ESN: ' || p_new_esn
                          ,p_program_name => l_v_position
                          ,p_error_text   => p_error_message);
      --
      l_v_position := l_cv_subprogram_name || '.7';
      l_v_note     := 'End executing with Oracle error ' || l_cv_subprogram_name;
      --
      --DBMS_OUTPUT.PUT_LINE(l_v_position || ': ' || l_v_note || TO_CHAR(SYSDATE,' MM/DD/YYYY HH:MI:SS AM'));
      --DBMS_OUTPUT.PUT_LINE('p_error_code   : ' || NVL(TO_CHAR(p_error_code),'Value is null'));
      --DBMS_OUTPUT.PUT_LINE('p_error_message: ' || NVL(p_error_message,'Value is null'));
      --
  END transfer_enrolled_program_prom;
  --CR22152 End Kacosta 10/2/2012
  --
  PROCEDURE move_cycle_date
  (
    p_enrolled_objid IN x_program_enrolled.objid%TYPE
   ,p_cycle_days     IN NUMBER
   ,p_user           IN VARCHAR2
   ,op_result        OUT NUMBER
   ,op_msg           OUT VARCHAR2
  ) IS
    l_bill_cycle_day     NUMBER;
    l_program_name       x_program_parameters.x_program_name%TYPE;
    l_program_enroll_rec x_program_enrolled%ROWTYPE;
    l_next_charge_date   DATE;
    l_date               DATE DEFAULT TRUNC(SYSDATE);
    l_count              NUMBER := 0;
    l_first_name         table_contact.first_name%TYPE;
    l_last_name          table_contact.last_name%TYPE;
    ---CR13581
    l_st_enrolled   CHAR(1) := 'N';
    retval          NUMBER; --ST_BUNDLE1
    l_bus_acc       CHAR(1) := 'N';
    l_contact_objid NUMBER;
    ----CR13581

    --CR8663
    CURSOR c_get_st_enroll IS
      SELECT 'X'
        FROM x_program_enrolled   pe
            ,x_program_parameters pp
       WHERE 1 = 1
         AND pp.objid = pe.pgm_enroll2pgm_parameter
         AND pp.x_prog_class = 'SWITCHBASE'
         AND pe.x_enrollment_status = 'ENROLLED'
         AND pe.objid = p_enrolled_objid;

    r_get_st_enroll c_get_st_enroll%ROWTYPE;

    --is business account cursor
    CURSOR c_bus_acc -----------------CR13581
    IS
      SELECT x_business_accounts.*
        FROM x_program_enrolled
            ,x_business_accounts
            ,table_web_user
       WHERE pgm_enroll2web_user = table_web_user.objid
         AND bus_primary2contact = web_user2contact
         AND x_program_enrolled.objid = p_enrolled_objid;

    r_bus_acc c_bus_acc%ROWTYPE;

    --
    CURSOR c_bus_acc_esns(contact_objid NUMBER) IS
      SELECT pe.*
        FROM x_program_enrolled pe
       WHERE pgm_enroll2web_user IN (SELECT objid
                                       FROM table_web_user
                                      WHERE web_user2contact = contact_objid)
         AND x_enrollment_status IN ('ENROLLED'
                                    ,'ENROLLMENTSCHEDULED');

    r_bus_acc_esns c_bus_acc_esns%ROWTYPE;

    CURSOR c_bus_acc_switch(contact_objid NUMBER) IS
      SELECT 'X'
        FROM x_program_enrolled   pe
            ,x_program_parameters pp
            ,table_web_user       wu
       WHERE 1 = 1
         AND pp.objid = pe.pgm_enroll2pgm_parameter
         AND pp.x_prog_class = 'SWITCHBASE'
         AND pe.x_enrollment_status = 'ENROLLED'
         AND pe.pgm_enroll2web_user = wu.objid
         AND wu.web_user2contact = contact_objid;
    r_bus_acc_switch c_bus_acc_switch %ROWTYPE;

    --enrolment cursor
    CURSOR c_enrollment(pe_objid NUMBER) IS
      SELECT pp.x_program_name
            ,pp.x_bill_cyl_shift_days
            ,pe.*
            ,co.first_name
            ,co.last_name
        FROM x_program_enrolled   pe
            ,x_program_parameters pp
            ,table_contact        co
            ,table_web_user
       WHERE 1 = 1
         AND pgm_enroll2pgm_parameter = pp.objid
         AND pgm_enroll2web_user = table_web_user.objid
         AND co.objid = web_user2contact
         AND pe.objid = pe_objid;

    r_enrollment c_enrollment%ROWTYPE; ------CR13581

  BEGIN
    ------CR13581
    op_result := 0;
    --Determine if Business Account
    OPEN c_bus_acc;
    FETCH c_bus_acc
      INTO r_bus_acc;
    IF c_bus_acc%FOUND THEN
      l_bus_acc := 'Y';
      --DBMS_OUTPUT.PUT_LINE('Business Account');
      l_contact_objid := r_bus_acc.bus_primary2contact;
      OPEN c_bus_acc_switch(l_contact_objid);
      FETCH c_bus_acc_switch
        INTO r_bus_acc_switch;
      IF c_bus_acc_switch%FOUND THEN
        l_st_enrolled := 'Y'; --has a switchbase esns
        --DBMS_OUTPUT.PUT_LINE('SWITCHBASED Business Account');
      END IF;
      CLOSE c_bus_acc_switch;
    ELSE
      --Determine if STRAIGHT_TALK for single accounts
      --DBMS_OUTPUT.PUT_LINE('SWITCHBASE Individual Account');
      OPEN c_get_st_enroll;
      FETCH c_get_st_enroll
        INTO r_get_st_enroll;
      IF c_get_st_enroll%FOUND THEN
        CLOSE c_get_st_enroll;
        l_st_enrolled := 'Y'; --is a switchbase esn
      ELSE
        --Determine number of changes in the last year for other accounts
        --DBMS_OUTPUT.PUT_LINE('Individual Account not Switchbase');
        CLOSE c_get_st_enroll; -----------------------------------CR13581
        SELECT COUNT(*)
          INTO l_count
          FROM x_program_trans
         WHERE x_trans_date BETWEEN l_date - 365 AND l_date
           AND x_action_type = 'CHANGE_PAYMENT_DATE'
           AND pgm_tran2pgm_entrolled = p_enrolled_objid;
        IF l_count > 0 THEN
          -----CR13581
          op_result := -20001;
          op_msg    := 'Payment Cycle Date can be changed only once in a year';
          RETURN; --------CR13581
        END IF;
      END IF;
    END IF;
    CLOSE c_bus_acc;

    -- CR14659 ST Retention -- proceed if ESNs are SWITCHBASED
    /*
    If L_St_Enrolled = 'Y' Then
    Op_Result := -20001;
    Op_Msg := 'Payment Cycle cannot be changed when ESNs are switchbase';
    Return;
    end if;
    */

    OPEN c_enrollment(p_enrolled_objid);
    FETCH c_enrollment
      INTO r_enrollment;
    IF c_enrollment%NOTFOUND THEN
      CLOSE c_enrollment; --------CR13581
      op_result := -100;
      op_msg    := 'Enrollment Record not found'; ------CR13581
      RETURN;
    END IF;
    CLOSE c_enrollment;

    l_next_charge_date := r_enrollment.x_next_charge_date + p_cycle_days;

    --IF l_bill_cycle_day < p_cycle_days THEN -----CR13581 -- CR14659 comments it

     -- CR27745   IF r_enrollment.x_bill_cyl_shift_days < p_cycle_days and r_enrollment.x_sourcesystem not in ('BATCH') THEN --CR27745
      -- CR14659
      --  op_result := 101;
      -- op_msg    := 'Billing Cycle Date is not between the extension period of ' || TO_CHAR(r_enrollment.x_bill_cyl_shift_days) || ' days defined by the program.';
      -- RETURN; ---CR13581
     --- END IF; ----CR13581

    --ST_BUNDLE1
    retval := billing_global_insert_pkg.billing_insert_prog_trans(billing_seq('X_PROGRAM_TRANS')
                                                                 ,r_enrollment.x_enrollment_status
                                                                 ,NULL
                                                                 ,NULL
                                                                 ,NULL
                                                                 ,NULL
                                                                 ,SYSDATE
                                                                 ,'Change Payment Date'
                                                                 ,'CHANGE_PAYMENT_DATE'
                                                                 ,r_enrollment.x_program_name || ' From ' || r_enrollment.x_next_charge_date || ' to ' || l_next_charge_date
                                                                 ,r_enrollment.x_sourcesystem
                                                                 ,r_enrollment.x_esn
                                                                 ,SYSDATE
                                                                 ,SYSDATE
                                                                 ,'I'
                                                                 ,NVL(p_user
                                                                     ,'System')
                                                                 ,r_enrollment.objid
                                                                 ,r_enrollment.pgm_enroll2web_user
                                                                 ,r_enrollment.pgm_enroll2site_part);

    ---------------- Insert a billing Log ------------------------------------------------------------
    INSERT INTO x_billing_log
      (objid
      ,x_log_category
      ,x_log_title
      ,x_log_date
      ,x_details
      ,x_program_name
      ,x_nickname
      ,x_esn
      ,x_originator
      ,x_contact_first_name
      ,x_contact_last_name
      ,x_agent_name
      ,x_sourcesystem
      ,billing_log2web_user)
    VALUES
      (billing_seq('X_BILLING_LOG')
      , ------ Modified for CR13581
       'Program'
      ,'Change Payment Date'
      ,SYSDATE
      ,r_enrollment.x_program_name || ' From ' || r_enrollment.x_next_charge_date || ' to ' || l_next_charge_date
      ,r_enrollment.x_program_name
      ,billing_getnickname(r_enrollment.x_esn)
      ,r_enrollment.x_esn
      ,p_user
      ,r_enrollment.first_name
      ,r_enrollment.last_name
      ,p_user
      ,r_enrollment.x_sourcesystem
      ,r_enrollment.pgm_enroll2web_user);

    ----CR13581
    IF l_bus_acc = 'Y' THEN
      -- Business Account Branch

      UPDATE x_program_enrolled
         SET x_next_charge_date = l_next_charge_date
            ,x_update_stamp     = SYSDATE
       WHERE pgm_enroll2web_user IN (SELECT objid
                                       FROM table_web_user
                                      WHERE web_user2contact = l_contact_objid)
         AND x_enrollment_status IN ('ENROLLED'
                                    ,'ENROLLMENTSCHEDULED');

      FOR r_bus_acc_esns IN c_bus_acc_esns(l_contact_objid) LOOP

        billing_extend_servicedays(r_bus_acc_esns.x_esn
                                  ,TRUNC(l_next_charge_date - SYSDATE)
                                  ,p_cycle_days
                                  ,op_result
                                  ,op_msg);

      END LOOP;

    ELSE
      -- Individual Account Branch

      UPDATE x_program_enrolled
         SET x_next_charge_date = l_next_charge_date
            ,x_update_stamp     = l_date
       WHERE objid = p_enrolled_objid; ----------CR13581

      FOR idx IN (SELECT *
                    FROM x_program_enrolled pe1
                   WHERE ((objid = p_enrolled_objid AND NOT EXISTS (SELECT 1
                                                                      FROM x_program_enrolled   pe
                                                                          ,x_program_parameters pp
                                                                     WHERE pp.objid = pe.pgm_enroll2pgm_parameter
                                                                       AND pp.x_prog_class = 'SWITCHBASE'
                                                                       AND pe.x_enrollment_status = 'ENROLLED'
                                                                       AND pe.objid = pe1.objid)) OR pgm_enroll2pgm_group = p_enrolled_objid)) LOOP
        -------------- Check if the service days are expiring by any chance. -----------------------------
        -------------- If the service days are expiring, add the necessary service days. -----------------
        billing_extend_servicedays(idx.x_esn
                                  ,TRUNC(l_next_charge_date - SYSDATE)
                                  ,p_cycle_days
                                  ,op_result
                                  ,op_msg);

      END LOOP;

    END IF;

  EXCEPTION
    WHEN others THEN
      op_result := -100;
      op_msg    := SQLCODE || SUBSTR(SQLERRM
                                    ,1
                                    ,100);

      IF (SQLCODE = -1400) THEN
        op_result := -1400;
        op_msg    := 'Entered is NULL';
      END IF;
  END move_cycle_date;

  PROCEDURE extent_grace_period
  (
    p_enrolled_objid IN x_program_enrolled.objid%TYPE
   ,p_grace_days     IN NUMBER
   ,p_user           IN VARCHAR2
   ,op_result        OUT NUMBER
   ,op_msg           OUT VARCHAR2
  )
  -- DECLARE
    -- OP_RESULT NUMBER;
    -- OP_MSG VARCHAR2(200);
    -- BEGIN
    -- TRAC.BILLING_WEBCSR_PKG.EXTENT_GRACE_PERIOD ( 102, 5, OP_RESULT, OP_MSG );
    -- --DBMS_OUTPUT.PUT_LINE('OP_RESULT = ' || TO_CHAR(OP_RESULT));
    -- --DBMS_OUTPUT.PUT_LINE('OP_MSG = ' || OP_MSG) ;
    -- END;
   IS
    l_grace_day          NUMBER;
    l_program_name       x_program_parameters.x_program_name%TYPE;
    l_program_enroll_rec x_program_enrolled%ROWTYPE;
    l_exp_date           DATE;
    l_service_exp_date   DATE;
    l_date               DATE DEFAULT TRUNC(SYSDATE);
    l_first_name         table_contact.first_name%TYPE;
    l_last_name          table_contact.last_name%TYPE;
    retval               NUMBER; --ST_BUNDLE1
  BEGIN
    -- Get the allowable grace period as defined by the program parameter.
    BEGIN
      SELECT x_program_name
            ,x_grace_period_webcsr
        INTO l_program_name
            ,l_grace_day
        FROM x_program_parameters
       WHERE objid = (SELECT pgm_enroll2pgm_parameter
                        FROM x_program_enrolled
                       WHERE objid = p_enrolled_objid);
    EXCEPTION
      WHEN others THEN
        op_result := SQLCODE;
        op_msg    := SUBSTR(SQLERRM
                           ,1
                           ,100);
    END;

    -- 5 < 11 then give error else it will update
    IF l_grace_day < p_grace_days THEN
      op_result := 101;
      op_msg    := 'This enrollment allows a grace period extension of ' || l_grace_day || ' days.';
    ELSE
      -- Get the enrollment record.
      SELECT *
        INTO l_program_enroll_rec
        FROM x_program_enrolled
       WHERE (objid = p_enrolled_objid);

      l_exp_date := NVL(l_program_enroll_rec.x_exp_date
                       ,SYSDATE) + p_grace_days;

      -- BUG 625: GracePeriod extension should always take the next_charge_date into account and extend it.
      --l_exp_date := NVL(l_program_enroll_rec.x_next_charge_date, sysdate) + p_grace_days;
      UPDATE x_program_enrolled
         SET x_exp_date     = l_exp_date
            ,x_update_stamp = l_date
       WHERE (objid = p_enrolled_objid OR pgm_enroll2pgm_group = p_enrolled_objid);

      --ST_BUNDLE1
      retval := billing_global_insert_pkg.billing_insert_prog_trans(billing_seq('X_PROGRAM_TRANS')
                                                                   ,l_program_enroll_rec.x_enrollment_status
                                                                   ,NULL
                                                                   ,NULL
                                                                   ,NULL
                                                                   ,p_grace_days
                                                                   ,SYSDATE
                                                                   ,'Grace Period Extension'
                                                                   ,'GRACE_PERIOD_EXTENSION'
                                                                   ,l_program_name || ' ' || TO_CHAR(p_grace_days) || ' days ' || TRUNC(NVL(l_program_enroll_rec.x_exp_date
                                                                                                                                           ,SYSDATE)) || ' to ' || l_exp_date
                                                                   ,l_program_enroll_rec.x_sourcesystem
                                                                   ,l_program_enroll_rec.x_esn
                                                                   ,l_date
                                                                   ,l_date
                                                                   ,'I'
                                                                   ,NVL(p_user
                                                                       ,'System')
                                                                   ,l_program_enroll_rec.objid
                                                                   ,l_program_enroll_rec.pgm_enroll2web_user
                                                                   ,l_program_enroll_rec.pgm_enroll2site_part);

      /* INSERT
      INTO x_program_trans(
      objid,
      x_enrollment_status,
      x_enroll_status_reason,
      x_float_given,
      x_cooling_given,
      x_grace_period_given,
      x_trans_date,
      x_action_text,
      x_action_type,
      x_reason,
      x_sourcesystem,
      x_esn,
      x_exp_date,
      x_cooling_exp_date,
      x_update_status,
      x_update_user,
      pgm_tran2pgm_entrolled,
      pgm_trans2web_user,
      pgm_trans2site_part
      ) VALUES(
      billing_seq ('X_PROGRAM_TRANS'),
      l_program_enroll_rec.x_enrollment_status,
      NULL,
      NULL,
      NULL,
      p_grace_days,
      SYSDATE,
      'Grace Period Extension',
      'GRACE_PERIOD_EXTENSION',
      l_program_name || ' ' || TO_CHAR (p_grace_days) || ' days '
      || TRUNC (NVL (l_program_enroll_rec.x_exp_date, SYSDATE)) || ' to '
      || l_exp_date,
      l_program_enroll_rec.x_sourcesystem,
      l_program_enroll_rec.x_esn,
      l_date,
      l_date,
      'I',
      NVL (p_user, 'System'),
      l_program_enroll_rec.objid,
      l_program_enroll_rec.pgm_enroll2web_user,
      l_program_enroll_rec.pgm_enroll2site_part
      );*/ --ST_BUNDLE1
      FOR idx IN (SELECT *
                    FROM x_program_enrolled
                   WHERE objid = p_enrolled_objid
                      OR pgm_enroll2pgm_group = p_enrolled_objid) LOOP
        -- Extend the service expiry date in case the ESN is expiring
        --
        -- Start CR13082 Kacosta 01/21/2011
        --SELECT x_expire_dt
        -- INTO l_service_exp_date
        -- FROM table_site_part
        -- WHERE x_service_id = l_program_enroll_rec.x_esn
        -- AND part_status = 'Active';
        SELECT tsp.x_expire_dt
          INTO l_service_exp_date
          FROM table_part_inst tpi
              ,table_site_part tsp
         WHERE tsp.x_service_id = l_program_enroll_rec.x_esn
           AND tsp.part_status = 'Active'
           AND tsp.objid = tpi.x_part_inst2site_part
           AND tpi.x_part_inst_status = '52'
           AND tpi.x_domain = 'PHONES';
        -- End CR13082 Kacosta 01/21/2011
        --
        IF (l_service_exp_date < l_exp_date) THEN
          --
          -- Start CR13082 Kacosta 01/21/2011
          --UPDATE table_site_part
          -- SET x_expire_dt = l_exp_date
          -- WHERE x_service_id = l_program_enroll_rec.x_esn
          -- AND part_status = 'Active';
          UPDATE table_site_part tsp
             SET tsp.x_expire_dt = l_exp_date
           WHERE tsp.x_service_id = l_program_enroll_rec.x_esn
             AND tsp.part_status = 'Active'
             AND EXISTS (SELECT 1
                    FROM table_part_inst tpi
                   WHERE tpi.x_part_inst2site_part = tsp.objid
                     AND tpi.x_part_inst_status = '52'
                     AND tpi.x_domain = 'PHONES');
          -- End CR13082 Kacosta 01/21/2011
          --

          UPDATE table_part_inst
             SET warr_end_date = l_exp_date
           WHERE part_serial_no = l_program_enroll_rec.x_esn
             AND part_status = 'Active';
        END IF;
      END LOOP;

      --------------------------------------------------------------------------------------------------
      ---------------- Get the contact details for logging ---------------------------------------------
      SELECT first_name
            ,last_name
        INTO l_first_name
            ,l_last_name
        FROM table_contact
       WHERE objid = (SELECT web_user2contact
                        FROM table_web_user
                       WHERE objid = l_program_enroll_rec.pgm_enroll2web_user);

      ---------------- Insert a billing Log ------------------------------------------------------------
      INSERT INTO x_billing_log
        (objid
        ,x_log_category
        ,x_log_title
        ,x_log_date
        ,x_details
        ,x_program_name
        ,x_nickname
        ,x_esn
        ,x_originator
        ,x_contact_first_name
        ,x_contact_last_name
        ,x_agent_name
        ,x_sourcesystem
        ,billing_log2web_user)
      VALUES
        (billing_seq('X_BILLING_LOG')
        ,'Program'
        ,'Grace Period Extension'
        ,SYSDATE
        ,l_program_name || ' ' || TO_CHAR(p_grace_days) || ' days ' || TRUNC(NVL(l_program_enroll_rec.x_exp_date
                                                                                ,SYSDATE)) || ' to ' || l_exp_date
        ,l_program_name
        ,billing_getnickname(l_program_enroll_rec.x_esn)
        ,l_program_enroll_rec.x_esn
        ,p_user
        ,l_first_name
        ,l_last_name
        ,p_user
        ,l_program_enroll_rec.x_sourcesystem
        ,l_program_enroll_rec.pgm_enroll2web_user);

      --------------------------------------------------------------------------------------------------
      COMMIT;
    END IF;
  EXCEPTION
    WHEN others THEN
      op_result := -100;
      op_msg    := SQLCODE || SUBSTR(SQLERRM
                                    ,1
                                    ,100);

      IF (SQLCODE = -1400) THEN
        op_result := -1400;
        op_msg    := 'Entered is NULL';
      END IF;
  END extent_grace_period;

  PROCEDURE has_grace_period_changed
  (
    p_web_user_objid IN x_program_enrolled.pgm_enroll2web_user%TYPE
   ,op_result        OUT NUMBER
   ,op_msg           OUT VARCHAR2
  ) IS
    l_grace_change_count     NUMBER;
    l_reversed_count         NUMBER;
    l_paydate_changed_xtimes NUMBER;
    l_paydate_change_count   NUMBER;
    -- constants for X times in Y time
    nooftimesallowed NUMBER := 10;
    duration         NUMBER := 365;
  BEGIN
    -- Has Grace period been changed within last year(Validation will check on account
    -- level for Grace Period Extensions)?
    SELECT COUNT(*)
      INTO l_grace_change_count
      FROM x_program_trans
     WHERE x_trans_date BETWEEN SYSDATE - 365 AND SYSDATE
       AND x_action_type = 'GRACE_PERIOD_EXTENSION'
       AND pgm_trans2web_user = p_web_user_objid;

    -- YES. Grace Period has been changed for the user within the last year
    IF l_grace_change_count > 0 THEN
      --Has Payment Date been changed X times between Y time ?
      SELECT COUNT(*)
        INTO l_paydate_changed_xtimes
        FROM x_program_trans    a
            ,x_program_enrolled b
       WHERE a.x_trans_date BETWEEN SYSDATE - duration AND SYSDATE
         AND a.x_action_type = 'CHANGE_PAYMENT_DATE'
         AND a.pgm_trans2web_user = p_web_user_objid
         AND b.pgm_enroll2web_user = a.pgm_trans2web_user
         AND a.pgm_tran2pgm_entrolled = b.objid
         AND b.x_is_grp_primary = 1;

      -- YES. Payment date has changed X times between Y time for this account
      IF l_paydate_changed_xtimes >= nooftimesallowed THEN
        op_result := 1;
        op_msg    := 'The grace period on the account has already been changed once this year.<br> We are sorry but we can only do this once a year';
      ELSE
        -- NO. Payment date has not changed X times between Y time
        -- Are there Programs on account eligible for Payment date change ?
        SELECT COUNT(*)
          INTO l_paydate_change_count
          FROM x_program_enrolled a
         WHERE a.pgm_enroll2web_user = p_web_user_objid
           AND a.x_enrollment_status = 'ENROLLED'
           AND a.x_is_grp_primary = 1
           AND a.objid NOT IN (SELECT b.pgm_tran2pgm_entrolled
                                 FROM x_program_trans b
                                WHERE b.x_trans_date BETWEEN SYSDATE - 365 AND SYSDATE
                                  AND b.x_action_type = 'CHANGE_PAYMENT_DATE'
                                  AND b.pgm_trans2web_user = a.pgm_enroll2web_user
                                  AND b.pgm_tran2pgm_entrolled = a.objid);

        -- YES. There are programs eligible for Payment date change for the account
        IF l_paydate_change_count > 0 THEN
          op_result := 2;
          op_msg    := 'Grace period already changed, change Payment date instead? ';
        ELSE
          -- NO. There are no eligible programs for Payment date chaange
          op_result := 1;
          op_msg    := 'The grace period on the account has already been changed once this year.<br> We are sorry but we can only do this once a year';
        END IF;
      END IF;
    ELSE
      -- Are there reversed Payments ?
      SELECT COUNT(a.x_esn)
        INTO l_reversed_count
        FROM x_program_enrolled a
       WHERE a.x_enrollment_status = 'SUSPENDED'
         AND a.x_is_grp_primary = 1
         AND a.pgm_enroll2web_user = p_web_user_objid;

      -- YES. There are one or more reversed payments for the account
      IF l_reversed_count > 0 THEN
        op_result := 3;
        op_msg    := 'Show Extend Grace Period Screen';
      ELSE
        -- NO. There are no Reversed Payments for this account
        --Has Payment Date been changed X times between Y time ?
        SELECT COUNT(*)
          INTO l_paydate_changed_xtimes
          FROM x_program_trans    a
              ,x_program_enrolled b
         WHERE a.x_trans_date BETWEEN SYSDATE - duration AND SYSDATE
           AND a.x_action_type = 'CHANGE_PAYMENT_DATE'
           AND a.pgm_trans2web_user = p_web_user_objid
           AND b.pgm_enroll2web_user = a.pgm_trans2web_user
           AND a.pgm_tran2pgm_entrolled = b.objid
           AND b.x_is_grp_primary = 1;

        -- YES. Payment date has changed X times between Y time
        IF l_paydate_changed_xtimes >= nooftimesallowed THEN
          op_result := 4;
          op_msg    := 'We cannot extend due date, if you want we can change the Funding Source';
        ELSE
          -- NO. Payment date has not changed X times between Y time
          -- Are there Programs on account eligible for Payment date change?
          SELECT COUNT(*)
            INTO l_paydate_change_count
            FROM x_program_enrolled a
           WHERE a.pgm_enroll2web_user = p_web_user_objid
             AND a.x_enrollment_status = 'ENROLLED'
             AND a.x_is_grp_primary = 1
             AND a.objid NOT IN (SELECT b.pgm_tran2pgm_entrolled
                                   FROM x_program_trans b
                                  WHERE b.x_trans_date BETWEEN SYSDATE - 365 AND SYSDATE
                                    AND b.x_action_type = 'CHANGE_PAYMENT_DATE'
                                    AND b.pgm_trans2web_user = a.pgm_enroll2web_user
                                    AND b.pgm_tran2pgm_entrolled = a.objid);

          -- YES. There are programs eligible for Payment date change in the account
          IF l_paydate_change_count > 0 THEN
            op_result := 5;
            op_msg    := 'Move Payment date instead? ';
          ELSE
            -- NO. There are no eligible programs for Payment date chaange
            op_result := 4;
            op_msg    := 'We cannot extend due date, if you want we can change the Funding Source';
          END IF;
        END IF;
      END IF;
    END IF;
  EXCEPTION
    WHEN others THEN
      op_result := -100;
      op_msg    := SQLCODE || SUBSTR(SQLERRM
                                    ,1
                                    ,100);

      IF (SQLCODE = -1400) THEN
        op_result := -1400;
        op_msg    := 'Web User Objid is NULL';
      END IF;
  END has_grace_period_changed;

  PROCEDURE remove_cooling_period
  (
    p_enrolled_objid IN x_program_enrolled.objid%TYPE
   ,p_user           IN VARCHAR2
   ,op_result        OUT NUMBER
   ,op_msg           OUT VARCHAR2
  ) IS
    l_program_enroll_rec x_program_enrolled%ROWTYPE;
    l_program_name       x_program_parameters.x_program_name%TYPE;
    l_date               DATE DEFAULT TRUNC(SYSDATE);
    cooling_times_allowed CONSTANT NUMBER := 10;
    cooling_time_frame    CONSTANT NUMBER := 365;
    l_cooling_allowed NUMBER;
    retval            NUMBER; --ST_BUNDLE1
  BEGIN
    BEGIN
      SELECT *
        INTO l_program_enroll_rec
        FROM x_program_enrolled
       WHERE objid = p_enrolled_objid;
    EXCEPTION
      WHEN others THEN
        op_result := -100;
        op_msg    := SQLCODE || SUBSTR(SQLERRM
                                      ,1
                                      ,100);
        RETURN;
    END;

    ------ Check if the cooling period change is allowed.
    SELECT COUNT(*)
      INTO l_cooling_allowed
      FROM x_program_trans
     WHERE pgm_tran2pgm_entrolled = p_enrolled_objid
       AND x_action_type = 'COOLING_PERIOD'
       AND x_trans_date BETWEEN SYSDATE - cooling_time_frame AND SYSDATE;

    IF (l_cooling_allowed > cooling_times_allowed) THEN
      op_result := 8001;
      op_msg    := 'Remove cooling attempt exceeds the number of times allowed';
      RETURN;
    END IF;

    IF l_program_enroll_rec.x_cooling_exp_date < l_date THEN
      op_result := 101;
      op_msg    := ' ESN is not in cooling Period';
    ELSE
      UPDATE x_program_enrolled
         SET x_cooling_exp_date  = NULL
            ,x_wait_exp_date     = NULL
            ,x_enrollment_status = 'READYTOREENROLL'
            ,x_update_stamp      = l_date
       WHERE objid = p_enrolled_objid;

      -- Get the program name
      SELECT x_program_name
        INTO l_program_name
        FROM x_program_parameters
       WHERE objid = l_program_enroll_rec.pgm_enroll2pgm_parameter;

      --ST_BUNDLE1
      retval := billing_global_insert_pkg.billing_insert_prog_trans(billing_seq('X_PROGRAM_TRANS')
                                                                   ,l_program_enroll_rec.x_enrollment_status
                                                                   ,'Cooling period is removed by WEBCSR'
                                                                   ,NULL
                                                                   ,NULL
                                                                   ,NULL
                                                                   ,SYSDATE
                                                                   ,'Cooling Period '
                                                                   ,'COOLING_PERIOD'
                                                                   ,l_program_name || ' Cooling Period removed'
                                                                   ,l_program_enroll_rec.x_sourcesystem
                                                                   ,l_program_enroll_rec.x_esn
                                                                   ,l_date
                                                                   ,l_date
                                                                   ,'I'
                                                                   ,NVL(p_user
                                                                       ,'System')
                                                                   ,l_program_enroll_rec.objid
                                                                   ,l_program_enroll_rec.pgm_enroll2web_user
                                                                   ,l_program_enroll_rec.pgm_enroll2site_part);
      /*INSERT
      INTO x_program_trans(
      objid,
      x_enrollment_status,
      x_enroll_status_reason,
      x_float_given,
      x_cooling_given,
      x_grace_period_given,
      x_trans_date,
      x_action_text,
      x_action_type,
      x_reason,
      x_sourcesystem,
      x_esn,
      x_exp_date,
      x_cooling_exp_date,
      x_update_status,
      x_update_user,
      pgm_tran2pgm_entrolled,
      pgm_trans2web_user,
      pgm_trans2site_part
      ) VALUES(
      billing_seq ('X_PROGRAM_TRANS'),
      l_program_enroll_rec.x_enrollment_status,
      'Cooling period is removed by WEBCSR',
      NULL,
      NULL,
      NULL,
      SYSDATE,
      'Cooling Period ',
      'COOLING_PERIOD',
      l_program_name || ' Cooling Period removed',
      l_program_enroll_rec.x_sourcesystem,
      l_program_enroll_rec.x_esn,
      l_date,
      l_date,
      'I',
      NVL (p_user, 'System'),
      l_program_enroll_rec.objid,
      l_program_enroll_rec.pgm_enroll2web_user,
      l_program_enroll_rec.pgm_enroll2site_part
      );*/
      --ST_BUNDLE1
    END IF;
  EXCEPTION
    WHEN others THEN
      op_result := -100;
      op_msg    := SQLCODE || SUBSTR(SQLERRM
                                    ,1
                                    ,100);

      IF (SQLCODE = -1400) THEN
        op_result := -1400;
        op_msg    := 'Entered is NULL';
      END IF;
  END remove_cooling_period;

  PROCEDURE transfer_esn_diff_act_online(
                                         -- p_esn IN x_program_enrolled.x_esn%TYPE,
                                         p_web_s_objid    IN x_program_enrolled.pgm_enroll2web_user%TYPE
                                        ,p_web_t_objid    IN x_program_enrolled.pgm_enroll2web_user%TYPE
                                        ,p_enroll_s_objid IN x_program_enrolled.objid%TYPE
                                        ,p_grace_period   IN NUMBER
                                        ,p_user           IN VARCHAR2
                                        ,op_result        OUT NUMBER
                                        ,op_msg           OUT VARCHAR2)
  -- DECLARE
    -- OP_RESULT NUMBER;
    -- OP_MSG VARCHAR2(200);
    -- BEGIN
    -- TRAC.BILLING_WEBCSR_PKG.TRANSFER_ESN_DIFF_ACT_ONLINE ( '10', 100, 600, 900, 10, 'BHAVANI', OP_RESULT, OP_MSG );
    -- --DBMS_OUTPUT.PUT_LINE('OP_RESULT = ' || TO_CHAR(OP_RESULT));
    -- --DBMS_OUTPUT.PUT_LINE('OP_MSG = ' || OP_MSG);
    -- END;
   IS
    l_count    NUMBER;
    enroll_rec x_program_enrolled%ROWTYPE;
    v_date     DATE DEFAULT TRUNC(SYSDATE);
    retval     NUMBER;
  BEGIN
    BEGIN
      SELECT *
        INTO enroll_rec
        FROM x_program_enrolled
       WHERE objid = p_enroll_s_objid;
    EXCEPTION
      WHEN no_data_found THEN
        op_result := SQLCODE;
        op_msg    := 'No data found';
    END;

    FOR idx IN (SELECT pgm_enroll2pgm_parameter
                  FROM x_program_enrolled
                 WHERE pgm_enroll2web_user = p_web_t_objid) LOOP
      SELECT COUNT(ROWID)
        INTO l_count
        FROM x_program_parameters
       WHERE objid = idx.pgm_enroll2pgm_parameter
         AND x_type = 'GROUP';

      IF enroll_rec.x_is_grp_primary = 1 THEN
        op_result := -100;
        op_msg    := 'This ESN is Primary hence ESN Can not be Transferred';
        EXIT;
      END IF;

      IF l_count > 0 THEN
        op_result := -100;
        op_msg    := 'Target Web Account has Group Plan hence ESN Can not be Transferred';
        EXIT;
      END IF;
    END LOOP;

    retval := billing_global_insert_pkg.billing_insert_prog_trans(billing_seq('X_PROGRAM_TRANS')
                                                                 ,enroll_rec.x_enrollment_status
                                                                 ,'Transferred Out'
                                                                 ,NULL
                                                                 ,NULL
                                                                 ,p_grace_period
                                                                 ,v_date
                                                                 ,'ESN #' || '' || enroll_rec.x_esn || '' || '' || ' Transferred OUT from' || p_web_s_objid || ' to Web Objid ' || '' || p_web_t_objid
                                                                 ,'TRANSFER'
                                                                 , -- OLD VALUE WAS PLAN_CHANGE
                                                                  'ESN Transferred to another Account'
                                                                 ,enroll_rec.x_sourcesystem
                                                                 ,enroll_rec.x_esn
                                                                 ,enroll_rec.x_exp_date
                                                                 ,NULL
                                                                 ,'I'
                                                                 ,p_user
                                                                 ,enroll_rec.objid
                                                                 ,enroll_rec.pgm_enroll2web_user
                                                                 ,enroll_rec.pgm_enroll2site_part);

    UPDATE x_program_enrolled
       SET pgm_enroll2web_user = p_web_t_objid
          ,
           -- x_exp_date = v_date + p_grace_period,
           x_update_stamp = v_date
          ,x_update_user  = p_user
     WHERE objid = p_enroll_s_objid;

    COMMIT;

    BEGIN
      SELECT *
        INTO enroll_rec
        FROM x_program_enrolled
       WHERE objid = p_enroll_s_objid;
    EXCEPTION
      WHEN no_data_found THEN
        op_result := SQLCODE;
        op_msg    := 'No data found';
    END;

    retval := billing_global_insert_pkg.billing_insert_prog_trans(billing_seq('X_PROGRAM_TRANS')
                                                                 ,enroll_rec.x_enrollment_status
                                                                 ,'Transferred IN'
                                                                 ,NULL
                                                                 ,NULL
                                                                 ,p_grace_period
                                                                 ,v_date
                                                                 ,'ESN #' || '' || enroll_rec.x_esn || '' || '' || 'Transferred IN from ' || p_web_s_objid || ' to Web Objid ' || '' || p_web_t_objid
                                                                 ,'TRANSFER'
                                                                 , -- OLD VALUE PLAN CHANGE
                                                                  'ESN Transferred to another Account'
                                                                 ,enroll_rec.x_sourcesystem
                                                                 ,enroll_rec.x_esn
                                                                 ,enroll_rec.x_exp_date
                                                                 ,NULL
                                                                 ,'I'
                                                                 ,p_user
                                                                 ,enroll_rec.objid
                                                                 ,enroll_rec.pgm_enroll2web_user
                                                                 ,enroll_rec.pgm_enroll2site_part);
  EXCEPTION
    WHEN others THEN
      op_result := -100;
      op_msg    := SQLCODE || SUBSTR(SQLERRM
                                    ,1
                                    ,100);

      IF (SQLCODE = -1400) THEN
        op_result := -1400;
        op_msg    := 'Entered is NULL';
      END IF;
  END transfer_esn_diff_act_online;

  PROCEDURE penalty_remove
  (
    p_penality_objid IN NUMBER
   ,p_user           IN VARCHAR2
   ,op_result        OUT NUMBER
   ,op_msg           OUT VARCHAR2
  ) IS
    l_date        DATE DEFAULT TRUNC(SYSDATE);
    l_penalty_rec x_program_penalty_pend%ROWTYPE;
    retval        NUMBER;
  BEGIN
    BEGIN
      UPDATE x_program_penalty_pend
         SET x_penalty_status = 'WAIVED'
            ,x_user           = p_user
       WHERE objid = p_penality_objid;
    EXCEPTION
      WHEN no_data_found THEN
        op_result := SQLCODE;
        op_msg    := SUBSTR(SQLERRM
                           ,1
                           ,100);
    END;

    SELECT *
      INTO l_penalty_rec
      FROM x_program_penalty_pend
     WHERE objid = p_penality_objid;

    --ST_BUNDLE1
    retval := billing_global_insert_pkg.billing_insert_prog_trans(billing_seq('X_PROGRAM_TRANS')
                                                                 ,NULL
                                                                 ,NULL
                                                                 ,NULL
                                                                 ,NULL
                                                                 ,NULL
                                                                 ,SYSDATE
                                                                 ,'PENALTY'
                                                                 ,'Penalty'
                                                                 ,'PENALTY ' || ' ' || '$' || l_penalty_rec.x_penalty_amt || ' ' || '' || 'IS WAIVED BY' || ' ' || '' || p_user || ''
                                                                 ,NULL
                                                                 ,l_penalty_rec.x_esn
                                                                 ,l_date
                                                                 ,l_date
                                                                 ,'I'
                                                                 ,l_penalty_rec.x_user
                                                                 ,l_penalty_rec.objid
                                                                 ,l_penalty_rec.penal_pend2web_user
                                                                 ,NULL);
    /* INSERT
    INTO x_program_trans(
    objid,
    x_enrollment_status,
    x_enroll_status_reason,
    x_float_given,
    x_cooling_given,
    x_grace_period_given,
    x_trans_date,
    x_action_text,
    x_action_type,
    x_reason,
    x_sourcesystem,
    x_esn,
    x_exp_date,
    x_cooling_exp_date,
    x_update_status,
    x_update_user,
    pgm_tran2pgm_entrolled,
    pgm_trans2web_user,
    pgm_trans2site_part
    ) VALUES(
    billing_seq ('X_PROGRAM_TRANS'),
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    SYSDATE,
    'PENALTY',
    'Penalty',
    'PENALTY ' || ' ' || '$' || l_penalty_rec.x_penalty_amt || ' ' || ''
    || 'IS WAIVED BY' || ' ' || '' || p_user || '',
    NULL,
    l_penalty_rec.x_esn,
    l_date,
    l_date,
    'I',
    l_penalty_rec.x_user,
    l_penalty_rec.objid,
    l_penalty_rec.penal_pend2web_user,
    NULL
    );*/ --ST_BUNDLE1
  EXCEPTION
    WHEN others THEN
      op_result := -100;
      op_msg    := SQLCODE || SUBSTR(SQLERRM
                                    ,1
                                    ,100);

      IF (SQLCODE = -1400) THEN
        op_result := -1400;
        op_msg    := 'Entered is NULL';
      END IF;
  END penalty_remove;

  /* This procedure no longer used. Kept for backreference */
  PROCEDURE transfer_esn_out(
                             --p_esn IN x_program_enrolled.x_esn%TYPE,
                             p_web_s_objid    IN x_program_enrolled.pgm_enroll2web_user%TYPE
                            ,p_web_t_objid    IN x_program_enrolled.pgm_enroll2web_user%TYPE
                            ,p_enroll_s_objid IN x_program_enrolled.objid%TYPE
                            ,p_grace_period   IN NUMBER
                            ,p_user           IN VARCHAR2
                            ,op_result        OUT NUMBER
                            ,op_msg           OUT VARCHAR2) IS
    l_count    NUMBER;
    enroll_rec x_program_enrolled%ROWTYPE;
    v_date     DATE DEFAULT TRUNC(SYSDATE);
    retval     NUMBER;
  BEGIN
    BEGIN
      SELECT *
        INTO enroll_rec
        FROM x_program_enrolled
       WHERE objid = p_enroll_s_objid;
    EXCEPTION
      WHEN no_data_found THEN
        op_result := SQLCODE;
        op_msg    := 'No data found';
    END;

    FOR idx IN (SELECT pgm_enroll2pgm_parameter
                  FROM x_program_enrolled
                 WHERE pgm_enroll2web_user = p_web_t_objid) LOOP
      SELECT COUNT(ROWID)
        INTO l_count
        FROM x_program_parameters
       WHERE objid = idx.pgm_enroll2pgm_parameter
         AND x_type = 'GROUP';

      IF enroll_rec.x_is_grp_primary = 1 THEN
        op_result := -100;
        op_msg    := 'This ESN is Primary hence ESN Can not be Transferred';
        EXIT;
      END IF;

      IF l_count > 0 THEN
        op_result := -100;
        op_msg    := 'Target Web Account has Group Plan hence ESN Can not be Transferred';
        EXIT;
      END IF;
    END LOOP;

    retval := billing_global_insert_pkg.billing_insert_prog_trans(billing_seq('X_PROGRAM_TRANS')
                                                                 ,enroll_rec.x_enrollment_status
                                                                 ,'Transferred Out'
                                                                 ,NULL
                                                                 ,NULL
                                                                 ,p_grace_period
                                                                 ,SYSDATE
                                                                 ,'ESN #' || '' || enroll_rec.x_esn || '' || '' || ' Transferred OUT from' || p_web_s_objid || ' to Web Objid ' || '' || p_web_t_objid
                                                                 ,'TRANSFER'
                                                                 , -- OLD VALUE WAS PLAN CHANGE
                                                                  'ESN Transferred to another Account'
                                                                 ,enroll_rec.x_sourcesystem
                                                                 ,enroll_rec.x_esn
                                                                 ,enroll_rec.x_exp_date
                                                                 ,NULL
                                                                 ,'I'
                                                                 ,p_user
                                                                 ,enroll_rec.objid
                                                                 ,enroll_rec.pgm_enroll2web_user
                                                                 ,enroll_rec.pgm_enroll2site_part);

    UPDATE x_program_enrolled
       SET pgm_enroll2web_user = p_web_t_objid
          ,x_wait_exp_date     = v_date + p_grace_period
          ,x_update_stamp      = v_date
          ,x_update_user       = p_user
     WHERE objid = p_enroll_s_objid;

    COMMIT;
  EXCEPTION
    WHEN others THEN
      op_result := -100;
      op_msg    := SQLCODE || SUBSTR(SQLERRM
                                    ,1
                                    ,100);

      IF (SQLCODE = -1400) THEN
        op_result := -1400;
        op_msg    := 'Entered is NULL';
      END IF;
  END transfer_esn_out;

  PROCEDURE transfer_esn_in(
                            -- p_esn IN x_program_enrolled.x_esn%TYPE,
                            p_web_s_objid    IN x_program_enrolled.pgm_enroll2web_user%TYPE
                           ,p_web_t_objid    IN x_program_enrolled.pgm_enroll2web_user%TYPE
                           ,p_enroll_s_objid IN x_program_enrolled.objid%TYPE
                           ,
                            -- p_grace_period IN NUMBER,
                            p_user    IN VARCHAR2
                           ,op_result OUT NUMBER
                           ,op_msg    OUT VARCHAR2) IS
    l_count    NUMBER;
    enroll_rec x_program_enrolled%ROWTYPE;
    v_date     DATE DEFAULT TRUNC(SYSDATE);
    retval     NUMBER;
  BEGIN
    BEGIN
      SELECT *
        INTO enroll_rec
        FROM x_program_enrolled
       WHERE objid = p_enroll_s_objid;
    EXCEPTION
      WHEN no_data_found THEN
        op_result := SQLCODE;
        op_msg    := 'No data found';
    END;

    FOR idx IN (SELECT pgm_enroll2pgm_parameter
                  FROM x_program_enrolled
                 WHERE pgm_enroll2web_user = p_web_t_objid) LOOP
      SELECT COUNT(ROWID)
        INTO l_count
        FROM x_program_parameters
       WHERE objid = idx.pgm_enroll2pgm_parameter
         AND x_type = 'GROUP';

      IF enroll_rec.x_is_grp_primary = 1 THEN
        op_result := -100;
        op_msg    := 'This ESN is Primary hence ESN Can not be Transferred';
        EXIT;
      END IF;

      IF l_count > 0 THEN
        op_result := -100;
        op_msg    := 'Target Web Account has Group Plan hence ESN Can not be Transferred';
        EXIT;
      END IF;
    END LOOP;

    UPDATE x_program_enrolled
       SET pgm_enroll2web_user = p_web_t_objid
          ,x_wait_exp_date     = NULL
          ,x_update_stamp      = v_date
          ,x_update_user       = p_user
     WHERE objid = p_enroll_s_objid;

    COMMIT;

    BEGIN
      SELECT *
        INTO enroll_rec
        FROM x_program_enrolled
       WHERE objid = p_enroll_s_objid;
    EXCEPTION
      WHEN no_data_found THEN
        op_result := SQLCODE;
        op_msg    := 'No data found';
    END;

    retval := billing_global_insert_pkg.billing_insert_prog_trans(billing_seq('X_PROGRAM_TRANS')
                                                                 ,enroll_rec.x_enrollment_status
                                                                 ,'Transferred IN'
                                                                 ,NULL
                                                                 ,NULL
                                                                 ,NULL
                                                                 ,SYSDATE
                                                                 ,'ESN #' || '' || enroll_rec.x_esn || '' || '' || 'Transferred IN from ' || p_web_s_objid || ' to Web Objid ' || '' || p_web_t_objid
                                                                 ,'TRANSFER'
                                                                 , -- OLD VALUE WAS PLAN CHANGE
                                                                  'ESN Transferred to another Account'
                                                                 ,enroll_rec.x_sourcesystem
                                                                 ,enroll_rec.x_esn
                                                                 ,enroll_rec.x_exp_date
                                                                 ,NULL
                                                                 ,'I'
                                                                 ,p_user
                                                                 ,enroll_rec.objid
                                                                 ,enroll_rec.pgm_enroll2web_user
                                                                 ,enroll_rec.pgm_enroll2site_part);
    COMMIT;
  EXCEPTION
    WHEN others THEN
      op_result := -100;
      op_msg    := SQLCODE || SUBSTR(SQLERRM
                                    ,1
                                    ,100);

      IF (SQLCODE = -1400) THEN
        op_result := -1400;
        op_msg    := 'Entered is NULL';
      END IF;
  END transfer_esn_in;

  /* Change the primary to a diffent ESN */
  PROCEDURE transfer_esn_same_acc
  (
    p_enroll_s_objid IN x_program_enrolled.objid%TYPE
   ,p_enroll_t_objid IN x_program_enrolled.objid%TYPE
   ,p_user           IN VARCHAR2
   ,op_result        OUT NUMBER
   ,op_msg           OUT VARCHAR2
  )
  -- DECLARE
    -- OP_RESULT NUMBER;
    -- OP_MSG VARCHAR2(200);
    -- BEGIN
    -- TRAC.BILLING_WEBCSR_PKG.TRANSFER_ESN_SAME_ACC ( 901, 900, 'settu', OP_RESULT, OP_MSG );
    -- --DBMS_OUTPUT.PUT_LINE('OP_RESULT = ' || TO_CHAR(OP_RESULT));
    -- --DBMS_OUTPUT.PUT_LINE('OP_MSG = ' || OP_MSG);
    -- END;
   IS
    l_count              NUMBER;
    l_primary1           NUMBER;
    l_primary2           NUMBER;
    retval               NUMBER;
    enroll_rec           x_program_enrolled%ROWTYPE;
    v_date               DATE DEFAULT TRUNC(SYSDATE);
    l_old_pymt_source    x_program_enrolled.pgm_enroll2x_pymt_src%TYPE;
    l_old_amount         x_program_enrolled.x_amount%TYPE;
    l_old_grp_primary    x_program_enrolled.x_is_grp_primary%TYPE;
    l_new_pymt_source    x_program_enrolled.pgm_enroll2x_pymt_src%TYPE;
    l_new_amount         x_program_enrolled.x_amount%TYPE;
    l_new_grp_primary    x_program_enrolled.x_is_grp_primary%TYPE;
    l_new_esn            x_program_enrolled.x_esn%TYPE;
    l_s_enroll_objid     NUMBER;
    l_contact_first_name table_contact.first_name%TYPE;
    l_contact_last_name  table_contact.last_name%TYPE;
  BEGIN
    /* When a Group primary is changed
    1. Funding source of the old ESN is moved to the new ESN
    2. Group primary settings are altered accordingly.
    */
    IF (p_enroll_t_objid IS NULL) THEN
      -- No change in primary.
      op_result := 4501;
      op_msg    := 'Null value passed.';
      RETURN;
    END IF;

    -- Check for source and target.
    IF (p_enroll_s_objid = p_enroll_t_objid) THEN
      -- No change in primary.
      op_result := 4502;
      op_msg    := 'No change in primary enrollment.';
      RETURN;
    END IF;

    -- Ensure that the old ESN is indeed a primary esn.
    BEGIN
      SELECT pgm_enroll2pgm_group
        INTO l_s_enroll_objid
        FROM x_program_enrolled
       WHERE objid = p_enroll_t_objid;

      SELECT pgm_enroll2x_pymt_src
            ,x_amount
            ,x_is_grp_primary
        INTO l_old_pymt_source
            ,l_old_amount
            ,l_old_grp_primary
        FROM x_program_enrolled
       WHERE objid = (l_s_enroll_objid);
    EXCEPTION
      WHEN no_data_found THEN
        op_result := 4503;
        op_msg    := 'Group primary link missing for enrollment ' || TO_CHAR(p_enroll_t_objid);
        RETURN;
    END;

    /*
    if ( l_old_grp_primary != 1 ) then
    op_result := 4503;
    op_msg := 'Old enrollment is not a group primary.';
    return;
    end if;
    */
    -- Get the values stored for the target enrollment
    -- Ensure that the old ESN is indeed a primary esn.
    SELECT pgm_enroll2x_pymt_src
          ,x_amount
          ,x_esn
      INTO l_new_pymt_source
          ,l_new_amount
          ,l_new_esn
      FROM x_program_enrolled
     WHERE objid = p_enroll_t_objid;

    -- update the new primary record
    UPDATE x_program_enrolled
       SET x_is_grp_primary      = 1
          ,pgm_enroll2pgm_group  = NULL
          ,x_amount              = l_old_amount
          ,pgm_enroll2x_pymt_src = NVL(l_old_pymt_source
                                      ,l_new_pymt_source)
     WHERE objid = p_enroll_t_objid;

    -- Move all additional phones to the new primary
    UPDATE x_program_enrolled
       SET pgm_enroll2pgm_group = p_enroll_t_objid
          ,x_is_grp_primary     = 0
     WHERE (pgm_enroll2pgm_group = l_s_enroll_objid OR objid = l_s_enroll_objid);

    -- update the source program records.
    UPDATE x_program_enrolled
       SET x_is_grp_primary      = 0
          ,x_amount              = l_new_amount
          ,pgm_enroll2x_pymt_src = l_new_pymt_source
     WHERE objid = l_s_enroll_objid;

    /*
    SELECT COUNT (*)
    INTO l_count
    FROM x_payment_source ps
    WHERE objid = (SELECT pgm_enroll2x_pymt_src
    FROM x_program_enrolled
    WHERE objid = p_enroll_t_objid)
    AND ps.pymt_src2web_user = (SELECT pgm_enroll2web_user
    FROM x_program_enrolled
    WHERE objid = p_enroll_t_objid);

    BEGIN
    SELECT x_is_grp_primary
    INTO l_primary1
    FROM x_program_enrolled
    WHERE objid = p_enroll_t_objid;
    EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
    op_result := SQLCODE;
    op_msg := 'No Record found Source ESN';
    END;

    BEGIN
    SELECT x_is_grp_primary
    INTO l_primary2
    FROM x_program_enrolled
    WHERE objid = p_enroll_s_objid;
    EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
    op_result := SQLCODE;
    op_msg := 'No Record found Source ESN';
    END;

    FOR idx IN 1 .. 1
    LOOP
    IF l_primary2 = 0
    THEN
    op_result := -100;
    op_msg := 'Source ESN is not a Primary';
    EXIT;
    END IF;
    END LOOP;

    IF l_count = 0
    THEN
    op_result := -100;
    op_msg := 'This ESN does not have Payment Source';
    ELSE
    IF l_primary1 = 1
    THEN
    --op_result := -101;
    --op_msg := 'This ESN is already Primary for the Group';
    -- Already a primary. No need to do anything.
    RETURN;
    END IF;

    UPDATE x_program_enrolled
    SET x_is_grp_primary = 1,
    X_UPDATE_STAMP=v_date
    WHERE objid = p_enroll_t_objid;

    COMMIT;

    UPDATE x_program_enrolled
    SET x_is_grp_primary = 0,
    X_UPDATE_STAMP=v_date
    WHERE objid = p_enroll_s_objid;

    COMMIT;
    */
    BEGIN
      SELECT *
        INTO enroll_rec
        FROM x_program_enrolled
       WHERE objid = l_s_enroll_objid;
    EXCEPTION
      WHEN no_data_found THEN
        op_result := SQLCODE;
        op_msg    := 'No data found in Enrollment';
        RETURN;
    END;

    retval := billing_global_insert_pkg.billing_insert_prog_trans(billing_seq('X_PROGRAM_TRANS')
                                                                 ,enroll_rec.x_enrollment_status
                                                                 ,'Changed Account Primary'
                                                                 ,NULL
                                                                 ,NULL
                                                                 ,NULL
                                                                 ,SYSDATE
                                                                 ,'Group primary update'
                                                                 ,'PRIMARY_UPDATE'
                                                                 ,'Group primary changed from ' || enroll_rec.x_esn || ' to ' || l_new_esn
                                                                 ,enroll_rec.x_sourcesystem
                                                                 ,enroll_rec.x_esn
                                                                 ,enroll_rec.x_exp_date
                                                                 ,NULL
                                                                 ,'I'
                                                                 ,p_user
                                                                 ,enroll_rec.objid
                                                                 ,enroll_rec.pgm_enroll2web_user
                                                                 ,enroll_rec.pgm_enroll2site_part);

    --- Get the contact details for logging
    SELECT first_name
          ,last_name
      INTO l_contact_first_name
          ,l_contact_last_name
      FROM table_contact
     WHERE objid = (SELECT web_user2contact
                      FROM table_web_user
                     WHERE objid = enroll_rec.pgm_enroll2web_user);

    ---- Log the transaction in the log table as well.
    INSERT INTO x_billing_log
      (objid
      ,x_log_category
      ,x_log_title
      ,x_log_date
      ,x_details
      ,x_nickname
      ,x_esn
      ,x_originator
      ,x_contact_first_name
      ,x_contact_last_name
      ,x_agent_name
      ,x_sourcesystem
      ,billing_log2web_user)
    VALUES
      (billing_seq('X_BILLING_LOG')
      ,'ESN'
      ,'Change Group Primary'
      ,SYSDATE
      ,'Group primary changed from ' || enroll_rec.x_esn || ' to ' || l_new_esn
      ,billing_getnickname(l_new_esn)
      ,l_new_esn
      ,p_user
      ,l_contact_first_name
      ,l_contact_last_name
      ,p_user
      ,enroll_rec.x_sourcesystem
      ,enroll_rec.pgm_enroll2web_user);

    -- END IF;
    op_result := 0;
    op_msg    := 'Group primary changed successfully.';
    COMMIT;
  EXCEPTION
    WHEN others THEN
      op_result := -100;
      op_msg    := SQLCODE || SUBSTR(SQLERRM
                                    ,1
                                    ,100);

      IF (SQLCODE = -1400) THEN
        op_result := -1400;
        op_msg    := 'Entered is NULL';
      END IF;
  END transfer_esn_same_acc;

  PROCEDURE transfer_esn_to_diff_act
  (
    p_esn         IN x_program_enrolled.x_esn%TYPE
   ,p_web_s_objid IN x_program_enrolled.pgm_enroll2web_user%TYPE
   ,p_web_t_objid IN x_program_enrolled.pgm_enroll2web_user%TYPE
   ,p_user        IN VARCHAR2
   ,op_result     OUT NUMBER
   ,op_msg        OUT VARCHAR2
  ) IS
    l_count             NUMBER;
    enroll_rec          x_program_enrolled%ROWTYPE;
    v_date              DATE DEFAULT TRUNC(SYSDATE);
    l_contact_objid     NUMBER;
    l_new_contact_objid NUMBER;
    retval              NUMBER;
    b2b_count           NUMBER; ------CR13581

    CURSOR funding_source_cursor
    (
      c_esn         IN x_program_enrolled.x_esn%TYPE
     ,c_web_s_objid IN x_program_enrolled.pgm_enroll2web_user%TYPE
     ,c_web_t_objid IN x_program_enrolled.pgm_enroll2web_user%TYPE
    ) IS
      SELECT ps.objid
            ,ps.x_pymt_type
            ,ps.x_pymt_src_name
        FROM x_payment_source ps
            ,(              (SELECT 'CREDITCARD' x_payment_type
                              FROM dual
                            UNION
                            SELECT 'DEBITCARD' x_payment_type
                              FROM dual
                            UNION
                            SELECT 'ACH' x_payment_type
                              FROM dual
                            UNION
                            SELECT 'PAYPAL' x_payment_type
                              FROM dual)                MINUS
               SELECT DISTINCT (a.x_payment_type)
                 FROM x_mtm_restricted_pymtmode a
                     ,x_program_enrolled        b
                WHERE a.program_param_objid = b.pgm_enroll2pgm_parameter
                  AND b.pgm_enroll2web_user = c_web_s_objid
                  AND b.x_esn = c_esn
                  AND b.x_enrollment_status NOT IN ('DEENROLLED')) cps
                WHERE ps.x_pymt_type = cps.x_payment_type
                  AND ps.x_status = 'ACTIVE'
                  AND ps.pymt_src2web_user = c_web_t_objid
                ORDER BY ps.x_is_default DESC;


    funding_source_rec funding_source_cursor%ROWTYPE;
    ----- Get the funding for the new account.
    l_funding_source_objid NUMBER;
    l_funding_source_check NUMBER;
    -- Variable to check if funding source check is required or not
  BEGIN
    ---- Do the compatible funding source check, only if there are programs associated with the ESN
    SELECT COUNT(*)
      INTO l_funding_source_check
      FROM x_program_enrolled
     WHERE pgm_enroll2web_user = p_web_s_objid
       AND x_esn = p_esn
       AND x_enrollment_status IN ('ENROLLED'
                                  ,'SUSPENDED'
                                  ,'ENROLLMENTPENDING');

    IF (l_funding_source_check > 0) THEN
      ----- Get the compatible funding source for the new web user.
      OPEN funding_source_cursor(p_esn
                                ,p_web_s_objid
                                ,p_web_t_objid);

      FETCH funding_source_cursor
        INTO funding_source_rec;

      IF funding_source_cursor%NOTFOUND THEN
        -- No compatible funding sources found in the new account.
        op_result := 6001;
        op_msg    := 'No compatible funding sources found for the new account';

        CLOSE funding_source_cursor;

        -- All programs are moved into wait period till a compatible funding source is added.
        INSERT INTO x_program_trans
          (objid
          ,x_enrollment_status
          ,x_enroll_status_reason
          ,x_float_given
          ,x_cooling_given
          ,x_grace_period_given
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
          ,pgm_trans2web_user
          ,pgm_trans2site_part)
          SELECT billing_seq('X_PROGRAM_TRANS')
                ,x_enrollment_status
                ,'Transferring ESN - No compatible funding sources found'
                ,NULL
                ,NULL
                ,NULL
                ,SYSDATE
                ,'Transfer ESN ' || p_esn
                ,

                 -- Modified for Defect 594
                 'TRANSFER'
                , -- OLD VALUE WAS PLAN CHANGE
                 'Transfer ESN to another account - No compatible funding source found. Applying wait period of 10 days'
                ,x_sourcesystem
                ,x_esn
                ,NULL
                ,NULL
                ,'I'
                ,p_user
                ,objid
                ,pgm_enroll2web_user
                ,pgm_enroll2site_part
            FROM x_program_enrolled
           WHERE x_esn = p_esn
             AND pgm_enroll2web_user = p_web_s_objid;

        UPDATE x_program_enrolled
           SET x_wait_exp_date = SYSDATE + 10
         WHERE x_esn = p_esn
           AND pgm_enroll2web_user = p_web_s_objid;

        COMMIT;
        -- Added for Defect 594
        op_result := 0;
        op_msg    := 'No compatible funding sources found for the new account';
        RETURN;
      END IF;

      CLOSE funding_source_cursor;
    END IF;

    /*
    BEGIN
    select objid into l_funding_source_objid from x_payment_source where PYMT_SRC2WEB_USER = p_web_t_objid and X_IS_DEFAULT = 1;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    -- There is no default funding source available for the webuser
    NULL;
    END;
    */
    ------------- Check if there are any programs to be transferred
    FOR idx IN (SELECT *
                  FROM x_program_enrolled
                 WHERE pgm_enroll2web_user = p_web_s_objid
                   AND x_esn = p_esn) LOOP
      BEGIN
        SELECT COUNT(ROWID)
          INTO l_count
          FROM x_program_parameters
         WHERE objid = idx.pgm_enroll2pgm_parameter
           AND x_type = 'GROUP';
      EXCEPTION
        WHEN no_data_found THEN
          op_result := SQLCODE;
          op_msg    := ' No data found programs';
      END;

      --If b2b needs to behave like GROUP ---CR13581
      SELECT COUNT(*)
        INTO b2b_count
        FROM table_web_user
            ,x_business_accounts
            ,x_program_enrolled
       WHERE web_user2contact = bus_primary2contact
         AND pgm_enroll2web_user = table_web_user.objid
         AND x_program_enrolled.objid = idx.objid; ----CR13581

      IF (l_count > 0 OR b2b_count > 0) ---CR13581
         AND idx.x_enrollment_status IN ('ENROLLED'
                                        ,'SUSPENDED') THEN
        op_result := -100;
        op_msg    := 'Source ESN is already enrolled into a Group Program. Transfer cannot be done';
      ELSE
        retval := billing_global_insert_pkg.billing_insert_prog_trans(billing_seq('X_PROGRAM_TRANS')
                                                                     ,idx.x_enrollment_status
                                                                     ,'Transferred Out'
                                                                     ,NULL
                                                                     ,NULL
                                                                     ,NULL
                                                                     ,SYSDATE
                                                                     ,'ESN #' || '' || idx.x_esn || '' || '' || ' Transferred Web User' || p_web_s_objid || ' to Web Objid ' || '' || p_web_t_objid
                                                                     ,'TRANSFER'
                                                                     , -- OLD VALUE WAS PLAN CHANGE
                                                                      'ESN Transferred to another Account'
                                                                     ,idx.x_sourcesystem
                                                                     ,idx.x_esn
                                                                     ,idx.x_exp_date
                                                                     ,NULL
                                                                     ,'I'
                                                                     ,p_user
                                                                     ,enroll_rec.objid
                                                                     ,enroll_rec.pgm_enroll2web_user
                                                                     ,enroll_rec.pgm_enroll2site_part);

        UPDATE x_program_enrolled
           SET pgm_enroll2web_user   = p_web_t_objid
              ,x_update_stamp        = v_date
              ,x_update_user         = p_user
              ,pgm_enroll2pgm_group  = NULL
              , ------CR13581
               pgm_enroll2x_pymt_src = funding_source_rec.objid
              ,x_wait_exp_date       = NULL -- Remove wait period, if any
         WHERE pgm_enroll2web_user = p_web_s_objid
           AND x_esn = p_esn;
      END IF;
    END LOOP;

    ---- All the programs are transferred. Transfer out the ESN to the new account as well.
    -- Update the transfer flag in the ESN to transfer out.
    SELECT web_user2contact
      INTO l_contact_objid
      FROM table_web_user
     WHERE objid = p_web_s_objid; --Always gives only one record.

    SELECT web_user2contact
      INTO l_new_contact_objid
      FROM table_web_user
     WHERE objid = p_web_t_objid; --Always gives only one record.

    UPDATE table_x_contact_part_inst
       SET x_contact_part_inst2contact = l_new_contact_objid
     WHERE x_contact_part_inst2contact = l_contact_objid
       AND x_contact_part_inst2part_inst = (SELECT objid
                                              FROM table_part_inst
                                             WHERE part_serial_no = p_esn);

    COMMIT;
  EXCEPTION
    WHEN others THEN
      op_result := -100;
      op_msg    := SQLCODE || SUBSTR(SQLERRM
                                    ,1
                                    ,100);

      IF (SQLCODE = -1400) THEN
        op_result := -1400;
        op_msg    := 'Entered is NULL';
      END IF;
  END transfer_esn_to_diff_act;

  PROCEDURE transfer_prog_to_diff_act
  (
    p_enroll_objid IN x_program_enrolled.objid%TYPE
   ,p_web_s_objid  IN x_program_enrolled.pgm_enroll2web_user%TYPE
   ,p_web_t_objid  IN x_program_enrolled.pgm_enroll2web_user%TYPE
   ,p_user         IN VARCHAR2
   ,op_result      OUT NUMBER
   ,op_msg         OUT VARCHAR2
  ) IS
    l_count             NUMBER;
    enroll_rec          x_program_enrolled%ROWTYPE;
    v_date              DATE DEFAULT TRUNC(SYSDATE);
    l_contact_objid     NUMBER;
    l_new_contact_objid NUMBER;
    retval              NUMBER;
  BEGIN
    ------------- Check if there are any programs to be transferred
    FOR idx IN (SELECT *
                  FROM x_program_enrolled
                 WHERE objid = p_enroll_objid) LOOP
      BEGIN
        SELECT COUNT(ROWID)
          INTO l_count
          FROM x_program_parameters
         WHERE objid = idx.pgm_enroll2pgm_parameter
           AND x_type = 'GROUP';
      EXCEPTION
        WHEN no_data_found THEN
          op_result := SQLCODE;
          op_msg    := ' No data found programs';
      END;

      IF l_count > 0 THEN
        op_result := -100;
        op_msg    := 'The program to be transferred is enrolled into a group program. This is not permitted.';
      ELSE
        retval := billing_global_insert_pkg.billing_insert_prog_trans(billing_seq('X_PROGRAM_TRANS')
                                                                     ,idx.x_enrollment_status
                                                                     ,'Transferred Out'
                                                                     ,NULL
                                                                     ,NULL
                                                                     ,NULL
                                                                     ,SYSDATE
                                                                     ,'Program #' || '' || enroll_rec.objid || '' || '' || ' Transferred Web User' || p_web_s_objid || ' to Web Objid ' || '' || p_web_t_objid
                                                                     ,'TRANSFER'
                                                                     , -- OLD VALUE WAS PLAN CHANGE
                                                                      'ESN Transferred to another Account'
                                                                     ,idx.x_sourcesystem
                                                                     ,idx.x_esn
                                                                     ,idx.x_exp_date
                                                                     ,NULL
                                                                     ,'I'
                                                                     ,p_user
                                                                     ,enroll_rec.objid
                                                                     ,enroll_rec.pgm_enroll2web_user
                                                                     ,enroll_rec.pgm_enroll2site_part);

        UPDATE x_program_enrolled
           SET pgm_enroll2web_user = p_web_t_objid
              ,x_update_stamp      = v_date
              ,x_update_user       = p_user
         WHERE objid = p_enroll_objid;

        ---- All the programs are transferred. Transfer out the ESN to the new account as well.
        -- Update the transfer flag in the ESN to transfer out.
        SELECT web_user2contact
          INTO l_contact_objid
          FROM table_web_user
         WHERE objid = p_web_s_objid; --Always gives only one record.

        SELECT web_user2contact
          INTO l_new_contact_objid
          FROM table_web_user
         WHERE objid = p_web_t_objid; --Always gives only one record.

        UPDATE table_x_contact_part_inst
           SET x_contact_part_inst2contact = l_new_contact_objid
         WHERE x_contact_part_inst2contact = l_contact_objid
           AND x_contact_part_inst2part_inst = (SELECT objid
                                                  FROM table_part_inst
                                                 WHERE part_serial_no = idx.x_esn);
      END IF;
    END LOOP;

    COMMIT;
  EXCEPTION
    WHEN others THEN
      op_result := -100;
      op_msg    := SQLCODE || SUBSTR(SQLERRM
                                    ,1
                                    ,100);

      IF (SQLCODE = -1400) THEN
        op_result := -1400;
        op_msg    := 'Entered is NULL';
      END IF;
  END transfer_prog_to_diff_act;

  PROCEDURE transfer_out_esn_pgms
  (
    p_web_s_objid    IN x_program_enrolled.pgm_enroll2web_user%TYPE
   ,p_esn            IN x_program_enrolled.x_esn%TYPE
   ,p_enroll_s_objid IN x_program_enrolled.objid%TYPE
   ,
    --List of enrolled programs that need to be transferred.
    p_grace_period IN NUMBER
   ,p_user         IN VARCHAR2
   ,op_result      OUT NUMBER
   ,op_msg         OUT VARCHAR2
  ) IS
    sqlstring       VARCHAR2(2000);
    l_contact_objid NUMBER;
  BEGIN
    IF (p_enroll_s_objid IS NOT NULL) THEN
      -- Update the x_enrollment status to 'SUSPENDED' and set the ESN transfer flag to 1.
      sqlstring := 'update x_program_enrolled set x_wait_exp_date = NVL(sysdate + ' || p_grace_period || ', sysdate + 10) where objid IN (' || p_enroll_s_objid || ')';

      EXECUTE IMMEDIATE sqlstring;
      -- Insert into program_trans pending.
    END IF;

    -- Update the transfer flag in the ESN to transfer out.
    BEGIN
      SELECT web_user2contact
        INTO l_contact_objid
        FROM table_web_user
       WHERE objid = p_web_s_objid; --Always gives only one record.
    EXCEPTION
      WHEN others THEN
        op_result := SQLCODE;
        op_msg    := SUBSTR(SQLERRM
                           ,1
                           ,100);
    END;

    UPDATE table_x_contact_part_inst
       SET x_transfer_flag = 1
     WHERE x_contact_part_inst2contact = l_contact_objid
       AND x_contact_part_inst2part_inst = (SELECT objid
                                              FROM table_part_inst
                                             WHERE part_serial_no = p_esn);

    COMMIT;
    op_result := 0;
    op_msg    := 'Success';
  EXCEPTION
    WHEN others THEN
      op_result := -100;
      op_msg    := SQLCODE || SUBSTR(SQLERRM
                                    ,1
                                    ,100);
  END transfer_out_esn_pgms;

  /*
  Procedure to transfer a program from one ESN to another.
  */
  PROCEDURE transfer_prog_to_diff_esn(p_enroll_s_objid IN x_program_enrolled.objid%TYPE
                                     ,
                                      -- Enrollment that needs transferring.
                                      p_esn IN x_program_enrolled.x_esn%TYPE
                                     ,
                                      -- ESN to which to transfer to.
                                      p_user IN VARCHAR2
                                     ,
                                      -- WEBCSR User Initiating the transfer
                                      op_result OUT NUMBER
                                     ,op_msg    OUT VARCHAR2) IS
    CURSOR enrollment_c(c_enroll_id NUMBER) IS
--      SELECT *
--        FROM x_program_enrolled
--       WHERE objid = c_enroll_id;
--CR22380 Handset protection, modified cursor to exclude programs which are not eligible for transferring.
      SELECT pe.*
        FROM x_program_enrolled pe,
             x_program_parameters pp
       WHERE pe.objid = c_enroll_id
        and  pp.objid = pe.pgm_enroll2pgm_parameter
        and  not exists (select 'X'
                         from   table_x_parameters
                         WHERE  X_PARAM_NAME = 'NOT ELIGIBLE FOR TRANSFERRING'
                         and    x_param_value = pp.x_prog_class);

    enrollment_rec enrollment_c%ROWTYPE;
    l_canenroll    NUMBER;
    retval         NUMBER; --ST_BUNDLE1
  BEGIN
    OPEN enrollment_c(p_enroll_s_objid);

    FETCH enrollment_c
      INTO enrollment_rec;

    IF (enrollment_c%NOTFOUND) THEN
      op_result := -100;
      op_msg    := 'No Enrollment Record found for transfer';

      CLOSE enrollment_c;

      RETURN;
    END IF;

    CLOSE enrollment_c;

    -- Since the transfer is happenning to a different ESN, transfer the funding source also to the
    -- other ESN if there is no funding source attached.
    -- Check if the program assocated with the new ESN are combinable with the program being transferred.
    FOR idx IN (SELECT DISTINCT (pgm_enroll2pgm_parameter) programid
                  FROM x_program_enrolled
                 WHERE x_esn = p_esn
                   AND x_enrollment_status IN ('ENROLLED'
                                              ,'SUSPENDED'
                                              ,'ENROLLMENTPENDING'
                                              ,'ENROLLMENTSCHEDULED'
                                              ,'DEENROLLED')) LOOP
      l_canenroll := canenroll(enrollment_rec.pgm_enroll2web_user
                              ,p_esn
                              ,idx.programid
                              ,1);

      IF (l_canenroll IN (1
                         ,2
                         ,3
                         ,4
                         ,8001
                         ,8007
                         ,7511)) THEN
        -- All ok to enroll.
        -- Allow CoolingPeriod transfers
        NULL;
      ELSE
        op_result := l_canenroll;
        op_msg    := 'Cannot transfer the program to the ESN';
        -- EXIT;
      END IF;
    END LOOP;

    IF (op_result = 0 OR op_result IS NULL) THEN
      -- Lets transfer the programs now.
      --ST_BUNDLE1
      retval := billing_global_insert_pkg.billing_insert_prog_trans(billing_seq('X_PROGRAM_TRANS')
                                                                   ,enrollment_rec.x_enrollment_status
                                                                   ,NULL
                                                                   ,NULL
                                                                   ,NULL
                                                                   ,NULL
                                                                   ,SYSDATE
                                                                   ,'Transfer Program to ESN ' || p_esn
                                                                   ,'TRANSFER'
                                                                   ,'Program Transferred to another ESN'
                                                                   ,enrollment_rec.x_sourcesystem
                                                                   ,enrollment_rec.x_esn
                                                                   ,NULL
                                                                   ,NULL
                                                                   ,'I'
                                                                   ,'sa'
                                                                   ,enrollment_rec.objid
                                                                   ,enrollment_rec.pgm_enroll2web_user
                                                                   ,enrollment_rec.pgm_enroll2site_part);

      /*INSERT
      INTO x_program_trans(
      objid,
      x_enrollment_status,
      x_enroll_status_reason,
      x_float_given,
      x_cooling_given,
      x_grace_period_given,
      x_trans_date,
      x_action_text,
      x_action_type,
      x_reason,
      x_sourcesystem,
      x_esn,
      x_exp_date,
      x_cooling_exp_date,
      x_update_status,
      x_update_user,
      pgm_tran2pgm_entrolled,
      pgm_trans2web_user,
      pgm_trans2site_part
      ) VALUES(
      billing_seq ('X_PROGRAM_TRANS'),
      enrollment_rec.x_enrollment_status,
      NULL,
      NULL,
      NULL,
      NULL,
      SYSDATE,
      'Transfer Program to ESN ' || p_esn,
      'TRANSFER', -- OLD VALUE WAS PLAN CHANGE
      'Program Transferred to another ESN',
      enrollment_rec.x_sourcesystem,
      enrollment_rec.x_esn,
      NULL,
      NULL,
      'I',
      'sa',
      enrollment_rec.objid,
      enrollment_rec.pgm_enroll2web_user,
      enrollment_rec.pgm_enroll2site_part
      );*/
      --ST_BUNDLE1
      UPDATE x_program_enrolled
         SET x_esn           = p_esn
            ,x_wait_exp_date = NULL
       WHERE objid = p_enroll_s_objid;

      op_result := 0;
      op_msg    := 'Success';
    END IF;
  EXCEPTION
    WHEN others THEN
      op_result := -100;
      op_msg    := SQLCODE || SUBSTR(SQLERRM
                                    ,1
                                    ,100);
  END transfer_prog_to_diff_esn;

  PROCEDURE transfer_progs_to_diff_esn(p_enroll_s_objid IN VARCHAR2
                                      ,
                                       -- ',' separated list of objids for transfer
                                       p_esn IN x_program_enrolled.x_esn%TYPE
                                      ,
                                       -- ESN to which to transfer to.
                                       p_user IN VARCHAR2
                                      ,
                                       -- WEBCSR User Initiating the transfer
                                       op_result OUT NUMBER
                                      ,op_msg    OUT VARCHAR2) IS
    l_temp_prog_enroll_objid VARCHAR2(30);
    l_enroll_s_objid         VARCHAR2(4000);
    l_index                  NUMBER;
  BEGIN
    -- Parse the string of objids, and transfer it to the programs.
    -- Append a ',' to the end if the last character is not a string.
    IF (p_enroll_s_objid IS NOT NULL) THEN
      l_enroll_s_objid := p_enroll_s_objid;

      IF (SUBSTR(l_enroll_s_objid
                ,LENGTH(l_enroll_s_objid)) != ',') THEN
        l_enroll_s_objid := l_enroll_s_objid || ',';
      END IF;
    END IF;

    WHILE (l_enroll_s_objid IS NOT NULL) LOOP
      l_index                  := INSTR(l_enroll_s_objid
                                       ,',');
      l_temp_prog_enroll_objid := SUBSTR(l_enroll_s_objid
                                        ,1
                                        ,l_index - 1);
      transfer_prog_to_diff_esn(l_temp_prog_enroll_objid
                               ,p_esn
                               ,p_user
                               ,op_result
                               ,op_msg);

      IF (op_result != 0) THEN
        ROLLBACK;
        RETURN;
      END IF;

      l_enroll_s_objid := SUBSTR(l_enroll_s_objid
                                ,l_index + 1);
    END LOOP;

    op_result := 0;
    op_msg    := 'Success';
    COMMIT;
  EXCEPTION
    WHEN others THEN
      op_result := -100;
      op_msg    := SQLCODE || SUBSTR(SQLERRM
                                    ,1
                                    ,100);
  END transfer_progs_to_diff_esn;

  /*
  This procedure is used the transfer out the ESN from the current accout.
  All the enrolled programs are put into indefinite wait period unless specified.
  */
  PROCEDURE transfer_out_esn
  (
    p_web_user_objid IN NUMBER
   ,p_esn            IN x_program_enrolled.x_esn%TYPE
   ,p_wait_period    IN NUMBER
   ,
    -- By Default, we will wait indefinitely, till the new user transfers in.
    p_user    IN VARCHAR2
   ,op_result OUT NUMBER
   ,op_msg    OUT VARCHAR2
  ) IS
    l_count   NUMBER;
    b2b_count NUMBER; --------CR13581

  BEGIN
    -- Check if the customer is enrolled into any of the existing group programs.
    SELECT COUNT(*)
      INTO l_count
      FROM x_program_enrolled   a
          ,x_program_parameters b
     WHERE a.pgm_enroll2pgm_parameter = b.objid
       AND b.x_type = 'GROUP'
       AND a.x_enrollment_status IN ('ENROLLED'
                                    ,'ENROLLMENTPENDING'
                                    ,'ENROLLMENTSCHEDULED')
       AND a.x_wait_exp_date IS NULL
       AND a.x_esn = p_esn
       AND a.pgm_enroll2web_user = p_web_user_objid;
    ------CR13581
    SELECT COUNT(*)
      INTO b2b_count
      FROM table_web_user
          ,x_business_accounts
          ,x_program_enrolled
     WHERE web_user2contact = bus_primary2contact
       AND pgm_enroll2web_user = table_web_user.objid
       AND x_program_enrolled.x_esn = p_esn
       AND x_enrollment_status IN ('ENROLLED'
                                  ,'SUSPENDED'); ------CR13581

    --DBMS_OUTPUT.PUT_LINE('Count for Group is retrieved as ' || l_count);

    IF (l_count > 0 OR b2b_count > 0) -------CR13581
     THEN
      -- Customer is still enrolled into GROUP program. Do not allow transfer out.
      op_result := 8001;
      op_msg    := 'Since you are enrolled into Group program, this ESN cannot be transferred out';
      RETURN;
    END IF;

    --- Transfer all the programs associated with the ESN.
    --- This means suspending all the benefits. This is achieved by putting the enrollment into wait state
    --- for a specified period after which the ESN will get de-enrolled and cooling period get applied.
    -- If there are any programs associated with the ESN, suspend the programs, and disassociate with the webuser.
    --DBMS_OUTPUT.PUT_LINE('Creating Trans Records. ');

    BEGIN
      --- Insert records into program trans.
      INSERT INTO x_program_trans
        (objid
        ,x_enrollment_status
        ,x_enroll_status_reason
        ,x_float_given
        ,x_cooling_given
        ,x_grace_period_given
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
        ,pgm_trans2web_user
        ,pgm_trans2site_part)
        SELECT billing_seq('X_PROGRAM_TRANS')
              ,x_enrollment_status
              ,'ESN Requested for Transfering out'
              ,NULL
              ,NULL
              ,NVL(p_wait_period
                  ,999)
              ,SYSDATE
              ,'Transfer Out from the Account'
              ,'TRANSFER'
              ,'Program ' || (SELECT x_program_name
                                FROM x_program_parameters
                               WHERE objid = pgm_enroll2pgm_parameter) || ' is transferred out from the Account'
              ,x_sourcesystem
              ,x_esn
              ,x_exp_date
              ,x_cooling_exp_date
              ,'I'
              ,p_user
              ,objid
              ,pgm_enroll2web_user
              ,pgm_enroll2site_part
          FROM x_program_enrolled
         WHERE x_esn = p_esn
           AND pgm_enroll2web_user = p_web_user_objid
           AND x_enrollment_status NOT IN ('READYTOREENROLL'
                                          ,'DEENROLLED'
                                          ,'ENROLLMENTBLOCKED');
    EXCEPTION
      WHEN others THEN
        --DBMS_OUTPUT.PUT_LINE('Exception Raised ');
        --DBMS_OUTPUT.PUT_LINE(SQLERRM);
        NULL;
        --- If there are no records selected for insert - catch the error.
    END;

    --DBMS_OUTPUT.PUT_LINE('Marking the ESN for transferring out. ');

    --- Mark the ESN for transfer out.
    UPDATE table_x_contact_part_inst
       SET x_transfer_flag = 1
     WHERE x_contact_part_inst2contact = (SELECT web_user2contact
                                            FROM table_web_user
                                           WHERE objid = p_web_user_objid)
          -- and X_CONTACT_PART_INST2PART_INST in ( select PGM_ENROLL2PART_INST from x_program_enrolled where x_esn = p_esn and PGM_ENROLL2WEB_USER = p_web_user_objid );
       AND x_contact_part_inst2part_inst IN (SELECT objid
                                               FROM table_part_inst
                                              WHERE part_serial_no = p_esn
                                                AND part_status = 'Active');

    --DBMS_OUTPUT.PUT_LINE('Transferring completed. ');

    BEGIN
      UPDATE x_program_enrolled
         SET pgm_enroll2pgm_group = NULL
            , ----CR13581
             x_wait_exp_date      =
             --------- Set the wait period to cycle_date+p_wait_period ------------
             --------- For non-recurring, give 10 days ----------------------------
              NVL(x_next_charge_date
                 ,SYSDATE) + NVL(p_wait_period
                                ,10)
      ----------------- Put an arbitrary max date. -------------------------
      -- PGM_ENROLL2WEB_USER = null -- Do not associate with any web-user till the ESN is transferred in.
       WHERE x_esn = p_esn
         AND pgm_enroll2web_user = p_web_user_objid
         AND x_enrollment_status NOT IN ('READYTOREENROLL'
                                        ,'DEENROLLED'
                                        ,'ENROLLMENTBLOCKED');
    EXCEPTION
      WHEN others THEN
        NULL;
        --- If there are no records selected for insert - catch the error.
    END;

    COMMIT;
    op_result := 0;
    op_msg    := 'ESN was successfully approved and transferred out.';
    RETURN;
  EXCEPTION
    WHEN others THEN
      op_result := -100;
      op_msg    := SQLERRM;
  END transfer_out_esn;

  /*
  This procedure finds the funding source compatible with all the programs selected.
  String separated list of enrollment IDs are passed to the program.
  */
  PROCEDURE validate_funding_source(p_web_user_objid IN NUMBER
                                   ,
                                    -- WebUser ID to whom the programs will be transferred
                                    p_enroll_list     IN VARCHAR2
                                   , -- List of current enrollments
                                    op_result         OUT NUMBER
                                   ,op_msg            OUT VARCHAR2
                                   ,op_permitted_list OUT VARCHAR2
                                    -- Permitted valid funding sources, in case of failure.
                                    ) IS
    /*
    0 : No matching funding sources
    1 : Default funding source is compatible
    2 : Non-Default funding source is compatible
    3 : No funding sources for the user
    */
    l_count      NUMBER;
    l_sql_string VARCHAR2(2000);

    CURSOR web_funding_cursor IS
      SELECT *
        FROM x_payment_source
       WHERE pymt_src2web_user = p_web_user_objid
         AND x_status = 'ACTIVE'
       ORDER BY NVL(x_is_default
                   ,0) DESC;

    -- Get the default funding source first.
    web_funding_rec web_funding_cursor%ROWTYPE;

    TYPE ref_cursor_type IS REF CURSOR;

    l_cursor                ref_cursor_type;
    l_web_funding_source    VARCHAR2(255);
    l_prog_funding_source   VARCHAR2(255);
    l_funding_source        VARCHAR2(50);
    l_valid_funding_sources VARCHAR2(255) := 'CREDITCARD,DEBITCARD,ACH,PAYPAL,';
  BEGIN
    op_result := 0;
    op_msg    := 'No matching funding sources';
    /* Implementation Logic:
    1. Get all the funding sources for the given web account.
    2. Get all the restricted funding account.
    3. If the restricted source exists, the current funding source cannot be used.
    */
    -- Step 1: Get the restricted payment sources.
    l_sql_string := 'select distinct (X_PAYMENT_TYPE) ' || ' from X_MTM_RESTRICTED_PYMTMODE a, x_program_parameters b ' || ' where a.PROGRAM_PARAM_OBJID = b.objid ' || ' and b.objid in ( select PGM_ENROLL2PGM_PARAMETER ' || ' from x_program_enrolled where objid in ( ' ||
                   --substr(p_enroll_list,1,length(p_enroll_list)-1) ||
                    p_enroll_list || ' )) ';

    -- Get all the funding types restricted (not allowed for the current programs enrolled )
    OPEN l_cursor FOR l_sql_string;

    LOOP
      FETCH l_cursor
        INTO l_funding_source;

      EXIT WHEN l_cursor%NOTFOUND;

      /*
      IF ( INSTR(l_web_funding_source, l_funding_source) = 0 ) THEN
      -- This funding source is not restricted. This funding source can be used.
      op_result := 2;
      op_msg := 'Funding Source ' ||l_funding_source || ' is compatible' ;
      EXIT;
      ELSE
      --DBMS_OUTPUT.PUT_LINE('Funding Source ' || l_funding_source || ' is *NOT* compatible' );
      END IF;
      */
      IF l_prog_funding_source IS NOT NULL THEN
        l_prog_funding_source := l_prog_funding_source || ',';
      END IF;

      l_prog_funding_source := l_prog_funding_source || l_funding_source;
      -- Delete l_funding_source from the available payment modes.
      l_valid_funding_sources := REPLACE(l_valid_funding_sources
                                        ,l_funding_source || ',');
    END LOOP;

    CLOSE l_cursor;

    --op_permitted_list := l_prog_funding_source; -- Set the permitted list of funding sources for the given program
    op_permitted_list := 'No valid funding sources found';
    --DBMS_OUTPUT.PUT_LINE('Program funding Sources restricted are ' || l_prog_funding_source);

    -- Step 2: Get the funding sources available with the current account.
    OPEN web_funding_cursor;

    LOOP
      FETCH web_funding_cursor
        INTO web_funding_rec;

      EXIT WHEN web_funding_cursor%NOTFOUND;

      -- Check if this funding source is restricted.
      IF (INSTR(l_prog_funding_source
               ,web_funding_rec.x_pymt_type) <> 0) THEN
        -- This is a restricted funding source. Cannot use this.
        -- Go for the next source
        --DBMS_OUTPUT.PUT_LINE('This funding source is restricted : ' || l_prog_funding_source || ' -> ' || web_funding_rec.x_pymt_type);
        NULL;
      ELSE
        -- This is not a restricted funding source.
        -- Is this the primary funding source.
        --DBMS_OUTPUT.PUT_LINE('Success : ' || l_prog_funding_source || ' -> ' || web_funding_rec.x_pymt_type || '-ObjiID' || TO_CHAR(web_funding_rec.objid));

        IF (web_funding_rec.x_is_default = 1) THEN
          op_result := 1;
          -- op_msg := 'Default funding source is compatible';
          op_msg            := web_funding_rec.objid;
          op_permitted_list := web_funding_rec.x_pymt_src_name;
          -- Give the payment source name
          RETURN;
        ELSE
          op_result := 2;
          -- op_msg := 'A funding source is compatible';
          op_msg            := web_funding_rec.objid;
          op_permitted_list := web_funding_rec.x_pymt_src_name;
          -- Give the payment source name
          RETURN;
        END IF;

        EXIT;
      END IF;
      /*
      IF l_web_funding_source is not null THEN
      l_web_funding_source := l_web_funding_source || ',';
      END IF;
      l_web_funding_source := l_web_funding_source || web_funding_rec.X_PYMT_TYPE;
      */
    END LOOP;

    IF (web_funding_cursor%ROWCOUNT = 0) THEN
      op_result         := 3;
      op_msg            := 'No funding sources associated to the user';
      op_permitted_list := SUBSTR(l_valid_funding_sources
                                 ,1
                                 ,LENGTH(l_valid_funding_sources) - 1);
      -- op_permitted_list := 'No valid funding sources found';
      /*
      else
      op_permitted_list := substr(l_valid_funding_sources,1,length(l_valid_funding_sources)-1);
      */
    END IF;

    CLOSE web_funding_cursor;
  END validate_funding_source;

  --ST_BUNDLE1
  /* This procedure is called to transfer the esn from one program to a different program */
  PROCEDURE transfer_esn_prog_to_diff_prog(p_s_enrlobjid IN x_program_enrolled.objid%TYPE
                                          ,
                                           -- source enrolled record
                                           p_t_pgmobjid IN x_program_parameters.objid%TYPE
                                          ,
                                           -- target program
                                           p_user IN VARCHAR2
                                          ,
                                           -- WEBCSR user initiating the transfer
                                           op_result OUT NUMBER
                                          ,op_msg    OUT VARCHAR2) IS
    CURSOR c_pgm_enroll IS
      SELECT *
        FROM x_program_enrolled
       WHERE objid = p_s_enrlobjid;

    r_pgm_enroll c_pgm_enroll%ROWTYPE;

    CURSOR c_pgm_param(ip_pgm_objid IN NUMBER) IS
      SELECT pp.objid
            ,pp.x_program_name
            ,sp.customer_price
        FROM x_program_parameters   pp
            ,mtm_sp_x_program_param mtm
            ,x_service_plan         sp
       WHERE 1 = 1
         AND sp.objid = mtm.program_para2x_sp
         AND pp.objid = mtm.x_sp2program_param
         AND pp.objid = ip_pgm_objid;

    r_pgm_param      c_pgm_param%ROWTYPE;
    l_old_pgm_objid  x_program_parameters.objid%TYPE;
    l_new_pgm_objid  x_program_parameters.objid%TYPE;
    l_old_pgm_name   x_program_parameters.x_program_name%TYPE;
    l_new_pgm_name   x_program_parameters.x_program_name%TYPE;
    l_old_pgm_amount x_program_enrolled.x_amount%TYPE;
    l_new_pgm_amount x_program_enrolled.x_amount%TYPE;
    l_enroll_esn     x_program_enrolled.x_esn%TYPE;
    retval           NUMBER;
  BEGIN
    OPEN c_pgm_enroll;

    FETCH c_pgm_enroll
      INTO r_pgm_enroll;

    IF c_pgm_enroll%NOTFOUND THEN
      CLOSE c_pgm_enroll;

      op_result := 1;
      op_msg    := 'Esn enrollment not found';
      RETURN;
    END IF;

    l_enroll_esn := r_pgm_enroll.x_esn;

    --to fetch the old program
    OPEN c_pgm_param(r_pgm_enroll.pgm_enroll2pgm_parameter);

    FETCH c_pgm_param
      INTO r_pgm_param;

    IF c_pgm_param%NOTFOUND THEN
      CLOSE c_pgm_param;

      op_result := 2;
      op_msg    := 'Old program not found';
      RETURN;
    ELSE
      l_old_pgm_objid  := r_pgm_param.objid;
      l_old_pgm_name   := r_pgm_param.x_program_name;
      l_old_pgm_amount := r_pgm_param.customer_price;
    END IF;

    CLOSE c_pgm_param;

    --to fetch the new program
    OPEN c_pgm_param(p_t_pgmobjid);

    FETCH c_pgm_param
      INTO r_pgm_param;

    IF c_pgm_param%NOTFOUND THEN
      CLOSE c_pgm_param;

      op_result := 2;
      op_msg    := 'New program not found';
      RETURN;
    ELSE
      l_new_pgm_objid  := r_pgm_param.objid;
      l_new_pgm_name   := r_pgm_param.x_program_name;
      l_new_pgm_amount := r_pgm_param.customer_price;
    END IF;

    CLOSE c_pgm_param;

    retval := billing_global_insert_pkg.billing_insert_prog_trans(billing_seq('X_PROGRAM_TRANS')
                                                                 ,r_pgm_enroll.x_enrollment_status
                                                                 ,r_pgm_enroll.x_reason
                                                                 ,NULL
                                                                 ,NULL
                                                                 ,NULL
                                                                 ,SYSDATE
                                                                 ,'Straight Talk Plan Transfer'
                                                                 ,'ST_PLAN_TRANSFER'
                                                                 ,'From ' || l_old_pgm_name || ' to ' || l_new_pgm_name
                                                                 ,r_pgm_enroll.x_sourcesystem
                                                                 ,r_pgm_enroll.x_esn
                                                                 ,NULL
                                                                 ,NULL
                                                                 ,'I'
                                                                 ,NVL(p_user
                                                                     ,'System')
                                                                 ,r_pgm_enroll.objid
                                                                 ,r_pgm_enroll.pgm_enroll2web_user
                                                                 ,r_pgm_enroll.pgm_enroll2site_part);

    UPDATE x_program_enrolled
       SET pgm_enroll2pgm_parameter = l_new_pgm_objid
          ,x_amount                 = l_new_pgm_amount
     WHERE objid = p_s_enrlobjid;

    COMMIT;
    op_result := 0;
    op_msg    := 'Success';

    CLOSE c_pgm_enroll;
  EXCEPTION
    WHEN others THEN
      op_result := -100;
      op_msg    := SQLERRM;

      INSERT INTO x_program_error_log
        (x_source
        ,x_error_code
        ,x_error_msg
        ,x_date
        ,x_description
        ,x_severity)
      VALUES
        ('transfer_esn_prog_to_diff_prog'
        ,op_result
        ,op_msg
        ,SYSDATE
        ,'ESN ' || l_enroll_esn || ' transfering from ' || l_old_pgm_name || ' to ' || l_new_pgm_name
        ,1 -- HIGH
         );

      ------------------------ Exception Logging --------------------------------------------------------------------
      --DBMS_OUTPUT.PUT_LINE('Got Error in transfer_esn_prog_to_diff_prog : ' || op_msg);
  END transfer_esn_prog_to_diff_prog;

  --ST_BUNDLE1
  /*
  This procedure is called when we want to transfer all the programs associated with one ESN
  to another ESN withing the same account. This is typically used for Upgrade.
  */
  PROCEDURE transfer_esn_prog_to_diff_esn
  (
    p_web_objid IN table_web_user.objid%TYPE
   , -- WebUser ObjID
    p_s_esn     IN x_program_enrolled.x_esn%TYPE
   ,
    -- ESN from which programs need to be transferred.
    p_t_esn IN x_program_enrolled.x_esn%TYPE
   ,
    -- ESN to which the programs need to be transferred to.
    p_user    IN VARCHAR2
   , -- WEBCSR user initiating the transfer
    p_pe_objid           OUT x_program_enrolled.objid%TYPE
   ,
    p_from_pgm_objid     OUT x_program_parameters.objid%TYPE
   ,
    op_result OUT NUMBER
   ,OP_MSG    OUT varchar2
   , in_hpp_transfer_flg  IN  varchar2 default null   /* CR22313 HPP PHASE-2 22-Aug-2014 ; warranty transfer allowed in certain cases  */
  ) IS
    CURSOR transfer_esn_c
    (
      c_web_user NUMBER
     ,c_esn      VARCHAR2
    ) IS
      SELECT pe.objid
            ,pe.pgm_enroll2web_user
            ,pe.pgm_enroll2pgm_parameter
			,pp.X_PROG_CLASS
            ,pe.x_esn
            ,(select org_id from table_bus_org bo where bo.objid = pp.prog_param2bus_org) org_id
--            ,(SELECT x_units FROM table_x_promotion prom WHERE prom.objid = pp.x_promo_incl_min_at AND ROWNUM < 2) AS from_units  --CR30860 SL SMARTPHONE UPGRADE
--            ,(SELECT 'Y' FROM x_sl_currentvals sl_cur, table_bus_org b_org WHERE sl_cur.x_current_esn = pe.x_esn AND pp.x_prog_class = 'LIFELINE'
--            AND pe.x_enrollment_status = 'ENROLLED' AND b_org.org_id = 'TRACFONE' AND ROWNUM < 2) AS is_sl_tf --CR30860 SL SMARTPHONE UPGRADE
        FROM x_program_enrolled   pe
            ,x_program_parameters pp
       WHERE pp.objid = pe.pgm_enroll2pgm_parameter -- CR12155
         AND (pp.x_is_recurring = 1 -- ST_BUNDLE_III to avoid transferring bundle progs and allow only Recurring
          OR EXISTS (
         SELECT 1 FROM table_x_parameters
         WHERE  x_param_name='TRANSFER NON RECURRING PROGRAM' AND x_param_value=pp.objid
         ))  --CR38927 configuration added to consider non recurring programs alsp
         AND pgm_enroll2web_user = c_web_user
         AND x_esn = c_esn
--CR22380 Handset protection, modified cursor to exclude programs which are not eligible for transferring.
        and  not exists (select 'X'
                         from   table_x_parameters
                         WHERE  X_PARAM_NAME = 'NOT ELIGIBLE FOR TRANSFERRING' || nvl(in_hpp_transfer_flg,'')  /*  CR22313  in_hpp_transfer_flg - added */
                         and    x_param_value = pp.x_prog_class);

    --Adding check for wait period,It should not be null and should be greater than todays date.
    --AND X_WAIT_EXP_DATE IS NOT NULL AND TRUNC( X_WAIT_EXP_DATE ) > TRUNC( SYSDATE );
    -- No need to check enrollment status. Simply need to transfer all the program records as is.
    transfer_esn_rec transfer_esn_c%ROWTYPE;
    ---------------------------------
    l_objid          x_program_enrolled.objid%TYPE;
    l_is_grp_primary x_program_enrolled.x_is_grp_primary%TYPE;
    ----------------------------------
    --- Compatibility checks
    l_error_number  NUMBER := 0;
    l_error_message VARCHAR2(255);
    --- Logging variables
    l_program_name x_program_parameters.x_program_name%TYPE;
    l_first_name   table_contact.first_name%TYPE;
    l_last_name    table_contact.last_name%TYPE;
    l_device_from table_x_part_class_values.x_param_value%TYPE;
    l_device_to table_x_part_class_values.x_param_value%TYPE;

    --ST_BUNDLE1
    CURSOR c_get_st_enroll(p_enrolled_objid IN NUMBER) IS
      SELECT 'X'
        FROM x_program_enrolled   pe
            ,x_program_parameters pp
       WHERE 1 = 1
         AND pp.objid = pe.pgm_enroll2pgm_parameter
         AND pp.x_prog_class = 'SWITCHBASE'
         AND pp.x_is_recurring = 1 -- CR12155 ST_BUNDLE_III
         AND pe.x_enrollment_status = 'ENROLLED'
         AND pe.objid = p_enrolled_objid;
     r_get_st_enroll c_get_st_enroll%ROWTYPE;

   /* CURSOR c_get_min_for_sl(c_esn IN x_program_enrolled.x_esn%TYPE) IS
      SELECT x_min x_min
        FROM table_site_part tsp
       WHERE 1 = 1
         AND tsp.x_service_id = c_esn
         AND part_status = 'Active';
     r_get_min_for_sl c_get_min_for_sl%ROWTYPE;

   CURSOR get_min
   IS
    SELECT x_min,objid
    FROM table_site_part
    WHERE x_service_id =p_t_esn
    AND part_status ='Active';

    CURSOR pgm_transfer(c_from_pgm_objid number)
    IS
    select to_pgm_objid
    from x_sl_upgrade_program_config cc
    where cc.from_pgm_objid = c_from_pgm_objid;*/

--        SELECT  DISTINCT
--        cv.lid lid,
--        su.objid subs_objid,
--        pr.objid pr_objid,
--        pe.objid  pe_objid,
--        pr.x_program_name current_pgm_name,
--        upc.to_pgm_objid pgm_change_objid,
--        upc.to_pgm_name pgm_change_name,
--        (select x_program_desc from x_program_parameters prc where prc.objid=upc.to_pgm_objid) pgm_change_name_desc
--        FROM x_sl_currentvals cv,
--        x_sl_subs su,
--        x_program_enrolled pe,
--        x_program_parameters pr,
--        x_sl_upgrade_program_config upc
--        WHERE cv.x_current_min = min --x_sl_current_vals can have from esn or to_esn so going by min
--            AND pe.x_esn=p_t_esn
--            AND pe.pgm_enroll2pgm_parameter = pr.objid
--            AND cv.lid = su.lid
--            AND pr.x_prog_class='LIFELINE'
--            AND pr.objid = upc.from_pgm_objid
--            AND upc.from_pgm_objid <> upc.to_pgm_objid;
      --  r_get_to_prog_obj c_get_to_prog_obj%ROWTYPE;

    l_st_enrolled   CHAR(1) := 'N';
    --ST_BUNDLE1

    l_update VARCHAR(2) := 'N';
   -- rec_get_min  get_min%ROWTYPE;

  BEGIN
    -- There is no need to check for any funding source compatibilities, or primary checks.
    -- The ESN can be transferred automatically without any issues.
    -- Checks: Check if the ESN is compatible with all the programs that have been enrolled into.
--CR49066
/*       SA.OTA_UTIL_PKG.ERR_LOG (
           'hpp transfer test',
           SYSDATE,
           null,
           'HPP Transfer',
            'p_s_esn='||p_s_esn
            ||', p_t_esn = '|| p_t_esn
            ||', p_web_objid='||p_web_objid  );*/

    OPEN transfer_esn_c(p_web_objid
                       ,p_s_esn);

    LOOP
      FETCH transfer_esn_c
        INTO transfer_esn_rec;

      EXIT WHEN transfer_esn_c%NOTFOUND;

      /*
      select canenroll (
      transfer_esn_rec.PGM_ENROLL2WEB_USER,
      p_t_esn, --transfer_esn_rec.x_esn,
      transfer_esn_rec.PGM_ENROLL2PGM_PARAMETER, 0)
      into l_error_number
      from dual;*/ --ST_BUNDLE1
      OPEN c_get_st_enroll(transfer_esn_rec.objid);

      FETCH c_get_st_enroll
        INTO r_get_st_enroll;

      IF c_get_st_enroll%FOUND THEN
        l_st_enrolled := 'Y';
      ELSE
        l_st_enrolled := 'N';
      END IF;

      CLOSE c_get_st_enroll;

      IF l_st_enrolled = 'Y' THEN
        l_error_number  := 1;
        l_error_message := 'OK to enroll as primary (first enrollment)';
        op_result       := 0;
        op_msg          := 'Success';
      ELSE
        billing_canenroll(transfer_esn_rec.pgm_enroll2web_user
                         ,p_t_esn
                         , --transfer_esn_rec.x_esn,
                          transfer_esn_rec.pgm_enroll2pgm_parameter
                         ,l_error_number
                         ,l_error_message);
      END IF;

      --ST_BUNDLE1
      -- Get the program name for logging purposes
     BEGIN --{
      SELECT x_program_name
         INTO l_program_name
         FROM x_program_parameters pp
        WHERE pp.objid = transfer_esn_rec.pgm_enroll2pgm_parameter;
     EXCEPTION --CR49066
     WHEN OTHERS THEN
      NULL;
     END; --}

      --ESN_STATUS_ENROLL_ELIGIBLE (transfer_esn_rec.PGM_ENROLL2PGM_PARAMETER, transfer_esn_rec.x_esn, transfer_esn_rec.PGM_ENROLL2WEB_USER,l_error_number, l_error_message );
      --DBMS_OUTPUT.PUT_LINE('Can Enroll returns ' || l_error_number);
--CR49066
/*       SA.OTA_UTIL_PKG.ERR_LOG (
           'hpp transfer test',
           SYSDATE,
           null,
           'HPP Transfer',
            'esn l_program_name='||l_program_name  ||', billing_canenroll -> l_error_number='||l_error_number  );*/

      IF (l_error_number IN (1
                            ,2
                            ,3
                            ,4
                            ,8001
                            ,8007
                            ,7511
                            ,7508)) THEN
        -- This program can be transferred
        ------ Insert record into program trans.
        --DBMS_OUTPUT.PUT_LINE('CanEnroll returned ' || l_error_number);

        INSERT INTO x_program_trans
          (objid
          ,x_enrollment_status
          ,x_enroll_status_reason
          ,x_float_given
          ,x_cooling_given
          ,x_grace_period_given
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
          ,pgm_trans2web_user
          ,pgm_trans2site_part)
          SELECT billing_seq('X_PROGRAM_TRANS')
                ,x_enrollment_status
                ,'ESN is being upgraded.'
                ,NULL
                ,NULL
                ,NULL
                ,SYSDATE
                ,'Upgrading the ESN'
                ,'TRANSFER'
                 --CR20740 Start KACOSTA 05/31/2012
                 --,'Due to upgrade from ESN ' || p_s_esn || ' to ' || p_t_esn || ' - Program ' || l_program_name || ' is transferred successfully'
                ,SUBSTR('Due to upgrade from ESN ' || p_s_esn || ' to ' || p_t_esn || ' - Program ' || l_program_name || ' is transferred successfully'
                       ,1
                       ,255)
                 --CR20740 End KACOSTA 05/31/2012
                ,x_sourcesystem
                ,x_esn
                ,x_exp_date
                ,x_cooling_exp_date
                ,'I'
                ,p_user
                ,objid
                ,pgm_enroll2web_user
                ,pgm_enroll2site_part
            FROM x_program_enrolled
           WHERE objid = transfer_esn_rec.objid;

        ----- Update the Enrollment record.
        --DBMS_OUTPUT.PUT_LINE('Before enroll update ');
        --
        --CR22152 Start Kacosta 10/23/2012
        DECLARE
          --
          l_exc_business_failure EXCEPTION;
          l_i_error_code    PLS_INTEGER := 0;
          l_v_error_message VARCHAR2(32767) := 'SUCCESS';
          --
        BEGIN
          --
          transfer_enrolled_program_prom(p_old_esn => p_s_esn
                                         --CR22660 Start kacosta 11/16/2012
                                        ,p_program_parameters_objid => transfer_esn_rec.pgm_enroll2pgm_parameter
                                         --CR22660 End kacosta 11/16/2012
                                        ,p_new_esn       => p_t_esn
                                        ,p_error_code    => l_i_error_code
                                        ,p_error_message => l_v_error_message);
          --
          IF (l_i_error_code <> 0) THEN
            --
            INSERT INTO x_program_error_log
              (x_source
              ,x_error_code
              ,x_error_msg
              ,x_date
              ,x_description
              ,x_severity)
            VALUES
              ('transfer_esn_prog_to_diff_esn'
              ,l_i_error_code
              ,'Failure calling transfer_enrolled_program_prom; Error: ' || l_v_error_message
              ,SYSDATE
              ,'ESN ' || p_s_esn || ' upgrading to ' || p_t_esn
              ,1);
            --
            RAISE l_exc_business_failure;
            --
          END IF;
          --
--CR49066
/*           SA.OTA_UTIL_PKG.ERR_LOG (
               'hpp transfer test',
               SYSDATE,
               null,
               'HPP Transfer',
                'transfer_enrolled_program_prom Completed'  );*/

        EXCEPTION
          WHEN l_exc_business_failure THEN
            --
           sa.OTA_UTIL_PKG.ERR_LOG (
               'l_exc_business_failure',
               SYSDATE,
               null,
               'transfer_esn_prog_to_diff_esn',
                'l_exc_business_failure occured'  );
            RAISE;
            --
          WHEN others THEN
            --
           sa.OTA_UTIL_PKG.ERR_LOG (
               'OTHERS Exception',
               SYSDATE,
               null,
               'transfer_esn_prog_to_diff_esn',
                '.ERR='|| substr(sqlerrm,1,100)  );
            RAISE;
            --
        END;
        --CR22152 End Kacosta 10/23/2012
        --

        UPDATE x_program_enrolled
           SET x_esn                = p_t_esn
              ,pgm_enroll2site_part =
               --
               -- Start CR13082 Kacosta 01/20/2011
               --(SELECT objid
               -- FROM table_site_part
               -- WHERE x_service_id = p_t_esn
               -- AND part_status = 'Active'),
               (SELECT tsp.objid
                  FROM table_part_inst tpi
                      ,table_site_part tsp
                 WHERE tsp.x_service_id = p_t_esn
                   AND tsp.part_status = 'Active'
                   AND tsp.objid = tpi.x_part_inst2site_part
                   AND tpi.x_part_inst_status = '52'
                   AND tpi.x_domain = 'PHONES')
              ,
               -- End CR13082 Kacosta 01/20/2011
               --
               pgm_enroll2part_inst =
               (SELECT objid
                  FROM table_part_inst
                 WHERE part_serial_no = p_t_esn
                   AND part_status = 'Active')
              ,x_wait_exp_date      = NULL
              , -- Remove the wait period if any
               x_grace_period       = NULL
              , -- Remove Grace Period
               x_cooling_period     = NULL
              , -- Remove the Cooling Period
               x_enrollment_status = CASE
                                       WHEN x_next_charge_date < TRUNC(SYSDATE)
                                            AND x_enrollment_status = 'ENROLLED' THEN
                                        CASE
                                          WHEN x_is_grp_primary = 1 THEN
                                           'SUSPENDED'
                                          ELSE
                                           'READYTOREENROLL'
                                        END
                                       ELSE
                                        x_enrollment_status
                                     END
         WHERE objid = transfer_esn_rec.objid
           AND x_enrollment_status = 'ENROLLED'  --CR47566 Only update the OLD ESN to NEW when status is enrolled otherwise it should not be changed
        RETURNING objid, x_is_grp_primary INTO l_objid, l_is_grp_primary;


      --CR38927 safelink changes start
IF transfer_esn_rec.x_prog_class='LIFELINE' THEN
      p_pe_objid := l_objid;
      p_from_pgm_objid := transfer_esn_rec.pgm_enroll2pgm_parameter;
END IF;
    BEGIN
        IF (transfer_esn_rec.x_prog_class='LIFELINE' AND transfer_esn_rec.org_id ='TRACFONE') THEN
         sa.ild_transaction_pkg.p_insert_ild_transaction_sl_1(
              p_min => NULL,
              p_esn_from => p_s_esn,
              p_esn_to => p_t_esn,
              p_action => 'UPGRADE',
              p_brand => transfer_esn_rec.org_id,
              p_ild_trans_type => 'D',
              p_err_num => l_error_number,
              p_err_string => l_error_message
            );
        END IF;
--call procedure arproc
     EXCEPTION
       WHEN OTHERS THEN

        util_pkg.insert_error_tab ( i_action         => 'calling ild_transaction_pkg.p_insert_ild_transaction_sl_1 failed',
                                    i_key            =>  p_t_esn,
                                    i_program_name   => 'billing_webscr_pkg.transfer_esn_prog_to_diff_esn',
                                    i_error_text     => 'Failed for From ESN :'||p_s_esn||' to ESN :'||p_t_esn||'Err :'||substr(sqlerrm,1,200));
     END;
    --CR38927 safelink changes end


        /* CR29079 changes starts. update the references to webuser and contact */
        declare
          lv_rows_updated integer := 0;
        begin
          if in_hpp_transfer_flg = 'ALLOW_HPP_TRANSFER' then
            update x_program_enrolled ut
            set (ut.PGM_ENROLL2CONTACT, ut.PGM_ENROLL2WEB_USER) = (
                   SELECT a.objid, a.web_user2contact
                   FROM table_web_user            a
                      ,table_x_contact_part_inst b
                      ,table_part_inst           c
                      ,table_mod_level           d
                      ,table_part_num            e
                   WHERE a.web_user2contact = b.x_contact_part_inst2contact
                   AND b.x_contact_part_inst2part_inst = c.objid
                   AND d.objid = c.n_part_inst2part_mod
                   AND d.part_info2part_num = e.objid
                   AND a.web_user2bus_org = e.part_num2bus_org
                   AND c.part_serial_no = p_t_esn
                  )
            where ut.objid = transfer_esn_rec.objid;

            lv_rows_updated := sql%rowcount;
--CR49066
/*           SA.OTA_UTIL_PKG.ERR_LOG (
               'hpp transfer test',
               SYSDATE,
               null,
               'HPP Transfer',
                'pgmEnrolledObjid='||transfer_esn_rec.objid
                ||'lv_rows_updated='||lv_rows_updated ||', err='|| substr(sqlerrm,1,50)  );*/

          end if;
        exception
          when others then
             sa.OTA_UTIL_PKG.ERR_LOG (
                 'OTHERS Exception', --CR49066
                 SYSDATE,
                 null,
                 'transfer_esn_prog_to_diff_esn',
                  substr(sqlerrm,1,50)
                  );
        end;
        /* CR29079 changes ends */

        ---------------- Insert the record into billing log -----------------------------------------------------------------------------------
      BEGIN --{
        SELECT first_name
              ,last_name
          INTO l_first_name
              ,l_last_name
          FROM table_contact
         WHERE objid = (SELECT web_user2contact
                          FROM table_web_user
                         WHERE objid = transfer_esn_rec.pgm_enroll2web_user);
      EXCEPTION --CR49066
      WHEN OTHERS THEN
       NULL;
      END; --}

        -- Log for old esn
        INSERT INTO x_billing_log
          (objid
          ,x_log_category
          ,x_log_title
          ,x_log_date
          ,x_details
          ,x_program_name
          ,x_nickname
          ,x_esn
          ,x_originator
          ,x_contact_first_name
          ,x_contact_last_name
          ,x_agent_name
          ,x_sourcesystem
          ,billing_log2web_user)
        VALUES
          (billing_seq('X_BILLING_LOG')
          ,'Program'
          ,'Upgrade'
          ,SYSDATE
           --CR20740 Start KACOSTA 05/31/2012
           --,'Upgrading ESN ' || p_s_esn || ' to ' || p_t_esn || ' - ' || l_program_name || ' transferred out successfully'
          ,SUBSTR('Upgrading ESN ' || p_s_esn || ' to ' || p_t_esn || ' - ' || l_program_name || ' transferred out successfully'
                 ,1
                 ,1000)
           --CR20740 End KACOSTA 05/31/2012
          ,l_program_name
          ,billing_getnickname(transfer_esn_rec.x_esn)
          ,transfer_esn_rec.x_esn
          ,'System'
          ,l_first_name
          ,l_last_name
          ,'System'
          ,'WEBCSR'
          ,transfer_esn_rec.pgm_enroll2web_user);

        -- Log for the new esn
        INSERT INTO x_billing_log
          (objid
          ,x_log_category
          ,x_log_title
          ,x_log_date
          ,x_details
          ,x_program_name
          ,x_nickname
          ,x_esn
          ,x_originator
          ,x_contact_first_name
          ,x_contact_last_name
          ,x_agent_name
          ,x_sourcesystem
          ,billing_log2web_user)
        VALUES
          (billing_seq('X_BILLING_LOG')
          ,'Program'
          ,'Upgrade'
          ,SYSDATE
           --CR20740 Start KACOSTA 05/31/2012
           --,'Upgrading ESN ' || p_s_esn || ' to ' || p_t_esn || ' - ' || l_program_name || ' transferred in successfully'
          ,SUBSTR('Upgrading ESN ' || p_s_esn || ' to ' || p_t_esn || ' - ' || l_program_name || ' transferred in successfully'
                 ,1
                 ,1000)
           --CR20740 End KACOSTA 05/31/2012
          ,l_program_name
          ,billing_getnickname(p_t_esn)
          ,p_t_esn
          ,'System'
          ,l_first_name
          ,l_last_name
          ,'System'
          ,'WEBCSR'
          ,transfer_esn_rec.pgm_enroll2web_user);

        -----------------------------------------------------------------------------------------------------------------------------------------
        --DBMS_OUTPUT.PUT_LINE('Check primary ');

        ----
        -- if the ESN that is being upgraded is a group primary, all the child ESNs also have to be moved out of the wait period.
        IF (l_is_grp_primary = 1) THEN
          UPDATE x_program_enrolled
             SET x_wait_exp_date  = NULL
                ,x_grace_period   = NULL
                ,x_cooling_period = NULL
           WHERE pgm_enroll2pgm_group = l_objid;
          /*
          insert into x_billing_log ( objid, X_LOG_CATEGORY, X_LOG_TITLE, X_LOG_DATE, X_DETAILS,
          X_PROGRAM_NAME, X_NICKNAME, X_ESN, X_ORIGINATOR,
          X_CONTACT_FIRST_NAME, X_CONTACT_LAST_NAME, X_AGENT_NAME,
          X_SOURCESYSTEM, BILLING_LOG2WEB_USER )
          values ( billing_seq('X_BILLING_LOG'),'Program','Upgrade',sysdate,
          'Upgrading ESN ' || p_s_esn || ' to ' || p_t_esn || '. Group Primary Upgrade',
          l_program_name,
          billing_getnickname(transfer_esn_rec.x_esn),
          transfer_esn_rec.x_esn,
          'System',l_first_name,l_last_name,'System','WEBCSR',
          transfer_esn_rec.PGM_ENROLL2WEB_USER );
          */
        END IF;

        -----
        --- Delete the record from MyAccount.
        --- If the account that got upgraded was primary, make the new ESN also a primary.
        --DBMS_OUTPUT.PUT_LINE('Removind from Myaccount defaults ');

        UPDATE table_x_contact_part_inst
           SET x_is_default =
               (SELECT x_is_default
                  FROM table_web_user            a
                      ,table_x_contact_part_inst b
                      ,table_part_inst           c
                 WHERE a.web_user2contact = b.x_contact_part_inst2contact
                   AND b.x_contact_part_inst2part_inst = c.objid
                   AND a.objid = p_web_objid
                   AND c.part_serial_no = p_s_esn)
         WHERE x_contact_part_inst2part_inst = (SELECT objid
                                                  FROM table_part_inst
                                                 WHERE part_serial_no = p_t_esn
                                                   AND part_status = 'Active')
           AND x_contact_part_inst2contact = (SELECT web_user2contact
                                                FROM table_web_user
                                               WHERE objid = p_web_objid);
        -- Start CR13249 GSM Upgrade project PM 07/19/2011
        IF l_st_enrolled = 'N' THEN
          op_result := 0;
          op_msg    := 'Success';
        END IF;
        -- End CR13249 GSM Upgrade project PM 07/19/2011

      ELSE
        op_result := 8701;
        -- One or more programs could not be transferred.
        op_msg := op_msg || ',' || l_program_name;

        ----- Update the Enrollment record.
        UPDATE x_program_enrolled
           SET x_wait_exp_date = SYSDATE + 10 -- Set wait period for incompatible programs.
         WHERE objid = transfer_esn_rec.objid;

        INSERT INTO x_program_trans
          (objid
          ,x_enrollment_status
          ,x_enroll_status_reason
          ,x_float_given
          ,x_cooling_given
          ,x_grace_period_given
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
          ,pgm_trans2web_user
          ,pgm_trans2site_part)
          SELECT billing_seq('X_PROGRAM_TRANS')
                ,x_enrollment_status
                ,'ESN upgrade failure -Error code ' || TO_CHAR(l_error_number)
                ,NULL
                ,NULL
                ,NULL
                ,SYSDATE
                ,'Upgrading the ESN'
                ,'TRANSFER'
                 --CR20740 Start KACOSTA 05/31/2012
                 --,'Due to upgrade from ESN ' || p_s_esn || ' to ' || p_t_esn || ', upgrade attempt of ' || l_program_name || ' failed. Wait period of 10 days applied. ' || TO_CHAR(l_error_number) || ' - ' || l_error_message
                ,SUBSTR('Due to upgrade from ESN ' || p_s_esn || ' to ' || p_t_esn || ', upgrade attempt of ' || l_program_name || ' failed. Wait period of 10 days applied. ' || TO_CHAR(l_error_number) || ' - ' || l_error_message
                       ,1
                       ,255)
                 --CR20740 End KACOSTA 05/31/2012
                ,x_sourcesystem
                ,x_esn
                ,x_exp_date
                ,x_cooling_exp_date
                ,'I'
                ,p_user
                ,objid
                ,pgm_enroll2web_user
                ,pgm_enroll2site_part
            FROM x_program_enrolled
           WHERE objid = transfer_esn_rec.objid;

        INSERT INTO x_billing_log
          (objid
          ,x_log_category
          ,x_log_title
          ,x_log_date
          ,x_details
          ,x_program_name
          ,x_nickname
          ,x_esn
          ,x_originator
          ,x_contact_first_name
          ,x_contact_last_name
          ,x_agent_name
          ,x_sourcesystem
          ,billing_log2web_user)
        VALUES
          (billing_seq('X_BILLING_LOG')
          ,'Program'
          ,'Upgrade'
          ,SYSDATE
           --CR20740 Start KACOSTA 05/31/2012
           --,'Due to upgrade from ' || p_s_esn || ' to ' || p_t_esn || ', transfer attempt of ' || l_program_name || ' failed. Wait period of 10 days applied. ' || TO_CHAR(l_error_number) || ' - ' || l_error_message
          ,SUBSTR('Due to upgrade from ' || p_s_esn || ' to ' || p_t_esn || ', transfer attempt of ' || l_program_name || ' failed. Wait period of 10 days applied. ' || TO_CHAR(l_error_number) || ' - ' || l_error_message
                 ,1
                 ,1000)
           --CR20740 End KACOSTA 05/31/2012
          ,l_program_name
          ,billing_getnickname(transfer_esn_rec.x_esn)
          ,transfer_esn_rec.x_esn
          ,'System'
          ,l_first_name
          ,l_last_name
          ,'System'
          ,'WEBCSR'
          ,transfer_esn_rec.pgm_enroll2web_user);
      END IF;
    END LOOP;

    -- Start CR13249 GSM Upgrade project PM 07/19/2011
    IF transfer_esn_c%ROWCOUNT = 0 THEN
      op_result := 0;
      op_msg    := 'Success';
--CR49066
/*       SA.OTA_UTIL_PKG.ERR_LOG (
           'hpp transfer test',
           SYSDATE,
           null,
           'HPP Transfer',
            'transfer_esn_c = 0 records !!!'  );*/


    END IF;
    -- End CR13249 GSM Upgrade project PM 07/19/2011
    CLOSE transfer_esn_c;

    ----------- All programs can be transferred.
    /* As per discussion, old ESN remains in MyAccount ( 330,335)

    --- Delete the record from MyAccount
    delete from table_x_contact_part_inst
    where X_CONTACT_PART_INST2PART_INST = (select objid from table_part_inst where part_serial_no = p_s_esn )
    and X_CONTACT_PART_INST2CONTACT = ( select WEB_USER2CONTACT from table_web_user where objid = p_web_objid) ;
    ---
    */
    IF (op_result = 8701) THEN
      -- One or more programs could not be transferred.
      op_msg := 'Programs ' || op_msg || ' could not be transferred. Please check log history for details';
    END IF;

    COMMIT;
    --op_result:= 0; -- Default is success
    --op_msg := 'Success';
  EXCEPTION
    WHEN others THEN

      op_result := -100;
      op_msg    := SQLERRM;

      -- Put in the values into the output variables.
      ------------------------ Exception Logging --------------------------------------------------------------------
      --- Incase of any Exceptions, Log the data in the Error Log table for debugging purposes.
      INSERT INTO x_program_error_log
        (x_source
        ,x_error_code
        ,x_error_msg
        ,x_date
        ,x_description
        ,x_severity)
      VALUES
        ('transfer_esn_prog_to_diff_esn'
        ,op_result
        ,op_msg
        ,SYSDATE
        ,'ESN ' || p_s_esn || ' upgrading to ' || p_t_esn
        ,1 -- HIGH
         );

      ------------------------ Exception Logging --------------------------------------------------------------------
      --DBMS_OUTPUT.PUT_LINE('Got Error in transfer_esn_prog_to_diff_esn : ' || op_msg);
  END transfer_esn_prog_to_diff_esn;

  /*
  This procedure is used the transfer in the ESN from a previous transferred out account.
  The procedure checks for program compatibility and funding source compatibility.

  ASSUMPTION: This procedure does not check for the transfer flag. This check is assumed to be
  done from the calling code.
  */
  PROCEDURE transfer_in_esn
  (
    p_web_user_objid IN NUMBER
   ,p_esn            IN x_program_enrolled.x_esn%TYPE
   ,p_user           IN VARCHAR2
   ,op_result        OUT NUMBER
   ,op_msg           OUT VARCHAR2
  ) IS
    l_status                NUMBER;
    l_result                NUMBER;
    l_message               VARCHAR2(255);
    l_permitted_list        VARCHAR2(255);
    l_enrollment_list       VARCHAR2(4000);
    l_compat_funding_source NUMBER;

    CURSOR enrollment_cur(c_esn IN NUMBER) IS
      SELECT *
        FROM x_program_enrolled
       WHERE x_esn = c_esn
         AND x_enrollment_status IN ('ENROLLED'
                                    ,'SUSPENDED'
                                    ,'ENROLLMENTPENDING'
                                    ,'ENROLLMENTSCHEDULED');

    enrollment_rec enrollment_cur%ROWTYPE;
  BEGIN
    /* Get all the programs the transferred out ESN is enrolled into.
    For each program, check if the transfer in is possible.
    If the transfer in is possible, validate the funding source.
    All ok, update the programs ( including de-enrolled ones ) into this account.
    */
    op_result := 0;

    OPEN enrollment_cur(p_esn);

    LOOP
      FETCH enrollment_cur
        INTO enrollment_rec;

      EXIT WHEN enrollment_cur%NOTFOUND;

      IF (enrollment_rec.pgm_enroll2web_user != p_web_user_objid) THEN
        l_status := canenroll(p_web_user_objid
                             ,p_esn
                             ,enrollment_rec.pgm_enroll2pgm_parameter);

        IF (l_status IN (1
                        ,2
                        ,3
                        ,4
                        ,8001
                        ,8007
                        ,7511)) THEN
          -- these programs can be transferred.
          l_enrollment_list := l_enrollment_list || enrollment_rec.objid || ',';
        ELSIF (l_status IN (7502) -- already enrolled in the program

              --and enrollment_rec.x_wait_exp_date is not null -- Commented for defect 285 on August 17, 2006 --
              -- For adding an ESN belongs to other account which is not in transfer out status--
              ) THEN
          l_enrollment_list := l_enrollment_list || enrollment_rec.objid || ',';
        ELSE
          -- program cannot be transferred.
          op_result := l_status;
          op_msg    := 'Program ID ' || enrollment_rec.pgm_enroll2pgm_parameter || ' cannot be transferred.';
        END IF;
      ELSE
        op_result := 9004;
        op_msg    := 'Transfer is being attempted in the same account';
      END IF;
    END LOOP;

    CLOSE enrollment_cur;

    --- Return back on error.
    IF (op_result != 0) THEN
      RETURN;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('List of eligible programs that can be transferred ' || l_enrollment_list);

    IF (l_enrollment_list IS NULL OR l_enrollment_list = '') THEN
      -- Assume that the default funding source is valid.
      l_result := 1;

      BEGIN
        SELECT objid
          INTO l_permitted_list
          FROM x_payment_source
         WHERE pymt_src2web_user = p_web_user_objid
           AND x_is_default = 1
           AND x_status = 'ACTIVE';
      EXCEPTION
        WHEN no_data_found THEN
          l_permitted_list := NULL;
      END;
    ELSE
      validate_funding_source(p_web_user_objid
                             ,SUBSTR(l_enrollment_list
                                    ,1
                                    ,LENGTH(l_enrollment_list) - 1)
                             ,l_result
                             ,l_message
                             ,l_permitted_list);
    END IF;

    IF (l_result = 1) THEN
      -- Primary funding source of the account is valid. Associated the new records with the primary funding source.
      INSERT INTO x_program_trans
        (objid
        ,x_enrollment_status
        ,x_enroll_status_reason
        ,x_float_given
        ,x_cooling_given
        ,x_grace_period_given
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
        ,pgm_trans2web_user
        ,pgm_trans2site_part)
        SELECT billing_seq('X_PROGRAM_TRANS')
              ,x_enrollment_status
              ,'ESN is transferred in.'
              ,NULL
              ,NULL
              ,NULL
              ,SYSDATE
              ,'Transfer ESN into MyAccount'
              ,'TRANSFER'
              ,'Transferring ESN ' || p_esn || ' to MyAccount'
              ,x_sourcesystem
              ,x_esn
              ,x_exp_date
              ,x_cooling_exp_date
              ,'I'
              ,p_user
              ,objid
              ,pgm_enroll2web_user
              ,pgm_enroll2site_part
          FROM x_program_enrolled
         WHERE x_esn = p_esn;

      l_compat_funding_source := TO_NUMBER(l_message);

      UPDATE x_program_enrolled
         SET pgm_enroll2x_pymt_src = l_compat_funding_source
            ,pgm_enroll2web_user   = p_web_user_objid
            ,x_wait_exp_date       = NULL
            , --remove wait period
             x_enrollment_status = CASE
                                     WHEN x_next_charge_date < SYSDATE
                                          AND x_enrollment_status = 'ENROLLED' THEN
                                      CASE
                                        WHEN x_is_grp_primary = 1 THEN
                                         'SUSPENDED'
                                        ELSE
                                         'READYTOREENROLL'
                                      END
                                     ELSE
                                      x_enrollment_status
                                   END -- Suspend the ESN when the charge date has passed.
       WHERE x_esn = p_esn;
    ELSIF (l_result = 2) THEN
      -- Secondary funding source of the account is valid
      INSERT INTO x_program_trans
        (objid
        ,x_enrollment_status
        ,x_enroll_status_reason
        ,x_float_given
        ,x_cooling_given
        ,x_grace_period_given
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
        ,pgm_trans2web_user
        ,pgm_trans2site_part)
        SELECT billing_seq('X_PROGRAM_TRANS')
              ,x_enrollment_status
              ,'ESN transferred in.'
              ,NULL
              ,NULL
              ,NULL
              ,SYSDATE
              ,'Transfer ESN into MyAccount'
              ,'TRANSFER'
              ,'Transferring ESN ' || p_esn || ' to MyAccount'
              ,x_sourcesystem
              ,x_esn
              ,x_exp_date
              ,x_cooling_exp_date
              ,'I'
              ,p_user
              ,objid
              ,pgm_enroll2web_user
              ,pgm_enroll2site_part
          FROM x_program_enrolled
         WHERE x_esn = p_esn;

      l_compat_funding_source := TO_NUMBER(l_message);

      UPDATE x_program_enrolled
         SET pgm_enroll2x_pymt_src = l_compat_funding_source
            ,pgm_enroll2web_user   = p_web_user_objid
            ,x_wait_exp_date       = NULL
            , --remove wait period
             x_enrollment_status = CASE
                                     WHEN x_next_charge_date < SYSDATE
                                          AND x_enrollment_status = 'ENROLLED' THEN
                                      'SUSPENDED'
                                     ELSE
                                      x_enrollment_status
                                   END -- Suspend the ESN when the charge date has passed.
       WHERE x_esn = p_esn;
    ELSIF (l_result = 3) THEN
      -- No funding sources are available for the user
      op_result := 9003; --
      op_msg    := 'No funding sources match for the programs.';

      --- Transferring the programs anyway. Putting payment source as null.
      INSERT INTO x_program_trans
        (objid
        ,x_enrollment_status
        ,x_enroll_status_reason
        ,x_float_given
        ,x_cooling_given
        ,x_grace_period_given
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
        ,pgm_trans2web_user
        ,pgm_trans2site_part)
        SELECT billing_seq('X_PROGRAM_TRANS')
              ,x_enrollment_status
              ,'ESN transferred in.'
              ,NULL
              ,NULL
              ,NULL
              ,SYSDATE
              ,'Transfer ESN into MyAccount'
              ,'TRANSFER'
              ,'Transferring ESN ' || p_esn || ' to MyAccount - No funding sources found'
              ,x_sourcesystem
              ,x_esn
              ,x_exp_date
              ,x_cooling_exp_date
              ,'I'
              ,p_user
              ,objid
              ,pgm_enroll2web_user
              ,pgm_enroll2site_part
          FROM x_program_enrolled
         WHERE x_esn = p_esn;

      l_compat_funding_source := NULL;

      UPDATE x_program_enrolled
         SET pgm_enroll2x_pymt_src = l_compat_funding_source
            ,pgm_enroll2web_user   = p_web_user_objid
            ,x_payment_type        = 'PENDING_FS'
            ,x_wait_exp_date       = SYSDATE + 10
            ,
             --Add additional 10 day wait period
             x_enrollment_status = CASE
                                     WHEN x_next_charge_date < SYSDATE
                                          AND x_enrollment_status = 'ENROLLED' THEN
                                      'SUSPENDED'
                                     ELSE
                                      x_enrollment_status
                                   END -- Suspend the ESN when the charge date has passed.
       WHERE x_esn = p_esn;

      RETURN;
    ELSE
      -- No funding sources on account
      op_result := 9001; --
      op_msg    := 'No funding sources on account.';

      INSERT INTO x_program_trans
        (objid
        ,x_enrollment_status
        ,x_enroll_status_reason
        ,x_float_given
        ,x_cooling_given
        ,x_grace_period_given
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
        ,pgm_trans2web_user
        ,pgm_trans2site_part)
        SELECT billing_seq('X_PROGRAM_TRANS')
              ,x_enrollment_status
              ,'ESN transferred in.'
              ,NULL
              ,NULL
              ,NULL
              ,SYSDATE
              ,'Transfer ESN into MyAccount'
              ,'TRANSFER'
              ,'Transferring ESN ' || p_esn || ' to MyAccount - No funding sources on account. Applying wait period of 10 days'
              ,x_sourcesystem
              ,x_esn
              ,x_exp_date
              ,x_cooling_exp_date
              ,'I'
              ,p_user
              ,objid
              ,pgm_enroll2web_user
              ,pgm_enroll2site_part
          FROM x_program_enrolled
         WHERE x_esn = p_esn;

      l_compat_funding_source := NULL;

      UPDATE x_program_enrolled
         SET pgm_enroll2x_pymt_src = l_compat_funding_source
            ,pgm_enroll2web_user   = p_web_user_objid
            ,x_payment_type        = 'PENDING_FS'
            ,x_wait_exp_date       = SYSDATE + 10
            ,
             --Add additional 10 day wait period
             x_enrollment_status = CASE
                                     WHEN x_next_charge_date < SYSDATE
                                          AND x_enrollment_status = 'ENROLLED' THEN
                                      'SUSPENDED'
                                     ELSE
                                      x_enrollment_status
                                   END -- Suspend the ESN when the charge date has passed.
       WHERE x_esn = p_esn;

      RETURN;
    END IF;

    op_result := 0;
    op_msg    := 'Program transferred in successfully';
    COMMIT;
    RETURN;
  EXCEPTION
    WHEN others THEN
      op_result := -100;
      op_msg    := SQLERRM;
  END transfer_in_esn;

  /* ----------------------
  Function that validates whether the new ESN can be upgraded
  --------------------- */
  FUNCTION validate_upgrade_account
  (
    p_s_esn          VARCHAR2
   ,p_t_esn          VARCHAR2
   ,bcreatemyaccount NUMBER := 0
   ,p_web_objid      OUT NUMBER
  ) RETURN NUMBER
  /*
    1 : Source ESN does not have any autopay enrollments.
    2 : New ESN does not exist and is added to MyAccout
    4 : New ESN does not exist in any account but is not added to MyAccount
    3 : New ESN belongs to another account
    */
   IS
    l_error_code           NUMBER;
    l_error_message        VARCHAR2(255);
    l_s_webuser_objid      NUMBER;
    l_t_webuser_objid      NUMBER;
    l_s_contact_objid      NUMBER;
    l_t_part_inst          NUMBER;
    l_s_contact_first_name table_contact.first_name%TYPE;
    l_s_contact_last_name  table_contact.last_name%TYPE;
    l_unlimited_count      NUMBER;
  BEGIN
    -- This function checks that the old ESN and the NEW ESNs belong to the same account.
    -- If the new ESN does not exist in any accout, it creates a new entry and returns
    -- BRAND_SEP
    BEGIN
      --DBMS_OUTPUT.PUT_LINE('validate_upgrade_account ' || ' Getting OLD ESN : ' || p_s_esn);
      SELECT a.objid
            ,a.web_user2contact
        INTO l_s_webuser_objid
            ,l_s_contact_objid
        FROM table_web_user            a
            ,table_x_contact_part_inst b
            ,table_part_inst           c
            ,table_mod_level           d
            ,table_part_num            e
       WHERE a.web_user2contact = b.x_contact_part_inst2contact
         AND b.x_contact_part_inst2part_inst = c.objid
         AND d.objid = c.n_part_inst2part_mod
         AND d.part_info2part_num = e.objid
         AND a.web_user2bus_org = e.part_num2bus_org
         AND c.part_serial_no = p_s_esn;
      --DBMS_OUTPUT.PUT_LINE('Old ESN data retrieved. ');
      p_web_objid := l_s_webuser_objid;
    EXCEPTION
      WHEN no_data_found THEN
        l_error_code    := 1;
        l_error_message := 'Source ESN does not have any autopay enrollments';
        --DBMS_OUTPUT.PUT_LINE(l_error_message || SQLERRM);
        RETURN l_error_code;
    END;

    -----------------------------------------------------------------------------------------------
    -------------------------------------------------------------------------------------------------------------------
    -- Net10 Unlimited Changes 07/11/2008 .. Ramu
    -- As a part of Upgrade, transfer plan is not allowed for Net10 Unlimited plans
    BEGIN
      SELECT COUNT(*)
        INTO l_unlimited_count
        FROM x_program_enrolled   enroll
            ,x_program_parameters param
       WHERE 1 = 1
         AND enroll.x_esn = p_s_esn
         AND enroll.x_enrollment_status = 'ENROLLED'
         AND param.x_prog_class IN ('UNLIMITED')
         AND enroll.pgm_enroll2pgm_parameter = param.objid;

      -- If this ESN is actively Enrolled in Unlimited Plan
      IF (l_unlimited_count <> 0) THEN
        -- DeEnroll this ESN
        UPDATE x_program_enrolled
           SET x_enrollment_status = 'DEENROLLED'
              ,x_cooling_exp_date  = TRUNC(SYSDATE + 1)
         WHERE x_esn = p_s_esn
           AND x_enrollment_status = 'ENROLLED'
           AND pgm_enroll2pgm_parameter IN (SELECT objid
                                              FROM x_program_parameters
                                             WHERE x_prog_class = 'UNLIMITED');

        -- Insert a record in x_billing_log
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
          ,'Program De-enrolled'
          ,SYSDATE
          ,'De-Enrollment by Upgrade proces'
          ,billing_getnickname(p_s_esn)
          ,p_s_esn
          ,'System'
          ,'System'
          ,'NETCSR'
          ,l_s_webuser_objid);

        -- Insert record in to program trans
        INSERT INTO x_program_trans
          (objid
          ,x_enrollment_status
          ,x_enroll_status_reason
          ,x_trans_date
          ,x_action_text
          ,x_action_type
          ,x_reason
          ,x_esn
          ,x_exp_date
          ,x_update_user
          ,pgm_tran2pgm_entrolled
          ,pgm_trans2web_user
          ,pgm_trans2site_part)
          SELECT billing_seq('X_PROGRAM_TRANS')
                ,x_enrollment_status
                ,'DeEnrollment Scheduled'
                ,SYSDATE
                ,'Voluntary DeEnrollment'
                ,'DE_ENROLL'
                ,'Net10 Unlimited Plan'
                ,x_esn
                ,x_exp_date
                ,'System'
                ,objid
                ,pgm_enroll2web_user
                ,pgm_enroll2site_part
            FROM x_program_enrolled
           WHERE x_esn = p_s_esn
             AND x_enrollment_status = 'ENROLLED'
             AND pgm_enroll2pgm_parameter IN (SELECT objid
                                                FROM x_program_parameters
                                               WHERE x_prog_class = 'UNLIMITED');

        RETURN 100;
        -- New Error number
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        l_error_code    := 1;
        l_error_message := 'Exception occured while pulling enrollment record';
        --DBMS_OUTPUT.PUT_LINE(l_error_message || SQLERRM);
        RETURN l_error_code;
    END;
    -------------------------------------------------------------------------------------------------------------------
    -- BRAND_SEP

    SELECT objid
      INTO l_t_part_inst
      FROM table_part_inst
     WHERE part_serial_no = p_t_esn
       AND part_status = 'Active';
    BEGIN
      SELECT a.objid
        INTO l_t_webuser_objid
        FROM table_web_user            a
            ,table_x_contact_part_inst b
            ,table_part_inst           c
            ,table_mod_level           d
            ,table_part_num            e
       WHERE a.web_user2contact = b.x_contact_part_inst2contact
         AND b.x_contact_part_inst2part_inst = c.objid
         AND d.objid = c.n_part_inst2part_mod
         AND d.part_info2part_num = e.objid
         AND a.web_user2bus_org = e.part_num2bus_org
         AND c.part_serial_no = p_t_esn;
      /*
      select objid
      into l_t_webuser_objid
      from table_web_user
      where WEB_USER2CONTACT = ( select X_CONTACT_PART_INST2CONTACT
      from table_x_contact_part_inst
      where X_CONTACT_PART_INST2PART_INST = l_t_part_inst
      );
      */
      --DBMS_OUTPUT.PUT_LINE('New ESN data retrieved. ');
    EXCEPTION
      WHEN no_data_found THEN
        --- ESN does not exist in any account.
        --- Add this ESN to MyAccount
        --DBMS_OUTPUT.PUT_LINE('New ESN is not present in MyAccount');

        IF (bcreatemyaccount = 1) THEN
          INSERT INTO table_x_contact_part_inst
            (objid
            ,x_contact_part_inst2contact
            ,x_contact_part_inst2part_inst)
          VALUES
            (seq('x_contact_part_inst')
            ,l_s_contact_objid
            ,l_t_part_inst);

          SELECT first_name
                ,last_name
            INTO l_s_contact_first_name
                ,l_s_contact_last_name
            FROM table_contact
           WHERE objid = l_s_contact_objid;

          INSERT INTO x_billing_log
            (objid
            ,x_log_category
            ,x_log_title
            ,x_log_date
            ,x_details
            ,x_nickname
            ,x_esn
            ,x_originator
            ,x_contact_first_name
            ,x_contact_last_name
            ,x_agent_name
            ,x_sourcesystem
            ,billing_log2web_user)
          VALUES
            (billing_seq('X_BILLING_LOG')
            ,'ESN'
            ,'ADD_ESN'
            ,SYSDATE
            ,'ESN ' || p_t_esn || ' has been successfully added.'
            ,billing_getnickname(p_t_esn)
            ,p_s_esn
            ,'System'
            ,l_s_contact_first_name
            ,l_s_contact_last_name
            ,'System'
            ,'WEBCSR'
            ,l_s_webuser_objid);

          RETURN 2;
          -- ESN does not belong to any account. Created a new record in MyAccount.
        END IF;

        RETURN 4;
    END;

    IF (l_s_webuser_objid != l_t_webuser_objid) THEN
      -- ESN belongs to another account.
      SELECT first_name
            ,last_name
        INTO l_s_contact_first_name
            ,l_s_contact_last_name
        FROM table_contact
       WHERE objid = l_s_contact_objid;

      --- Log a message into the source account that the upgrade ESN belongs to another account
      INSERT INTO x_billing_log
        (objid
        ,x_log_category
        ,x_log_title
        ,x_log_date
        ,x_details
        ,x_nickname
        ,x_esn
        ,x_originator
        ,x_contact_first_name
        ,x_contact_last_name
        ,x_agent_name
        ,x_sourcesystem
        ,billing_log2web_user)
      VALUES
        (billing_seq('X_BILLING_LOG')
        ,'ESN'
        ,'ADD_ESN'
        ,SYSDATE
        ,'ESN ' || p_t_esn || ' belongs to a different account.'
        ,billing_getnickname(p_s_esn)
        ,p_s_esn
        ,'System'
        ,l_s_contact_first_name
        ,l_s_contact_last_name
        ,'System'
        ,'WEBCSR'
        ,l_s_webuser_objid);

      -- ESN belongs to another account.
      SELECT first_name
            ,last_name
        INTO l_s_contact_first_name
            ,l_s_contact_last_name
        FROM table_contact
       WHERE objid = (SELECT web_user2contact
                        FROM table_web_user
                       WHERE objid = l_t_webuser_objid);

      --- Log a message into the target account that the upgrade ESN upgrade was attempted with this esn
      INSERT INTO x_billing_log
        (objid
        ,x_log_category
        ,x_log_title
        ,x_log_date
        ,x_details
        ,x_nickname
        ,x_esn
        ,x_originator
        ,x_contact_first_name
        ,x_contact_last_name
        ,x_agent_name
        ,x_sourcesystem
        ,billing_log2web_user)
      VALUES
        (billing_seq('X_BILLING_LOG')
        ,'ESN'
        ,'ADD_ESN'
        ,SYSDATE
        ,'ESN ' || p_t_esn || ' was attempted to be upgraded.'
        ,billing_getnickname(p_s_esn)
        ,p_s_esn
        ,'System'
        ,l_s_contact_first_name
        ,l_s_contact_last_name
        ,'System'
        ,'WEBCSR'
        ,l_t_webuser_objid);

      COMMIT;
      RETURN 3;
      -- ESN Belongs to another account
    END IF;

    RETURN 0; -- ESN exists and belongs to same account.
  EXCEPTION
    WHEN others THEN
      l_error_code    := -100;
      l_error_message := SQLERRM;
      --DBMS_OUTPUT.PUT_LINE(SQLERRM);
      RETURN - 100;
  END validate_upgrade_account;

  -------------------------------------- New Changes for SEP --------------------------------------
  PROCEDURE remove_enrollment_pending
  (
    p_enrolled_objid IN x_program_enrolled.objid%TYPE
   ,p_user           IN VARCHAR2
   ,op_result        OUT NUMBER
   ,op_msg           OUT VARCHAR2
  ) IS
    l_program_enroll_rec x_program_enrolled%ROWTYPE;
    l_program_name       x_program_parameters.x_program_name%TYPE;
    l_date               DATE DEFAULT TRUNC(SYSDATE);
    l_payment_success    NUMBER;
    l_enroll_status      VARCHAR2(50);
    retval               NUMBER; --ST_BUNDLE1
  BEGIN
    BEGIN
      -- Take only Active and Enrollment Pending ESN's
      SELECT *
        INTO l_program_enroll_rec
        FROM x_program_enrolled
       WHERE objid = p_enrolled_objid
         AND x_enrollment_status = 'ENROLLMENTPENDING'
         AND pgm_enroll2site_part IN (
                                      --
                                      -- Start CR13082 Kacosta 01/21/2011
                                      --SELECT objid
                                      -- FROM table_site_part
                                      -- WHERE x_service_id = x_esn
                                      -- AND part_status || '' = 'Active');
                                      SELECT tsp.objid
                                        FROM table_part_inst tpi
                                             ,table_site_part tsp
                                       WHERE tsp.x_service_id = x_esn
                                         AND tsp.part_status || '' = 'Active'
                                         AND tsp.objid = tpi.x_part_inst2site_part
                                         AND tpi.x_part_inst_status = '52'
                                         AND tpi.x_domain = 'PHONES');
      -- End CR13082 Kacosta 01/21/2011
      --
    EXCEPTION
      WHEN others THEN
        op_result := -100;
        op_msg    := SQLCODE || SUBSTR(SQLERRM
                                      ,1
                                      ,100);
        RETURN;
    END;

    ------ Check if it has any success payments recently
    SELECT COUNT(*)
      INTO l_payment_success
      FROM x_program_purch_hdr hdr
          ,x_program_purch_dtl dtl
     WHERE 1 = 1
       AND hdr.x_rqst_date >= l_program_enroll_rec.x_enrolled_date
       AND hdr.x_payment_type = 'ENROLLMENT'
       AND hdr.x_ics_rcode IN ('1'
                              ,'100')
       AND hdr.objid = dtl.pgm_purch_dtl2prog_hdr
       AND dtl.pgm_purch_dtl2pgm_enrolled = p_enrolled_objid;

    IF (l_payment_success > 0) THEN
      l_enroll_status := 'ENROLLED';
    ELSE
      l_enroll_status := 'ENROLLMENTFAILED';
    END IF;

    UPDATE x_program_enrolled
       SET x_enrollment_status = l_enroll_status
          ,x_update_stamp      = l_date
          ,x_reason            = 'Enrollment Pending has been removed'
     WHERE objid = p_enrolled_objid;

    IF (l_enroll_status = 'ENROLLED') THEN
      SELECT x_program_name
        INTO l_program_name
        FROM x_program_parameters
       WHERE objid = l_program_enroll_rec.pgm_enroll2pgm_parameter;

      --ST_BUNDLE1
      retval := billing_global_insert_pkg.billing_insert_prog_trans(billing_seq('X_PROGRAM_TRANS')
                                                                   ,l_program_enroll_rec.x_enrollment_status
                                                                   ,'Enrollment pending is removed by WEBCSR'
                                                                   ,NULL
                                                                   ,NULL
                                                                   ,NULL
                                                                   ,SYSDATE
                                                                   ,'Enrollment Attempt'
                                                                   ,'ENROLLMENT'
                                                                   ,l_program_name || ' Enrollment Pending removed'
                                                                   ,l_program_enroll_rec.x_sourcesystem
                                                                   ,l_program_enroll_rec.x_esn
                                                                   ,l_date
                                                                   ,l_date
                                                                   ,'I'
                                                                   ,NVL(p_user
                                                                       ,'System')
                                                                   ,l_program_enroll_rec.objid
                                                                   ,l_program_enroll_rec.pgm_enroll2web_user
                                                                   ,l_program_enroll_rec.pgm_enroll2site_part);
      /*INSERT
      INTO x_program_trans(
      objid,
      x_enrollment_status,
      x_enroll_status_reason,
      x_float_given,
      x_cooling_given,
      x_grace_period_given,
      x_trans_date,
      x_action_text,
      x_action_type,
      x_reason,
      x_sourcesystem,
      x_esn,
      x_exp_date,
      x_cooling_exp_date,
      x_update_status,
      x_update_user,
      pgm_tran2pgm_entrolled,
      pgm_trans2web_user,
      pgm_trans2site_part
      ) VALUES(
      billing_seq ('X_PROGRAM_TRANS'),
      l_program_enroll_rec.x_enrollment_status,
      'Enrollment pending is removed by WEBCSR',
      NULL,
      NULL,
      NULL,
      SYSDATE,
      'Enrollment Attempt',
      'ENROLLMENT',
      l_program_name || ' Enrollment Pending removed',
      l_program_enroll_rec.x_sourcesystem,
      l_program_enroll_rec.x_esn,
      l_date,
      l_date,
      'I',
      NVL (p_user, 'System'),
      l_program_enroll_rec.objid,
      l_program_enroll_rec.pgm_enroll2web_user,
      l_program_enroll_rec.pgm_enroll2site_part
      );*/
      --ST_BUNDLE1
    END IF;
  EXCEPTION
    WHEN others THEN
      op_result := -100;
      op_msg    := SQLCODE || SUBSTR(SQLERRM
                                    ,1
                                    ,100);

      IF (SQLCODE = -1400) THEN
        op_result := -1400;
        op_msg    := 'Entered is NULL';
      END IF;
  END remove_enrollment_pending;
  -------------------------------------- End of Changes for SEP --------------------------------------
END billing_webcsr_pkg;
/