CREATE OR REPLACE PACKAGE BODY sa.ENROLLMENT_PKG
  IS
  /*******************************************************************************************************
  --$RCSfile: enrollment_pkb.sql,v $
  --$Revision: 1.39 $
  --$Author: abustos $
  --$Date: 2018/05/25 22:15:36 $
  --$ $Log: enrollment_pkb.sql,v $
  --$ Revision 1.39  2018/05/25 22:15:36  abustos
  --$ CR57152 - Corrected is_b2b call in post_activation_enrollment
  --$
  --$ Revision 1.38  2018/05/24 21:55:42  abustos
  --$ CR57152 - Logic should only be implemented for B2B
  --$
  --$ Revision 1.37  2018/05/16 15:00:27  abustos
  --$ CR57152 - Modify main cursor in post_actvation_enrollment to correct duplicate records getting picked up.
  --$
  --$ Revision 1.36  2017/10/12 20:32:35  skambhammettu
  --$ CR53217: PROC get_discount_flag, CHECK FOR i_part_num
  --$
  --$ Revision 1.33  2017/01/20 20:33:30  akhan
  --$ refactored post_activation_enrollment
  --$
  --$ Revision 1.32  2017/01/19 22:40:45  akhan
  --$ Fixed a bug
  --$
  --$ Revision 1.31  2016/12/28 20:17:25  akhan
  --$ fixing bugs in connected products
  --$
  --$ Revision 1.30  2016/10/12 17:50:26  vlaad
  --$ Fixes for CR45766
  --$
  --$ Revision 1.26  2016/09/26 17:17:50  vlaad
  --$ Updated for Data Club
  --$
  --$ Revision 1.14 2015/01/28 22:53:48 gsaragadam
  --$ CR31683 Changes to Switch Plan procedure to handle NULL values in Source Part Number
  --$
  --$ Revision 1.13 2015/01/28 20:37:45 gsaragadam
  --$ Changes to Switch Plan procedure to handle NULL values in Source Part Number
  --$
  --$ Revision 1.13 2015/01/28 15:26:38 gsaragadam
  --$ Cr31683 Changes to Switch Plan procedure to handle NULL values in Source Part Number
  --$
  --$ Revision 1.12 2014/08/18 14:56:38 cpannala
  --$ Cr30255 Changes to post activation enrollment
  --$
  --$ Revision 1.11 2014/07/07 14:05:57 cpannala
  --$ Switch plan has changes according to Contract change
  --$
  --$ Revision 1.2 2014/02/05 16:08:23 cpannala
  --$ Description: CR25490 GETENROLLMENTDETAILS procedure addedd
  --$
  --$ Revision 1.1 2013/12/05 16:22:36 cpannala
  --$ CR22623 - B2B Initiative
  --$Description: CR25490 deenrollfromplan procedure addedd
  -----------------------------------------------------------------------------------------------------
  *******************************************************************************************************/
PROCEDURE post_activation_enrollment(op_result OUT VARCHAR2,
                                     op_msg    OUT VARCHAR2,
                                     p_esn      IN VARCHAR2)
IS
  v_count            NUMBER;
  v_sp_objid         VARCHAR2(60);
  v_purch_objid      VARCHAR2(60);
  v_enroll_objid     VARCHAR2(60);
  c_program_name     VARCHAR2(4000);
  c_charge_freq_code VARCHAR2(60);
 --
  v_b2b_err_num     NUMBER;       --CR57152 Added
  v_b2b_err_msg     VARCHAR2(30); --CR57152 Added
 --
  CURSOR enroll_pending_cases_cur(ip_esn IN VARCHAR2)
  IS
    SELECT hdr.objid  purch_objid,
           pe.objid   enroll_objid,
           pp.objid   pgm_objid,
           sp.objid   sp_objid,
           pe.x_esn   x_esn,
           cd.x_value c_dtl_value
    FROM table_case           c,
         table_x_case_detail  cd,
         table_condition      con,
         x_program_enrolled   pe,
         x_program_parameters pp,
         table_site_part      sp,
         x_program_purch_hdr  hdr,
         x_program_purch_dtl  dtl
    WHERE c.s_title                      = 'ENROLLMENT PENDING'
      AND pp.objid                       = pe.pgm_enroll2pgm_parameter
      AND sp.x_service_id                = NVL(ip_esn,sp.x_service_id)
      AND c.x_case_type                  = 'Value Plan'
      AND pe.x_enrollment_status         = 'ENROLLMENTPENDING'
      AND cd.x_name                      = 'VALUE_PLAN'
      AND pe.x_esn                       = c.x_esn
      AND cd.detail2case                 = c.objid
      AND pe.x_esn                       = sp.x_service_id
      AND sp.part_status                 = 'Active'
      AND c.case_state2condition         = con.objid
      -- AND pe.objid                       = TO_NUMBER(cd.x_value) --Added for CR57152, only applicable to B2B plans
      AND hdr.objid                      = dtl.pgm_purch_dtl2prog_hdr
      AND dtl.pgm_purch_dtl2pgm_enrolled = pe.objid
      AND hdr.x_payment_type             = 'ENROLLMENT'
      AND hdr.x_ics_rcode               IN ('1','100');

  enroll_pending_cases_rec enroll_pending_cases_cur%ROWTYPE;
BEGIN
  OPEN enroll_pending_cases_cur(p_esn);
  LOOP
    FETCH enroll_pending_cases_cur INTO enroll_pending_cases_rec;
    EXIT WHEN enroll_pending_cases_cur%NOTFOUND;

    --CR57152 - We should only process B2B customers whose value in table_case_detail = pgm_enroll_objid
    --This will correct issues with Data Club customers
    IF (sa.b2b_pkg.is_b2b ('ESN', enroll_pending_cases_rec.x_esn, NULL, v_b2b_err_num, v_b2b_err_msg) = 1)
        AND ((enroll_pending_cases_rec.c_dtl_value) <> TO_CHAR(enroll_pending_cases_rec.enroll_objid))
    THEN
      CONTINUE;
    END IF;
    --CR57152 END

    UPDATE x_program_enrolled
       SET x_enrollment_status  = 'ENROLLED',
           pgm_enroll2site_part = enroll_pending_cases_rec.sp_objid,
           x_next_charge_date   = billing_payment_recon_pkg.get_next_cycle_date(p_prog_param_objid   => enroll_pending_cases_rec.pgm_objid,
                                                                                p_current_cycle_date => SYSDATE)
    WHERE objid = enroll_pending_cases_rec.enroll_objid;

    UPDATE sa.x_program_purch_hdr
       SET x_process_date = SYSDATE
    WHERE objid = enroll_pending_cases_rec.purch_objid;

    UPDATE x_program_trans
       SET pgm_trans2site_part = enroll_pending_cases_rec.sp_objid
    WHERE pgm_tran2pgm_entrolled = enroll_pending_cases_rec.enroll_objid;
  END LOOP;

  CLOSE enroll_pending_cases_cur;
  op_result := '0';
  op_msg    := 'Success';
  COMMIT;

EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  op_result := SQLCODE;
  op_msg    := SUBSTR(SQLERRM, 1, 300);
  util_pkg.insert_error_tab_proc(ip_action       => TO_CHAR(op_result),
                                 ip_key          => p_esn,
                                 ip_program_name => 'enrollment_pkg.POST_ACTIVATION_ENROLLMENT',
                                 ip_error_text   => op_msg);
END post_activation_enrollment;
     ---
PROCEDURE getenrollmentdetails(in_esn         IN VARCHAR2,
                               out_plan_list OUT plan_list_tbl,
                               out_err_num   OUT NUMBER,
                               out_err_msg   OUT VARCHAR2)
IS
  esn_exist NUMBER := 0;
  pe_esn    NUMBER := 0;
BEGIN
  BEGIN
    SELECT COUNT(*)
      INTO esn_exist
    FROM table_part_inst
    WHERE part_serial_no = in_esn;
    IF esn_exist = 0
    THEN
      out_err_num  := -1;
      out_err_msg  := 'ESN Doesnot Exists'|| SUBSTR(SQLERRM, 1, 300);
      RETURN;
    END IF;
  END;
  ----
  BEGIN
    SELECT COUNT (*)
      INTO pe_esn
    FROM x_program_enrolled
    WHERE x_esn = in_esn
      AND x_enrollment_status = 'ENROLLED';
    IF pe_esn = 0
    THEN
      out_err_num := -1;
      out_err_msg := 'ESN Doesnot Enrolled'|| SUBSTR(sqlerrm, 1, 300);
      RETURN;
    END IF;
  END;
  ----
  IF pe_esn > 0
  THEN
    BEGIN
      SELECT PLAN_LIST_OBJ(tbl.planid,
                           tbl.plan_part_number,
                           tbl.plan_name,
                           tbl.plan_description,
                           tbl.plan_type,
                           tbl.paymentsourceid ,
                           tbl.payment_type,
                           tbl.payment_status,
                           tbl.credit_card_no,
                           tbl.credit_card_exp,
                           tbl.bank_accnt_no,
                           tbl.next_charge_date,
                           tbl.enrollment_status,
                           tbl.data_refill_limit)
      BULK COLLECT INTO out_plan_list
        FROM(SELECT pp.objid planid,
                    ff.x_source_part_num plan_part_number,
                    pp.x_program_name plan_name,
                    pp.x_program_desc plan_description,
                    pe.x_enrollment_status enrollment_status,
                    pe.auto_refill_max_limit data_refill_limit,
                    CASE
                      WHEN upper(pp.x_program_name) LIKE '%ILD%'
                      THEN 'ILD'
                      WHEN upper(pp.x_program_name) LIKE '%HPP%'
                      THEN 'HPP'
                      WHEN upper(pp.x_program_name) LIKE '%UNLIMITED%'
                      THEN 'UNLIMITED'
                      WHEN upper(pp.x_program_name) LIKE '%PAYGO%'
                      THEN 'PAYGO'
                      WHEN upper(pp.x_program_name) LIKE '%MINUTES%'
                      THEN 'PAYGO'
                    END plan_type,
                    pe.pgm_enroll2x_pymt_src paymentsourceid,
                    ps.x_pymt_type payment_type,
                    ps.x_status payment_status,
                    cc.x_customer_cc_number credit_card_no,
                    (cc.x_customer_cc_expmo|| cc.x_customer_cc_expyr) credit_card_exp,
                    ba.x_customer_acct bank_accnt_no,
                    pe.x_next_charge_date next_charge_date
            FROM x_ff_part_num_mapping ff,
                 x_program_enrolled pe,
                 x_program_parameters pp,
                 -- table_part_num pn,
                 x_payment_source ps,
                 table_x_credit_card cc,
                 table_x_bank_account ba
            WHERE ff.x_ff_objid              = pe.pgm_enroll2pgm_parameter
              and pp.objid                   = pe.pgm_enroll2pgm_parameter
              and x_enrollment_status       IN ('ENROLLED')--,'ENROLLMENTPENDING')
              AND pe.pgm_enroll2x_pymt_src   = ps.objid
              --  AND pn.objid                   = pp.prog_param2prtnum_enrlfee
              AND ps.pymt_src2x_credit_card  = cc.objid(+)
              AND ps.pymt_src2x_bank_account = ba.objid(+)
              AND pe.x_esn                   = in_esn
            )tbl;--'100000000662964'
    EXCEPTION
    WHEN OTHERS THEN
      out_err_num := -1;
      out_err_msg := 'ESN Not Enrolled In Billng Program'||SUBSTR(sqlerrm, 1, 300);
      RETURN;
    END;
  END IF;
  out_err_num := 0;
  out_err_msg := 'Success';
EXCEPTION
WHEN OTHERS THEN
  --
  out_err_num := SQLCODE;
  out_err_msg := SUBSTR(SQLERRM, 1, 300);
  UTIL_PKG.INSERT_ERROR_TAB_PROC(ip_action       => 'Enrollment Details',
                                 ip_key          => in_esn,
                                 ip_program_name => 'enrollment_pkg.GETENROLLMENTDETAILS',
                                 ip_error_text   => out_err_msg);

END getenrollmentdetails;
----
PROCEDURE deenrollfromplan(in_esn           IN VARCHAR2 ,
                           in_planid        IN NUMBER ,
                           in_deenroll_date IN DATE DEFAULT NULL ,
                           in_reason        IN VARCHAR2 ,
                           op_err_num      OUT NUMBER ,
                           op_err_msg      OUT VARCHAR2 )
IS
  l_enroll_objid       NUMBER;
  l_web_user_objid     NUMBER;
  l_sp_objid           NUMBER;
  l_x_next_charge_date DATE;
  l_pp_objid           NUMBER;
BEGIN
  IF in_esn IS NULL OR IN_PLANID IS NULL
  THEN
    op_err_num := -1 ;
    op_err_msg := 'ESN, Plan Id Required' ;
    RETURN;
  END IF;
  BEGIN
    SELECT objid,
           pgm_enroll2web_user,
           pgm_enroll2site_part,
           x_next_charge_date,
           pgm_enroll2pgm_parameter
      INTO l_enroll_objid,
           l_web_user_objid,
           l_sp_objid,
           l_x_next_charge_date,
           l_pp_objid
    FROM x_program_enrolled
    WHERE x_esn                    = in_esn
      AND x_enrollment_status      = 'ENROLLED'
      AND pgm_enroll2pgm_parameter = in_planid;
  EXCEPTION
  WHEN OTHERS THEN
    op_err_num := -1 ;
    op_err_msg := 'ESN Not Enrolled' ;
    RETURN;
  END;
  IF l_enroll_objid IS NOT NULL
  THEN
    BEGIN
      UPDATE x_program_enrolled
         SET x_enrollment_status = 'READYTOREENROLL',
             x_next_charge_date  = NVL(TO_DATE(in_deenroll_date, 'DD-Mon-YY' ), TO_DATE(NULL))
      WHERE objid = l_enroll_objid;
    EXCEPTION
    WHEN OTHERS THEN
      op_err_num := SQLCODE;
      op_err_msg := SUBSTR(SQLERRM, 1, 300) ;
      RETURN;
    END;
      ---
    BEGIN
      INSERT
      INTO x_program_trans
        ( objid,
          x_enrollment_status,
          x_enroll_status_reason,
          x_trans_date,
          x_action_text,
          x_action_type,
          x_reason,
          x_sourcesystem,
          x_esn,
          x_update_user,
          pgm_tran2pgm_entrolled,
          pgm_trans2web_user,
          pgm_trans2site_part)
      VALUES
        ( billing_seq ('x_program_trans'),
          'ENROLLED',
          'DeEnrollment Scheduled',
          sysdate,
          'voluentry DeEnrollment',
          'DE_ENROLL',
          'Customer DeEnrollment',
          'System',
          In_Esn,
          'operations',
          l_enroll_objid,
          l_web_user_objid,
          l_sp_objid);
    EXCEPTION
    WHEN OTHERS THEN
      op_err_num := SQLCODE;
      op_err_msg := SUBSTR(SQLERRM, 1, 300) ;
      RETURN;
    END;
        ---
    BEGIN
      INSERT
      INTO x_billing_log
        ( objid,
          x_log_category,
          x_log_title,
          x_log_date,
          x_details,
          x_nickname,
          x_esn,
          x_originator,
          x_contact_first_name,
          x_contact_last_name,
          x_agent_name,
          x_sourcesystem,
          billing_log2web_user)
      VALUES
        ( billing_seq ('X_BILLING_LOG'),
          'Program',
          'Program De-enrolled',
          SYSDATE,
          'Customer DeEnrollment',
          billing_getnickname (In_Esn),
          In_Esn,
          'System',
          'N/A',
          'N/A',
          'System',
          'System',
          l_web_user_objid);
    EXCEPTION
    WHEN OTHERS THEN
      op_err_num := SQLCODE;
      op_err_msg := SUBSTR(SQLERRM, 1, 300) ;
      RETURN;
    END;
  END IF;
  --commit;
  op_err_num := 0;
  op_err_msg := 'Success' ;
EXCEPTION
WHEN OTHERS THEN
  --
  ROLLBACK;
  op_err_num := SQLCODE;
  op_err_msg := SUBSTR(SQLERRM, 1, 300);
  util_pkg.insert_error_tab_proc(ip_action       => NULL,
                                 ip_key          => in_esn,
                                 ip_program_name => 'enrollment_pkg.DEENROLLFROMPLAN',
                                 ip_error_text   => op_err_msg);
END deenrollfromplan;
------------
PROCEDURE switch_plan( in_esn              IN VARCHAR2,
                       in_src_enrl_plan_id IN NUMBER,
                       io_dst_enrl_plan_id IN OUT NUMBER,
                       in_src_part_num     IN VARCHAR2,
                       io_dst_part_num     IN OUT VARCHAR2,
                       in_cycle_start_date IN OUT DATE,
                       out_err_num         OUT NUMBER,
                       out_err_msg         OUT VARCHAR2)
IS
------------------------------------------------------------------------------------
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_enroll_objid     NUMBER;
  l_next_charge_date DATE;
  l_pp_objid         NUMBER;
  l_web_user         NUMBER;
  l_pymt_src_id      NUMBER;
  l_sp_objid         NUMBER;
  l_source_part_num  VARCHAR2(40);
  l_count            NUMBER := 0;
  x_rank             NUMBER;
  n_data_plan_id     NUMBER;
  n_data_sp_objid    NUMBER;
  --CR45766
  n_servplan_objid   NUMBER;
BEGIN
  IF   (in_esn IS NULL)
    OR ((in_src_enrl_plan_id IS NULL) AND (in_src_part_num IS NULL))
    OR ((io_dst_part_num IS NULL) AND (io_dst_enrl_plan_id IS NULL))
  THEN
    out_err_num := -1;
    out_err_msg := 'Need Valid Data For ESN, Source And Destination Plan';
    --  DBMS_OUTPUT.PUT_LINE('OUT_ERR_MSG = ' || OUT_ERR_MSG);
    RETURN;
  END IF;
  IF (in_src_part_num = io_dst_part_num )or  (in_src_enrl_plan_id = io_dst_enrl_plan_id)
  THEN
    out_err_num := -3;
    out_err_msg := 'Source and Destination Plans Are Same';
    --  DBMS_OUTPUT.PUT_LINE('OUT_ERR_MSG = ' || OUT_ERR_MSG);
    RETURN;
  END IF;

  IF UPPER(in_src_part_num) = 'NO_PLAN'
  THEN
    BEGIN
      SELECT COUNT(*)
        INTO l_count
      FROM x_program_enrolled pe, x_ff_part_num_mapping ff
      WHERE 1 = 1
        AND pe.pgm_enroll2pgm_parameter = ff.x_ff_objid
        AND pe.x_esn                     = in_esn
        AND pe.x_enrollment_status       = 'ENROLLED';
      IF l_count > 0
      THEN
        out_err_num := -1;
        out_err_msg := 'ESN Enrolled In Plan When NO_PLAN AS Source Plan';
        RETURN;
      ELSE
        BEGIN
          SELECT pe.objid,
                 pe.pgm_enroll2web_user,
                 pe.pgm_enroll2x_pymt_src,
                 pe.pgm_enroll2site_part,
                 sp.x_expire_dt
            INTO l_enroll_objid,
                 l_web_user,
                 l_pymt_src_id,
                 l_sp_objid,
                 l_next_charge_date
          FROM x_program_enrolled pe,
               x_program_parameters pp,
               table_site_part sp
          WHERE pe.x_esn       = in_esn --pe.x_insert_date>=trunc(sysdate)-60
            AND pp.objid       = pe.pgm_enroll2pgm_parameter
            and sp.objid       = pe.pgm_enroll2site_part
            and sp.part_status = 'Active';
        EXCEPTION
        WHEN OTHERS THEN
          out_err_num := -1;
          out_err_msg := 'ESN Does Not Have Payment Info For Enrollment';
         -- DBMS_OUTPUT.PUT_LINE('OUT_ERR_MSG = ' || OUT_ERR_MSG);
        RETURN;
        END;
      END IF;
    END;
  ELSE
    BEGIN
      SELECT pe.objid,
             pe.x_next_charge_date,
             pe.pgm_enroll2web_user,
             pe.pgm_enroll2x_pymt_src,
             pe.pgm_enroll2site_part
        INTO l_enroll_objid,
             l_next_charge_date ,
             l_web_user,
             l_pymt_src_id,
             l_sp_objid
      FROM x_program_enrolled pe, x_ff_part_num_mapping ff
      WHERE 1                 =1
        AND pe.pgm_enroll2pgm_parameter  = ff.x_ff_objid
        AND pe.x_esn                     = in_esn
        AND pe.x_enrollment_status       = 'ENROLLED'
        AND (pe.pgm_enroll2pgm_parameter = in_src_enrl_plan_id
             OR ff.x_source_part_num = in_src_part_num) ;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      out_err_num := -1;
      out_err_msg := 'ESN Not Enrolled In Source plan';
      --DBMS_OUTPUT.PUT_LINE('OUT_ERR_MSG = ' || OUT_ERR_MSG);
      RETURN;
    WHEN OTHERS THEN
      out_err_num := -1;
      out_err_msg := 'ESN Enrollment Validation Failed';
      -- DBMS_OUTPUT.PUT_LINE('OUT_ERR_MSG = ' || OUT_ERR_MSG);
      RETURN;
    END;
  END IF;
  -- DBMS_OUTPUT.PUT_LINE('OUT_ERR_MSG = ' || OUT_ERR_MSG);
  IF (io_dst_part_num IS NOT NULL) OR (io_dst_enrl_plan_id IS NOT NULL)
  THEN
    BEGIN
      SELECT x_ff_objid, x_source_part_num
        INTO l_pp_objid, l_source_part_num
      FROM x_ff_part_num_mapping
      WHERE 1=1
        AND x_source_part_num = io_dst_part_num
         OR x_ff_objid = io_dst_enrl_plan_id;
    EXCEPTION
    WHEN OTHERS THEN
      out_err_num := -1;
      out_err_msg := 'Invalid Destinataion Partnumber';
      -- DBMS_OUTPUT.PUT_LINE('OUT_ERR_MSG = ' || OUT_ERR_MSG);
      RETURN;
    END;
  END IF;
--CR45766 DATACLUB
-- If source and destination both are same plan, then do not deenroll.

  IF (io_dst_part_num = in_src_part_num) OR (l_pp_objid = in_src_enrl_plan_id)
  THEN
    -- check if data club plan
    BEGIN
      SELECT service_plan_objid
        INTO n_servplan_objid
      FROM   service_plan_feat_pivot_mv mv
      WHERE  service_plan_objid IN ( SELECT program_para2x_sp FROM mtm_sp_x_program_param sp
                                     WHERE sp.x_sp2program_param = l_pp_objid )
        AND  mv.plan_category      = 'CONNECTED_PRODUCTS_BASE'
        AND  mv.service_plan_group = 'FP_UNLIMITED';

      -- If turns out to be DATA CLUB, then just leave an entry in x_program_trans
      -- DO NOT CHANGE ENROLLMENT STATUS
      -- Limit update part will be taken care in add_dataclub_addon_card procedure
      INSERT
      INTO x_program_trans
            ( objid,
              x_enrollment_status,
              x_enroll_status_reason,
              x_trans_date,
              x_action_text,
              x_action_type,
              x_reason,
              x_sourcesystem,
              x_esn,
              x_update_user,
              pgm_tran2pgm_entrolled,
              pgm_trans2web_user,
              pgm_trans2site_part)
        VALUES
            ( billing_seq ('x_program_trans'),
              'ENROLLED',    --CHECK
              'Data Club enrollment parameter change',
              SYSDATE,
              'ENROLLMENT parameter update',
              'ENROLLMENT_PARAM_UPDATE',
              'B2B Data club Customer auto refill limit update',
              'System',
              In_Esn,
              'operations',
              l_enroll_objid,
              l_web_user,
              l_sp_objid);

      out_err_num := 0;
      out_err_msg := 'SUCCESS';
      --Need to put a commit as this is a pragma autonomous_transaction
      COMMIT;
      RETURN;
    EXCEPTION
    WHEN no_data_found THEN
      -- If not data club, then do nothing, let the normal flow work the way it should
      NULL;
    WHEN OTHERS THEN
      util_pkg.insert_error_tab_proc(ip_action      => 'Switch_Plan',
                                    ip_key          => in_esn,
                                    ip_program_name => 'Enrollment_pkg.Switch_Plan',
                                    ip_error_text   => 'Inside data club customer limit change '||SQLERRM);
      out_err_num := -1;
      out_err_msg := 'Error deenrolling data club plan '||sqlerrm;
      RETURN;
    END;
  END IF;
-- END CR45766 DATACLUB

  IF UPPER(NVL(in_src_part_num,'-1')) <> 'NO_PLAN'
  THEN
    BEGIN
      UPDATE x_program_enrolled
      SET x_enrollment_status = 'READYTOREENROLL'
         -- X_NEXT_CHARGE_DATE  = decode(trunc(in_cycle_start_date),trunc(sysdate), NULL,in_cycle_start_date)
      WHERE OBJID  = l_enroll_objid;
    EXCEPTION
    WHEN OTHERS THEN
      out_err_num := -1;
      out_err_msg := 'De-Enrollment Failed For Switch Plan';
      RETURN;
    END;
    INSERT
    INTO x_program_trans
          ( objid,
            x_enrollment_status,
            x_enroll_status_reason,
            x_trans_date,
            x_action_text,
            x_action_type,
            x_reason,
            x_sourcesystem,
            x_esn,
            x_update_user,
            pgm_tran2pgm_entrolled,
            pgm_trans2web_user,
            pgm_trans2site_part)
      VALUES
          ( billing_seq ('x_program_trans'),
            'ENROLLED',    --CHECK
            'DeEnrollment Scheduled',
            SYSDATE,
            'Plan Change DeEnrollment',
            'DE_ENROLL',
            'B2B Customer Plan Change DeEnrollment',
            'System',
            In_Esn,
            'operations',
            l_enroll_objid,
            l_web_user,
            l_sp_objid);

    INSERT
    INTO x_billing_log
          ( objid,
            x_log_category,
            x_log_title,
            x_log_date,
            x_details,
            x_nickname,
            x_esn,
            x_originator,
            x_contact_first_name,
            x_contact_last_name,
            x_agent_name,
            x_sourcesystem,
            billing_log2web_user)
      VALUES
          ( billing_seq ('X_BILLING_LOG'),
            'Program',
            'Program De-enrolled',
            SYSDATE,
            'B2B Customer Plan Change DeEnrollment',
            billing_getnickname (In_Esn),
            In_Esn,
            'System',
            'N/A',
            'N/A',
            'System',
            'System',
            l_web_user);
    --CR43498 Data CLUB
    -- if the source plan is a data club plan and the ESN is enrolled in data plan
    -- then deenroll from data autorefill plan as well
    BEGIN
    --CR45766
    -- IF THE DESTINATION IS ALSO DATA CLUB, DO NOT DEENROLL DATA PLAN
      SELECT objid, pgm_enroll2site_part
        INTO n_data_plan_id,n_data_sp_objid
      FROM   x_program_enrolled pe
      WHERE  x_Esn                    = in_esn
      AND    x_enrollment_status      = 'ENROLLED'
      AND    EXISTS     ( SELECT 1
                          FROM   sa.mtm_sp_x_program_param sp,
                                 sa.service_plan_feat_pivot_mv mv
                          WHERE  mv.service_plan_objid = sp.program_para2x_sp
                            AND  sp.x_sp2program_param = pe.pgm_enroll2pgm_parameter
                            AND  mv.plan_type = 'DATA PLANS'
                            AND  mv.PLAN_CATEGORY = 'CONNECTED_PRODUCTS_ADDON' )
      AND    NOT EXISTS ( SELECT 1
                          FROM   service_plan_feat_pivot_mv mv
                          WHERE  service_plan_objid IN ( SELECT program_para2x_sp
                                                           FROM mtm_sp_x_program_param sp
                                                          WHERE sp.x_sp2program_param = l_pp_objid )
                                                            AND mv.plan_category      = 'CONNECTED_PRODUCTS_BASE'
                                                            AND mv.service_plan_group = 'FP_UNLIMITED' );
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
     NULL;
    WHEN OTHERS THEN
     util_pkg.insert_error_tab_proc(ip_action       => 'Switch_Plan',
                                    ip_key          => in_esn,
                                    ip_program_name => 'Enrollment_pkg.Switch_Plan',
                                    ip_error_text   => SQLERRM);
     out_err_num := -1;
     out_err_msg := 'Error deenrolling data club plan '||SQLERRM;
     RETURN;
    END;
    IF n_data_plan_id IS NOT NULL
    THEN
      BEGIN
        UPDATE x_program_enrolled
           SET x_enrollment_status = 'READYTOREENROLL'
        WHERE objid  = n_data_plan_id;
      EXCEPTION
      WHEN OTHERS THEN
        util_pkg.insert_error_tab_proc(ip_action      => 'Switch_Plan',
                                      ip_key          => in_esn,
                                      ip_program_name => 'Enrollment_pkg.Switch_Plan',
                                      ip_error_text   => SQLERRM);
        out_err_num := -1;
        out_err_msg := 'Error deenrolling data club plan '||SQLERRM;
        RETURN;
      END;
        INSERT
        INTO x_program_trans
              ( objid,
                x_enrollment_status,
                x_enroll_status_reason,
                x_trans_date,
                x_action_text,
                x_action_type,
                x_reason,
                x_sourcesystem,
                x_esn,
                x_update_user,
                pgm_tran2pgm_entrolled,
                pgm_trans2web_user,
                pgm_trans2site_part)
          VALUES
              ( billing_seq ('x_program_trans'),
                'ENROLLED',    --CHECK
                'DeEnrollment Scheduled',
                SYSDATE,
                'Plan Change DeEnrollment',
                'DE_ENROLL',
                'B2B Customer Plan Change DeEnrollment',
                'System',
                In_Esn,
                'operations',
                n_data_plan_id,
                l_web_user,
                n_data_sp_objid);
    END IF;
  END IF;
  BEGIN
    billing_inserts_pkg.inserts_billing_proc(ip_esn               => in_esn,                                      -- IN VARCHAR2,
                                             ip_pgm_param_objid   => NVL(io_dst_enrl_plan_id,l_pp_objid),         -- IN NUMBER,
                                             ip_web_user_objid    => l_web_user,                                  -- IN NUMBER,
                                             ip_payment_src_objid => l_pymt_src_id,                               -- IN NUMBER,
                                             ip_next_charge_date  => NVL(in_cycle_start_date,l_next_charge_date ),-- IN DATE,
                                             ip_sourcesystem      => 'WEB',                                       -- IN VARCHAR2,
                                             op_result            => out_err_num ,                                -- OUT NUMBER,     -- Output Result
                                             op_msg               => out_err_msg,                                 -- OUT VARCHAR2,      -- Output Message
                                             ip_enrollment_status => NULL                                         -- IN VARCHAR2 default null
                                             );
    IF out_err_num <>  0 THEN
      RETURN;
    END IF;
  END;
  COMMIT;
  out_err_num := 0;
  out_err_msg := 'Success';
  in_cycle_start_date := l_next_charge_date;
  io_dst_enrl_plan_id := l_pp_objid;
  io_dst_part_num     := l_source_part_num;
EXCEPTION
WHEN OTHERS THEN
  util_pkg.insert_error_tab_proc(ip_action       => 'Switch_Plan',
                                 ip_key          => in_esn,
                                 ip_program_name => 'Enrollment_pkg.Switch_Plan',
                                 ip_error_text   => out_err_msg);
END;
--- CR 43498 - Data Club START
-- Clearway Connected Products - Added new procedure for add on DATA card VL 07/26/2016
---
PROCEDURE add_dataclub_addon_card( in_esn              IN VARCHAR2 ,
                                   in_enrl_plan_id     IN NUMBER   ,
                                   in_enrl_partnum     IN VARCHAR2 ,
                                   in_cycle_start_date IN OUT DATE ,
                                   in_isenrolled       IN VARCHAR2 ,
                                   in_autorefill_limit IN NUMBER   ,
                                   out_err_num         OUT NUMBER  ,
                                   out_err_msg         OUT VARCHAR2 )
IS
  n_web_user          NUMBER;
  n_pymt_src_id       NUMBER;
  n_data_plan_id      NUMBER;
  n_enrl_data_plan_id NUMBER;
  n_pgmenrl_objid     NUMBER;
  n_data_webuserid    NUMBER;
  n_data_sitepartid   NUMBER;

BEGIN
  IF ( in_esn IS NULL ) THEN
    out_err_num := -1;
    out_err_msg := 'ESN NOT PASSED, CAN NOT PROCEED';
    util_pkg.insert_error_tab_proc( ip_action       => 'Switch_Plan',
                                    ip_key          => in_esn,
                                    ip_program_name => 'Enrollment_pkg.add_dataclub_addon_card',
                                    ip_error_text   => out_err_msg);
    RETURN;
  END IF;

  IF ( in_enrl_partnum IS NULL ) THEN
   out_err_num := -2;
   out_err_msg := 'ENROLLMENT PART NUMBER NOT PASSED, CAN NOT PROCEED';
   util_pkg.insert_error_tab_proc( ip_action       => 'Switch_Plan',
                                   ip_key          => in_esn,
                                   ip_program_name => 'Enrollment_pkg.add_dataclub_addon_card',
                                   ip_error_text   => out_err_msg);
    RETURN;
  END IF;

  BEGIN
    SELECT pe.pgm_enroll2web_user,
           pe.pgm_enroll2x_pymt_src
    INTO   n_web_user,
           n_pymt_src_id
    FROM   x_program_enrolled pe,
           sa.mtm_sp_x_program_param  ff,
           service_plan_feat_pivot_mv mv
    WHERE  x_enrollment_status   IN ('ENROLLED','ENROLLMENTPENDING')
      AND  x_esn                 = in_esn
      AND  ff.x_sp2program_param = pe.pgm_enroll2pgm_parameter
      AND  mv.service_plan_objid = ff.program_para2x_sp
      AND  service_plan_group    = 'FP_UNLIMITED'
      AND  mv.plan_type          <> 'DATA PLANS'
      AND  mv.plan_category      = 'CONNECTED_PRODUCTS_BASE';

  EXCEPTION
  WHEN OTHERS THEN
    out_err_num := -3;
    out_err_msg := 'ESN NOT ENROLLED IN BASE PLAN '||SQLERRM;
    util_pkg.insert_error_tab_proc( ip_action       => 'Switch_Plan',
                                    ip_key          => in_esn,
                                    ip_program_name => 'Enrollment_pkg.add_dataclub_addon_card',
                                    ip_error_text   => out_err_msg);
  END;

  --GET PROGRAM PARAMETER OBJID FOR DATA PLAN BASED ON PART NUMBER PASSED IN INPUT
  BEGIN
    SELECT x_ff_objid
      INTO n_data_plan_id
    FROM   x_ff_part_num_mapping
    WHERE  x_source_part_num = in_enrl_partnum;
  EXCEPTION
  WHEN OTHERS THEN
    out_err_num := -7;
    out_err_msg := 'Error obtaining data plan enroll plan id '||SQLERRM;
    util_pkg.insert_error_tab_proc( ip_action       => 'Switch_Plan',
                                    ip_key          => in_esn,
                                    ip_program_name => 'Enrollment_pkg.add_dataclub_addon_card',
                                    ip_error_text   => out_err_msg);
    RETURN;
  END;
  --CR45766
  -- If the ESN is already enrolled in same data plan_category
  -- then do not enroll again
  -- Just update the auto-refill limit
  BEGIN
    SELECT pgm_enroll2pgm_parameter,
           objid,
           pgm_enroll2web_user,
           pgm_enroll2site_part
    INTO   n_enrl_data_plan_id,
           n_pgmenrl_objid,
           n_data_webuserid,
           n_data_sitepartid
    FROM   x_program_enrolled pe
    WHERE  x_esn                = in_esn
    AND    x_enrollment_status  = 'ENROLLED'
    AND    EXISTS  ( SELECT 1
                     FROM   sa.mtm_sp_x_program_param sp,
                            sa.service_plan_feat_pivot_mv mv
                     WHERE  mv.service_plan_objid = sp.program_para2x_sp
                     AND    sp.x_sp2program_param = pe.pgm_enroll2pgm_parameter
                     AND    mv.plan_type = 'DATA PLANS'
                     AND    mv.plan_category = 'CONNECTED_PRODUCTS_ADDON' );

    --if same data plan then simply update the limit and be done with it
    IF n_enrl_data_plan_id = n_data_plan_id THEN
      UPDATE x_program_enrolled
      SET    auto_refill_max_limit = COALESCE(in_autorefill_limit,auto_refill_max_limit,0)
      WHERE  objid                 = n_pgmenrl_objid;

      out_err_num := 0;
      out_err_msg := 'SUCCESS';
      RETURN;
    END IF;
    -- If different data plan, then de-enroll the existing data plan before enrolling new data plan

    UPDATE x_program_enrolled
       SET x_enrollment_status = 'READYTOREENROLL'
    WHERE objid  = n_pgmenrl_objid;

    -- leave an entry in x_program_trans
    INSERT
    INTO x_program_trans
          ( objid,
            x_enrollment_status,
            x_enroll_status_reason,
            x_trans_date,
            x_action_text,
            x_action_type,
            x_reason,
            x_sourcesystem,
            x_esn,
            x_update_user,
            pgm_tran2pgm_entrolled,
            pgm_trans2web_user,
            pgm_trans2site_part)
      VALUES
          ( billing_seq ('x_program_trans'),
            'ENROLLED',    --CHECK
            'DeEnrollment Scheduled',
            SYSDATE,
            'Plan Change DeEnrollment',
            'DE_ENROLL',
            'B2B Customer Plan Change DeEnrollment',
            'System',
            In_Esn,
            'operations',
            n_pgmenrl_objid,
            n_data_webuserid,
            n_data_sitepartid);
     RETURN;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    out_err_num := -10;
    out_err_msg := 'Error checking if the esn is already enrolled in data plan '||SQLERRM;
    util_pkg.insert_error_tab_proc( ip_action       => 'Switch_Plan',
                                    ip_key          => in_esn,
                                    ip_program_name => 'Enrollment_pkg.add_dataclub_addon_card',
                                    ip_error_text   => out_err_msg);
   RETURN;
  END;

  billing_inserts_pkg.inserts_billing_proc( ip_esn               => in_esn,
                                            ip_pgm_param_objid   => n_data_plan_id,
                                            ip_web_user_objid    => n_web_user,
                                            ip_payment_src_objid => n_pymt_src_id,
                                            ip_next_charge_date  => NULL,
                                            ip_sourcesystem      => 'WEB',
                                            op_result            => out_err_num ,
                                            op_msg               => out_err_msg,
                                            ip_enrollment_status => NULL,
                                            ip_dataclub_flag     => 'Y' );

  IF  out_err_num <> 0 THEN
    util_pkg.insert_error_tab_proc( ip_action       => 'Switch_Plan',
                                    ip_key          => in_esn,
                                    ip_program_name => 'Enrollment_pkg.add_dataclub_addon_card',
                                    ip_error_text   => out_err_msg);
    RETURN;
  END IF;

  UPDATE x_program_enrolled
  SET    --x_enrollment_status   = decode(upper(in_isenrolled),'Y','ENROLLED',x_enrollment_status),
        x_enrollment_status   = 'ENROLLED',
        auto_refill_max_limit = NVL(in_autorefill_limit,999),
        auto_refill_counter   = 0,
        x_next_charge_date    = NULL
  WHERE x_esn = in_esn
  AND   pgm_enroll2pgm_parameter = n_data_plan_id
  AND   x_enrollment_status IN ('ENROLLED', 'ENROLLMENTPENDING');

  IF SQL%rowcount <> 1 THEN
    out_err_num := -8;
    out_err_msg := 'Error updating X_PROGRAM_ENROLLED, MULTIPLE ROWS UPDATED';
    util_pkg.insert_error_tab_proc( ip_action       => 'Switch_Plan',
                                    ip_key          => in_esn,
                                    ip_program_name => 'Enrollment_pkg.add_dataclub_addon_card',
                                    ip_error_text   => out_err_msg);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  out_err_num := -9;
  out_err_msg := 'Error in enrollment_pkg.add_dataclub_addon_card '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE();
  util_pkg.insert_error_tab_proc( ip_action       => 'Switch_Plan',
                                  ip_key          => in_esn,
                                  ip_program_name => 'Enrollment_pkg.add_dataclub_addon_card',
                                  ip_error_text   => out_err_msg);
END add_dataclub_addon_card;

FUNCTION check_unl_family(p_esn IN VARCHAR2)
  RETURN NUMBER
AS
/************************************************************************************************************************************/
/**  return 0 doesn't have account ,                                                                                                */
/*            not found any ESn in the same account enroll into family promo related                                                 */
/**  return 1 found any ESn in the same account enroll into family promo related                                                     */
/************************************************************************************************************************************/
  l_default NUMBER := 0;
  -- web objid associated to ESN account
  CURSOR webxESN_cur (v_esn VARCHAR2 )
  IS
    SELECT web.objid
    FROM table_part_inst pi,
         table_x_contact_part_inst cpi ,
         table_web_user web
    WHERE pi.part_serial_no               = v_esn
      AND pi.objid                        = cpi.x_contact_part_inst2part_inst
      AND cpi.x_contact_part_inst2contact = web.web_user2contact;
  webxESN_rec webxESN_cur%ROWTYPE;

  -- list of ESN in the same account except origigal ESN
  CURSOR ESNSxacc_cur (v_web NUMBER, v_esn VARCHAR2 )
  IS
    SELECT pi.part_serial_no
    FROM table_part_inst pi,
         table_x_contact_part_inst cpi ,
         table_web_user web
    WHERE web.objid                       = v_web
      AND pi.objid                        = cpi.x_contact_part_inst2part_inst
      AND cpi.x_contact_part_inst2contact = web.web_user2contact
      AND pi.part_serial_no          NOT IN (v_esn);
  ESNSxacc_rec ESNSxacc_cur%ROWTYPE;

  -- check if ESN is enrolled into progran unlimited or unlimited ILD
  CURSOR Esnxprogram_cur(v_esn VARCHAR2)
  IS
    SELECT pi.part_serial_no
    FROM x_program_parameters pp,
         x_program_enrolled pe,
         table_part_inst pi,
         sa.service_plan_feat_pivot_mv fea,
         x_service_plan_site_part spsp
    WHERE pp.objid                      = pe.PGM_ENROLL2PGM_PARAMETER
      AND pe.x_esn                      = v_esn
      AND pe.x_esn                      = pi.part_serial_no
      AND pi.x_part_inst_status         = '52'
      AND pi.x_domain                   = 'PHONES'
      AND spsp.table_site_part_id       = pe.PGM_ENROLL2SITE_PART
      AND spsp.x_service_plan_id        = fea.service_plan_objid
      AND fea.family_plan_discount_flag ='Y';
  Esnxprogram_rec Esnxprogram_cur%ROWTYPE;

  -- check if ESN is enrolled in promotion unlimited or unlimited ILD
  CURSOR Enrolled_promo_cur(p_esn VARCHAR2)
  IS
    SELECT pr.x_script_id,
           p.x_promo_code,
           grp2esn.*
    FROM x_enroll_promo_grp2esn grp2esn,
         table_x_promotion p,
         x_enroll_promo_rule pr,
         table_bus_org bo
    WHERE 1             = 1
      AND grp2esn.x_esn = p_esn
      AND SYSDATE BETWEEN grp2esn.x_start_date AND NVL(grp2esn.x_end_date, SYSDATE + 1)
      AND p.objid = grp2esn.promo_objid
      AND SYSDATE BETWEEN p.x_start_date AND p.x_end_date
      AND pr.promo_objid = grp2esn.promo_objid
      AND bo.objid       = p.promotion2bus_org
      AND (( p.objid    IN
        (SELECT promo_id
        FROM x_promotion_relation
        WHERE relationship_type = 'PARENT_CHILD'
        ))
      OR ( p.objid IN
        (SELECT related_promo_id
        FROM x_promotion_relation
        WHERE relationship_type = 'PARENT_CHILD'
        )) )
    ORDER BY pr.x_priority;
    Enrolled_promo_rec Enrolled_promo_cur%ROWTYPE;
BEGIN
  OPEN webxESN_cur(p_esn);
  FETCH webxESN_cur INTO webxESN_rec;
  -- check web objid for account
  IF webxESN_cur%notfound
  THEN
    CLOSE webxESN_cur;
    DBMS_OUTPUT.PUT_LINE( 'do not have account ');
    RETURN l_default; --- doesn't have account
  ELSE
    ---  check list of esn associated to the account
    FOR ESNSxacc_rec IN ESNSxacc_cur( webxESN_rec.objid,p_esn)
    LOOP
      OPEN Esnxprogram_cur(ESNSxacc_rec.part_serial_no);
      FETCH Esnxprogram_cur INTO Esnxprogram_rec;
      -- check if alter esn is enrolled in unl or unl ILD
      IF Esnxprogram_cur%FOUND
      THEN
        DBMS_OUTPUT.PUT_LINE( 'found any ESN in the same account enrolled into program_id '||ESNSxacc_rec.part_serial_no);
        --check if alter ESN is enrolled in promotion unl or unl family
        FOR Enrolled_promo_rec IN Enrolled_promo_cur( ESNSxacc_rec.part_serial_no)
        LOOP
          DBMS_OUTPUT.PUT_LINE( 'ESN is enrolled in promotion unl or unl family '||ESNSxacc_rec.part_serial_no);
          l_default := 1;
          CLOSE Esnxprogram_cur;
          CLOSE webxESN_cur;
          RETURN l_default;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE( 'found any ESN in the same account enrolled into program_id but is not enrolled in promo unl or unli ILD '||ESNSxacc_rec.part_serial_no);
      END IF;
      CLOSE Esnxprogram_cur;
    END LOOP;
  END IF;
  CLOSE webxESN_cur;
  DBMS_OUTPUT.PUT_LINE( 'not found any ESN in the same account enrolled into program_id ') ;
  RETURN l_default; -- not found any ESn in the same account enroll into program_id
EXCEPTION
WHEN OTHERS THEN
  RETURN l_default;
END check_unl_family;

PROCEDURE get_discount_flag(i_esn             IN VARCHAR2,
                            i_service_plan_id IN x_service_plan.OBJID%TYPE,
                            i_part_num        IN table_part_num.s_part_number%TYPE,
                            o_discount_flag  OUT VARCHAR2,
                            o_is_family_plan OUT VARCHAR2,
                            o_err_num        OUT NUMBER,
                            o_err_string     OUT VARCHAR2)
AS
  v_service_plan_id x_service_plan.OBJID%TYPE;
BEGIN
  v_service_plan_id := i_service_plan_id;
  IF i_service_plan_id IS NULL AND i_part_num IS NOT NULL
  THEN
    service_plan.sp_get_partnum_service_plan( ip_part_number => i_part_num,
                                              ip_esn         => i_esn ,
                                              op_sp_objid    => v_service_plan_id ,
                                              op_err_num     => o_err_num ,
                                              op_err_string  => o_err_string );
  END IF;
  --To check if the plan id is a family plan
  BEGIN
    SELECT NVL(family_plan_discount_flag,'N'),
           NVL(family_plan_discount_flag,'N')
      INTO o_is_family_plan,
           o_discount_flag
    FROM service_plan_feat_pivot_mv
    WHERE service_plan_objid = v_service_plan_id;
  EXCEPTION
  WHEN no_data_found THEN
    o_is_family_plan := 'N';
    o_discount_flag  := 'N';
  WHEN OTHERS THEN
    o_is_family_plan := 'N';
    o_discount_flag  := 'N';
  END;
  --return 1 found any ESn in the same account enroll into family promo related
  IF o_is_family_plan = 'Y'
  THEN
    --
    o_discount_flag := CASE check_unl_family ( p_esn => i_esn )
                         WHEN 1 THEN   'Y'
                         ELSE 'N'
                       END;
  END IF;
  o_err_num    := 0;
  o_err_string := 'SUCCESS';
EXCEPTION
WHEN OTHERS THEN
  o_discount_flag := 'N';
  o_err_num       := '1';
  o_err_string    := SUBSTR('FAIL: '||SQLERRM,1,500);
END get_discount_flag;

END enrollment_pkg;
-- ANTHILL_TEST PLSQL/SA/PackageBodies/enrollment_pkb.sql 	CR57152: 1.39
/