CREATE OR REPLACE PACKAGE BODY sa."BILLING_PAYMENT_RECON_PKG"
IS
 ---------------------------------------------------------------------------------------------
 --$RCSfile: BILLING_PAYMENT_RECON_PKG.sql,v $
  --$Revision: 1.50 $
  --$Author: sinturi $
  --$Date: 2017/11/13 19:36:04 $
  --$ $Log: BILLING_PAYMENT_RECON_PKG.sql,v $
  --$ Revision 1.50  2017/11/13 19:36:04  sinturi
  --$ Added condition
  --$
  --$ Revision 1.48  2017/10/06 22:01:22  smeganathan
  --$ added a call to vas to sync statuses
  --$
  --$ Revision 1.46  2017/02/20 18:35:57  vmallela
  --$ CR45710
  --$
  --$ Revision 1.44  2017/02/14 20:45:10  vlaad
  --$ updated an issue
  --$
  --$ Revision 1.40  2016/12/19 22:55:17  mshah
  --$ CR47120 - Fix ACH Purchases flow for NT business plans.
  --$
  --$ Revision 1.39  2016/09/22 21:02:06  vlaad
  --$ Merged with 44499
  --$
  --$ Revision 1.34  2016/09/20 22:45:56  vnainar
  --$ CR43498 addon changes  merged on top of CR43305
  --$
  --$ Revision 1.33  2016/09/20 22:15:02  mgovindarajan
  --$ CR42361 - Moved the Batch to Payment_hdr_succes(3param) procedure.
  --$
  --$ Revision 1.32  2016/09/14 19:48:49  mgovindarajan
  --$ CR42361
  --$
  --$ Revision 1.29  2016/09/08 18:55:22  mgovindarajan
  --$ CR42361 - Call new proceudre for Runtime promotions
  --$
  --$ Revision 1.28  2016/08/30 16:50:50  aganesan
  --$ New parameter added for program parameter objid value to while invoking get brm applicable flag function
  --$
  --$ Revision 1.26  2016/08/23 23:18:39  aganesan
  --$ Modified code to exclude simple mobile brand
  --$
  --$ Revision 1.24  2016/05/19 19:43:46  nmuthukkaruppan
  --$ Cursor parameter changed from l_days_cutoff to p_days_cutoff
  --$
  --$ Revision 1.22  2016/05/19 14:16:38  nmuthukkaruppan
  --$ EME CR43048 -  Removed hardcoding for ACH Reconcilation cutoff days and made it as Configurable parameter.
  --$
  --$ Revision 1.21  2015/08/11 15:01:11  jarza
  --$ CR34962
  --$
  --$ Revision 1.16  2015/01/05 19:06:18  ahabeeb
  --$ updated to fix defect 152 - branch - rel601_core
  --$
  --$ Revision 1.15  2014/10/10 21:51:36  oarbab
  --$ CR30004 upated next_charge_date
  --$
  --$ Revision 1.10  2011/12/05 16:20:10  akhan
  --$ removed extra line from CVS header
  --$
  --$ Revision 1.9  2011/12/05 16:19:10  akhan
  --$ Removed the call to payment_log proc which was causing duplicate recs
  --$
  ---------------------------------------------------------------------------------------------
PROCEDURE payment_hdr_update(
    p_batch_objid          IN NUMBER,                                       --
    p_merchant_ref_number  IN VARCHAR2,                                     --
    p_ics_rcode            IN VARCHAR2,                                     --
    p_ics_rflag            IN VARCHAR2,                                     --
    p_ics_rmsg             IN VARCHAR2,                                     --
    p_request_id           IN VARCHAR2,                                     --
    p_auth_avs             IN VARCHAR2,                                     -- CC
    p_auth_response        IN VARCHAR2,                                     --
    p_auth_time            IN VARCHAR2,                                     --
    p_auth_rcode           IN NUMBER,                                       --
    p_auth_rflag           IN VARCHAR2,                                     --
    p_auth_rmsg            IN VARCHAR2,                                     --
    p_bill_request_time    IN VARCHAR2,                                     --
    p_bill_rcode           IN NUMBER,                                       --
    p_bill_rflag           IN VARCHAR2,                                     --
    p_bill_rmsg            IN VARCHAR2,                                     --
    p_bill_trans_ref_no    IN VARCHAR2,                                     --
    p_auth_amount          IN NUMBER,                                       --
    p_bill_amount          IN NUMBER,                                       --
    p_ecp_debit_request_id IN VARCHAR2,                                     -- ACH
    p_ecp_debit_avs        IN X_ACH_PROG_TRANS.x_ecp_debit_avs%TYPE,        -- ACH
    p_ecp_debit_avs_raw    IN X_ACH_PROG_TRANS.x_ecp_debit_avs_raw%TYPE,    -- ACH
    p_ecp_rcode            IN X_ACH_PROG_TRANS.x_ecp_rcode%TYPE,            -- ACH
    p_ecp_trans_id         IN X_ACH_PROG_TRANS.x_ecp_trans_id%TYPE,         -- ACH
    p_ecp_result_code      IN X_ACH_PROG_TRANS.x_ecp_result_code%TYPE,      -- ACH
    p_ecp_rflag            IN X_ACH_PROG_TRANS.x_ecp_rflag%TYPE,            -- ACH
    p_ecp_rmsg             IN X_ACH_PROG_TRANS.x_ecp_rmsg%TYPE,             -- ACH
    p_auth_cv_result       IN VARCHAR2,                                     -- cc
    p_ecpdebit_ref_number  IN X_ACH_PROG_TRANS.x_ecp_debit_ref_number%TYPE, -- ACH   this input need to be updated in purchase hdr
    p_auth_code            IN VARCHAR2,                                     -- CC Auth Code
    op_result OUT NUMBER,                                                   --
    op_msg OUT VARCHAR2                                                     --
  )
IS
  CURSOR x_program_hdr_c ( c_batch_objid IN NUMBER, c_merchant_ref_number IN VARCHAR2 )
  IS
    SELECT a.objid,
      a.prog_hdr2prog_batch,
      a.x_merchant_ref_number,
      b.x_pymt_type
    FROM x_program_purch_hdr a,
      x_payment_source b
    WHERE a.prog_hdr2x_pymt_src = b.objid
    AND a.prog_hdr2prog_batch   = c_batch_objid
    AND a.x_merchant_ref_number = c_merchant_ref_number;
  x_program_hdr_rec x_program_hdr_c%ROWTYPE;
  l_error_message VARCHAR2 (255);
  -- For error message/
  -- CR15373 WMMC pm Start
  l_wm_error_code    NUMBER;
  L_WM_ERROR_MESSAGE VARCHAR2 (400);
  -- CR15373 WMMC pm End
BEGIN
  op_result := 0; -- By default assume success
  op_msg    := 'Success';
  OPEN x_program_hdr_c (p_batch_objid, p_merchant_ref_number);
  FETCH x_program_hdr_c INTO x_program_hdr_rec;
  IF x_program_hdr_c%NOTFOUND THEN
    IF (x_program_hdr_c%ISOPEN) THEN
      CLOSE x_program_hdr_c;
    END IF;
    RETURN;
  END IF;
  ---------------------------------------------------------------------------------------------
  ------- Update the payment header record with the response received from the payment gateway
  ----------------------------------------------------------------------------------------------
  UPDATE x_program_purch_hdr
  SET x_ics_rcode       = p_ics_rcode,
    x_ics_rflag         = p_ics_rflag,
    x_ics_rmsg          = p_ics_rmsg,
    x_request_id        = p_request_id,
    x_auth_avs          = p_auth_avs,
    x_auth_response     = p_auth_response,
    x_auth_time         = p_auth_time,
    x_auth_rcode        = p_auth_rcode,
    x_auth_code         = p_auth_code,
    x_auth_rflag        = p_auth_rflag,
    x_auth_rmsg         = p_auth_rmsg,
    x_bill_request_time = p_bill_request_time,
    x_bill_rcode        = p_bill_rcode,
    x_bill_rflag        = p_bill_rflag,
    x_bill_rmsg         = p_bill_rmsg,
    x_bill_trans_ref_no = p_bill_trans_ref_no,
    x_auth_amount       = ROUND(p_auth_amount,2),
    x_bill_amount       = ROUND(p_bill_amount,2),
    x_status            = DECODE ( P_ics_rcode,                              --- Incase of ACH success, do not change the status, since real success will be only after 5 days.
    '100', DECODE (X_rqst_type, 'ACH_PURCH', X_status,'SUCCESS' ), 'FAILED' ) -- Check with payment system for the rcode.
  WHERE objid = x_program_hdr_rec.objid;
  -- CR15373 WMMC pm Start
  IF P_ICS_RCODE <> '100' THEN
    money_card_pkg.modify_usage (X_PROGRAM_HDR_REC.OBJID * -1, L_WM_ERROR_CODE, L_WM_ERROR_MESSAGE );
    sa.data_club_pkg.batch_addon_recon(i_prog_purch_hdr_id     => x_program_hdr_rec.objid,
	                               i_prog_purch_hdr_status => 'FAILED');
  END IF;
  -- CR15373 WMMC pm End.
  ---------------------------------------------------------------------------------------------------------
  --- Update ACH Transaction/ CC Transaction tables as well
  ---------------------------------------------------------------------------------------------------------
  IF x_program_hdr_rec.x_pymt_type = 'CREDITCARD' THEN
    BEGIN
      UPDATE x_cc_prog_trans
      SET x_auth_avs               = p_auth_avs,
        x_auth_cv_result           = p_auth_cv_result
      WHERE x_cc_trans2x_purch_hdr = x_program_hdr_rec.objid;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_application_error (-20001, 'CC Tran Record Not Found');
    END;
  END IF;
  ---------------------------------------------------------------------------------------------------------
  --- Update ACH Transaction/ CC Transaction tables as well
  ---------------------------------------------------------------------------------------------------------
  IF x_program_hdr_rec.x_pymt_type = 'ACH' THEN
    BEGIN
      UPDATE x_ach_prog_trans
      SET x_ecp_debit_request_id  = p_ecp_debit_request_id,
        x_ecp_debit_avs           = p_ecp_debit_avs,
        x_ecp_debit_avs_raw       = p_ecp_debit_avs_raw,
        x_ecp_rcode               = p_ecp_rcode,
        x_ecp_trans_id            = p_ecp_trans_id,
        x_ecp_result_code         = p_ecp_result_code,
        x_ecp_rflag               = p_ecp_rflag,
        x_ecp_rmsg                = p_ecp_rmsg,
        x_ecp_debit_ref_number    = p_ecpdebit_ref_number,
        x_ecp_ref_no              = p_ecpdebit_ref_number
      WHERE ach_trans2x_purch_hdr = x_program_hdr_rec.objid;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_application_error (-20001, 'ACH Tran Record Not Found');
    END;
  END IF;
  CLOSE x_program_hdr_c;
  --- Log the failed payment.
  ------------------- Log the payment details
  IF (p_ics_rcode NOT IN ('1', '100')) THEN
    l_error_message := payment_log (x_program_hdr_rec.objid);
  END IF;
  COMMIT; -- Commit from the calling procedure
EXCEPTION
WHEN NO_DATA_FOUND THEN
  raise_application_error (-20001, 'No data Found');
  IF (x_program_hdr_c%ISOPEN) THEN
    CLOSE x_program_hdr_c;
  END IF;
WHEN OTHERS THEN
  op_result := -900;
  op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  IF (x_program_hdr_c%ISOPEN) THEN
    CLOSE x_program_hdr_c;
  END IF;
END payment_hdr_update;
PROCEDURE Payment_Hdr_Success(
    p_batch_objid IN NUMBER,
    p_hdr_objid   IN NUMBER,
    op_result OUT NUMBER,
    op_msg OUT VARCHAR2 )
IS
  -- SOA PROJECT
  v_date          DATE DEFAULT SYSDATE;
  l_notify_objid  NUMBER;
  l_pgm_trans     NUMBER;
  l_error_code    NUMBER;
  l_error_message VARCHAR2 (255);
  l_delivery_frq_code x_program_parameters.x_delivery_frq_code%TYPE;
  l_is_recurring x_program_parameters.x_is_recurring%TYPE;
  l_program_name x_program_parameters.x_program_name%TYPE;
  l_charge_frq_code  x_program_parameters.x_charge_frq_code%TYPE;
  APPERROR EXCEPTION;
  lv_promo_objid	table_x_promotion.objid%type;	--CR44499
  lv_hp_error_code	VARCHAR2(3);		        --CR44499
  lv_hp_error_msg	VARCHAR2(300);		        --CR44499
  lv_esn		x_program_purch_dtl.x_esn%type;	--CR44499
  v_b2b_sb VARCHAR2(3) := '0'; --CR47120

BEGIN

  -- By Default : Assume Success
  op_result := 0;
  op_msg    := 'Success';
  --l_notify_objid := billing_seq ('X_PROGRAM_NOTIFY');
  --l_pgm_trans := billing_seq ('X_PROGRAM_TRANS');
  FOR idx IN
  (SELECT  *
  FROM x_program_purch_hdr
  WHERE X_Status IN ('SUCCESS', 'RECURACHPENDING')
  AND objid       = p_hdr_objid --SOA PROJECT
  )
  LOOP
    --        DBMS_OUTPUT.put_line (   'PURCH ID'
    --                              || idx.purch_hdr2prog_enrolled);
    ---Review: Sharat: No direct link between purch_hdr and enrolled. Everything is via purch_dtl table.
    ---           Review the joins
    --------------------------------------------------------------------------------
    -- Pick up all the records that are associated with this payment success.
    --------------------------------------------------------------------------------
    FOR idx1 IN
    (SELECT b.* ,
      a.x_charge_desc ,
      A.pgm_purch_dtl2prog_hdr ,
      c.x_charge_frq_code, -----CR30004
      c.X_IS_RECURRING, -----CR30004
      c.X_PROG_CLASS, -----CR30004
      c.x_program_name --CR47120
    FROM x_program_purch_dtl a,
      x_program_enrolled b,
      x_program_parameters c --CR13581
    WHERE a.pgm_purch_dtl2prog_hdr   = idx.objid
    AND a.pgm_purch_dtl2pgm_enrolled = b.objid
    AND A.PGM_PURCH_DTL2PENAL_PEND  IS NULL
    AND b.pgm_enroll2pgm_parameter   = c.objid --CR13581
	--CR43305 exclude Simple mobile
	AND NOT EXISTS
    (SELECT 1
     FROM   x_program_parameters xpp
     WHERE  xpp.objid = b.pgm_enroll2pgm_parameter
     AND    get_brm_applicable_flag(i_bus_org_objid => xpp.prog_param2bus_org,i_program_parameter_objid => xpp.objid ) = 'Y' )
    )
    LOOP
      DBMS_OUTPUT.put_line (idx1.pgm_enroll2pgm_parameter);
      DBMS_OUTPUT.put_line ('program enrolled objid:' || idx1.objid);
      -- Insert data into program trans
      INSERT
      INTO x_program_trans
        (
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
        )
        VALUES
        (
          billing_seq ('X_PROGRAM_TRANS'),
          idx1.x_enrollment_status,
          'Recurring payment received successfully',
          NULL,
          NULL,
          NULL,
          v_date,
          'Payment Receipt',
          'RECURRING_PAYMENT',
          idx1.x_charge_desc,
          idx1.x_sourcesystem,
          idx1.x_esn,
          idx1.x_exp_date,
          idx1.x_cooling_exp_date,
          'I',
          'System',
          idx1.objid,
          idx1.pgm_enroll2web_user,
          idx1.pgm_enroll2site_part
        );
      DBMS_OUTPUT.put_line ( 'AFTERINSERT..........00 ESN: '|| idx1.x_esn );

--Commented as per CR47120  --{
/*
      IF (idx1.x_is_grp_primary = 1 AND idx.x_status = 'SUCCESS') AND (billing_job_pkg.is_SB_esn (NULL, idx1.x_esn) <> 1) --CR8663
        THEN
        DBMS_OUTPUT.put_line ('AFTERINSERT..........001');
        DBMS_OUTPUT.put_line ( 'inserting   x_program_notify with x_esn:' || idx1.x_esn);
        INSERT
        INTO x_program_notify
          (
            objid,
            x_esn,
            x_program_name,
            x_program_status,
            x_notify_process,
            x_notify_status,
            x_source_system,
            x_process_date,
            x_phone,
            x_language,
            x_remarks,
            pgm_notify2pgm_objid,
            pgm_notify2contact_objid,
            pgm_notify2web_user,
            pgm_notify2pgm_enroll,
            pgm_notify2purch_hdr
          )
          VALUES
          (
            billing_seq ('X_PROGRAM_NOTIFY'),
            idx1.x_esn,
            (SELECT x_program_name
            FROM x_program_parameters
            WHERE objid = idx1.pgm_enroll2pgm_parameter
            ),
            'ENROLLED',
            'PAYMENT_HDR_SUCCESS',
            'PENDING',
            idx1.x_sourcesystem,
            v_date,
            NULL,
            idx1.x_language,
            'ENROLLED SUCESSFULLY',
            idx1.pgm_enroll2pgm_parameter,
            idx1.pgm_enroll2contact,
            idx1.pgm_enroll2web_user,
            idx1.objid,
            idx1.pgm_purch_dtl2prog_hdr
          );
      END IF;
      DBMS_OUTPUT.put_line ('AFTERINSERT..........003');
      DBMS_OUTPUT.put_line ('AFTERINSERT..........111111111');
*/        -- CR47120 ends --}
      -- For ACH Payments, do not update the charge date and x_next_charge date columns
		IF NVL(IDX1.X_CHARGE_TYPE,'NULL') != 'BUNDLE' THEN --CR34962
			UPDATE x_program_enrolled
			SET x_enrollment_status = DECODE (x_enrollment_status, 'DEENROLLED', 'DEENROLLED', 'READYTOREENROLL', 'READYTOREENROLL', 'ENROLLED' ),
          x_charge_date         =
          CASE
            WHEN idx.x_status = 'SUCCESS'
            THEN NVL (x_next_charge_date, SYSDATE)
            ELSE x_charge_date
          END,
          x_next_charge_date =
          CASE
            WHEN idx.x_status = 'SUCCESS'
            THEN get_next_cycle_date ( idx1.pgm_enroll2pgm_parameter, x_next_charge_date )
            --CR47120 --{
            WHEN IDX1.X_PROG_CLASS='SWITCHBASE' and idx.x_status = 'RECURACHPENDING' and     IDX1.x_program_name like '%B2B'
            THEN x_next_charge_date
            --CR47120 --}
            --CR47971--ADDED FOR GO SMART
            WHEN sa.validate_ach_next_charge_date(  i_x_prog_class   => idx1.x_prog_class,
                                                   i_x_status       => idx.x_status,
                                                   i_x_program_name => idx1.x_program_name ) = 'Y'
            THEN x_next_charge_date
            --- CR47971
            --
            WHEN idx.x_status = 'RECURACHPENDING'
            THEN
            -- For deactivation protection put the next charge date as NULL
            get_next_cycle_date_deact ( idx1.pgm_enroll2pgm_parameter, x_next_charge_date )
            ELSE x_next_charge_date
          END,
          X_COOLING_PERIOD = NULL,
          X_EXP_DATE       = -- Start of CR30004
          CASE
            WHEN idx.x_status          = 'SUCCESS'
            AND idx1.x_charge_frq_code = '365'
            AND idx1.X_IS_RECURRING    = 1
            AND idx1.X_PROG_CLASS      = 'WARRANTY'
            THEN TRUNC (SYSDATE) + 365
            ELSE X_EXP_DATE
          END, -- End of CR30004
          x_update_stamp = v_date
			WHERE objid      = idx1.objid;
      --
      -- CR49058 changes starts..
      -- call to update the status and expiry date in x_vas_subscription
      IF  ( check_x_parameter ( p_v_x_param_name => 'NON_BASE_PROGRAM_CLASS',
                                p_v_x_param_value => idx1.x_prog_class       ) )

      THEN
        vas_management_pkg.p_update_vas_subscription ( i_esn                => idx1.x_esn,
                                                       i_program_enroll_id  => idx1.objid);
      END IF;
      -- CR49058 changes ends.
      --
		ELSIF NVL(IDX1.X_CHARGE_TYPE,'NULL') = 'BUNDLE' THEN --CR34962
			sa.BILLING_BUNDLE_PKG.SP_RECON_BUNDLED_ESNS
				(IDX1.X_ESN				--IP_ESN
				, IDX1.OBJID			--IP_PROG_ENR_OBJID
				, IDX.X_STATUS			--IP_PROG_PURCH_HDR_X_STATUS
				, OP_RESULT
				, OP_MSG);
		END IF;
      DBMS_OUTPUT.put_line (idx1.objid);
      -------------------------- Deliver Service days as applicable. --------------------------------------------
      billing_deliverservicedays (idx1.objid,l_error_code,l_error_message);
      IF (l_error_code != 0) THEN
        DBMS_OUTPUT.put_line ( 'Error in delivering service days for  ' || idx1.x_esn || ' Enrolled : ' || TO_CHAR (idx1.objid));
        --         RAISE APPERROR;
      END IF;
      DBMS_OUTPUT.put_line ('AFTERINSERT..........333');
      -------------------------------- Service Days Delivery End -------------------------------------------------
      --Notify on the primary ESN
      --Changed x_notify_status form NULL as PENDING
      ----------------- Check if there are any benefits to be delivered. Just mark the next_delivery_date as sysdate.
      ----------------- ASSUMPTION: Delivery Job runs after payment success job
      SELECT x_delivery_frq_code,
        x_is_recurring,
	x_program_name,
	x_charge_frq_code
      INTO l_delivery_frq_code,
        l_is_recurring,
	l_program_name, --CR43498
	l_charge_frq_code --CR43498
      FROM x_program_parameters
      WHERE objid             = idx1.pgm_enroll2pgm_parameter;
      IF (l_delivery_frq_code = 'AFTERCHARGE') THEN
        /*
        update x_program_enrolled
        set   x_next_delivery_date = sysdate
        where  objid = idx1.objid;
        */
        -- Deliver the benefits immediately.
        BILLING_DELIVERBENEFITS (idx1.objid, l_error_code, l_error_message );


        --CR43498 calling new recon procedure to update x_balance_transaction_order for dataclub
        IF l_program_name LIKE '%Data Club Plan%B2B%' AND l_charge_frq_code ='LOWBALANCE' THEN
         sa.data_club_pkg.batch_addon_recon( i_prog_purch_hdr_id     => p_hdr_objid,
                                             i_prog_purch_hdr_status => idx.x_status,
                                             i_esn                   => idx1.x_esn  );

        --CR43498, calling proc to update autorefill counters on service plan renewal
        ELSIF l_program_name like '%Data Club%Service B2B' and l_charge_frq_code !='LOWBALANCE' then
         sa.data_club_pkg.update_auto_refill_counter( i_esn => idx1.x_esn);
        END IF;
        IF (l_error_code != 0) THEN
          DBMS_OUTPUT.put_line ( 'Error is delivering benefits for  ' || idx1.x_esn || ' Enrolled : ' || TO_CHAR (idx1.objid) );
        END IF;
        /* If this is a sample deactivation protection program, de-enroll from the program */
        IF (l_is_recurring = 0) THEN
          INSERT
          INTO x_program_trans
            (
              objid,
              x_enrollment_status,
              x_enroll_status_reason,
              x_trans_date,
              x_action_text,
              x_action_type,
              x_reason,
              x_sourcesystem,
              x_esn,
              x_exp_date,
              pgm_tran2pgm_entrolled,
              pgm_trans2web_user,
              pgm_trans2site_part
            )
            VALUES
            (
              billing_seq ('X_PROGRAM_TRANS'),
              idx1.x_enrollment_status,
              'Deactivation protection-Sample Program',
              SYSDATE,
              'De-enroll sample program',
              'DEENROLL',
              (SELECT x_program_name
                || ' De-enrolled due to benefits delivery from sample program'
              FROM x_program_parameters
              WHERE objid = idx1.pgm_enroll2pgm_parameter
              ),
              idx1.x_sourcesystem,
              idx1.x_esn,
              idx1.x_exp_date,
              idx1.objid,
              idx1.pgm_enroll2web_user,
              idx1.pgm_enroll2site_part
            );
          UPDATE x_program_enrolled
          SET x_enrollment_status = 'DEENROLLED',
            x_reason              = 'System Deenrollment',
            x_cooling_exp_date    = NULL,
            PGM_ENROLL2X_PYMT_SRC = NULL,
            x_update_stamp        = SYSDATE
          WHERE objid             = idx1.objid;
        END IF;
        /* -------------------------------------------------------------------------------- */
      END IF;
      DBMS_OUTPUT.put_line ('AFTERINSERT..........44');
      -------------- Minutes delivery - immediately after charge -- end.
      --CR47120 --{
      IF  IDX1.X_PROG_CLASS='SWITCHBASE' -- AND IDX1.x_program_name LIKE '%B2B' -- As part of CR45710 took out
      THEN
       v_b2b_sb := '1';
      END IF;
      --CR47120 --}
      --CR47971--
      IF  sa.validate_ach_next_charge_date(  i_x_prog_class   => idx1.x_prog_class,
                                             i_x_status       => idx.x_status,
                                             i_x_program_name => idx1.x_program_name ) = 'Y'
      THEN
       v_b2b_sb := '1';
      END IF;
      --CR47971--
    END LOOP;
    ------------------ Update the status of Purchase header to processed for the record.
    DBMS_OUTPUT.put_line ('Befor calling purch hdr upd');
    UPDATE x_program_purch_hdr
    SET x_status =
      CASE
        WHEN idx.x_status = 'SUCCESS'
        THEN 'PROCESSED'
        --CR47120 --{
        WHEN idx.x_status = 'RECURACHPENDING' AND v_b2b_sb = '1'
        THEN 'PROCESSED'
        --CR47120 --}
        ELSE idx.x_status
      END
    WHERE objid = idx.objid;
    DBMS_OUTPUT.put_line ('After purch upd success');
    ------------------- Log the payment details
    --CR19077(removed duplicate call to this proc)
    --         l_error_message := payment_log ( idx.objid ) ;
    --CR19077 end;

	--CR44499 START
	IF idx.x_status = 'SUCCESS'
	THEN
		BEGIN
			SELECT PE.x_esn, DISC_HIST.pgm_discount2x_promo
			INTO 	lv_esn, lv_promo_objid
			FROM 	X_PROGRAM_ENROLLED PE
			,X_PROGRAM_DISCOUNT_HIST DISC_HIST
			,X_PROGRAM_PURCH_HDR HDR
			WHERE 1 		= 1
			AND DISC_HIST.pgm_discount2pgm_enrolled 	= PE.OBJID
			AND DISC_HIST.PGM_DISCOUNT2PROG_HDR 	      	= HDR.OBJID
			AND HDR.OBJID                               	= idx.objid
			;
		EXCEPTION WHEN OTHERS
		THEN
			lv_promo_objid	:= NULL;
		END;
		sa.PKG_FLIP_ENROLLED_ESN_PROMO.UPDATE_HOLIDAY_PROMO_BALANCE	-- decrement holiday promo usage counter
		(lv_esn
		,lv_promo_objid
		,lv_hp_error_code
		,lv_hp_error_msg
		);
	END IF;
	--CR44499 END


  END LOOP;
  /*  ------------------------------------------ Removed Special Handling for advance PayNow cases for SOA batch  04/27/2011 -------------------------- */
EXCEPTION
WHEN OTHERS THEN
  Op_Result := -900;
  op_msg    := SQLCODE || 'payment_hdr_success: ' || SUBSTR (SQLERRM, 1, 200);
END payment_hdr_success;
PROCEDURE payment_hdr_success(
    p_batch_objid IN NUMBER,
    op_result OUT NUMBER,
    op_msg OUT VARCHAR2 )
IS
  v_date          DATE DEFAULT SYSDATE;
  l_notify_objid  NUMBER;
  l_pgm_trans     NUMBER;
  l_error_code    NUMBER;
  l_error_message VARCHAR2 (255);
  l_delivery_frq_code x_program_parameters.x_delivery_frq_code%TYPE;
  l_is_recurring x_program_parameters.x_is_recurring%TYPE;
  l_program_name x_program_parameters.x_program_name%TYPE;
  l_charge_frq_code  x_program_parameters.x_charge_frq_code%TYPE;
  APPERROR EXCEPTION;
  lv_promo_objid	table_x_promotion.objid%type;	--CR44499
  lv_hp_error_code	VARCHAR2(3);		        --CR44499
  lv_hp_error_msg	VARCHAR2(300);		        --CR44499
  lv_esn		x_program_purch_dtl.x_esn%type;	--CR44499
  v_b2b_sb VARCHAR2(3) := '0'; --CR47120

BEGIN
  -- By Default : Assume Success
  op_result := 0;
  op_msg    := 'Success';
  --l_notify_objid := billing_seq ('X_PROGRAM_NOTIFY');
  --l_pgm_trans := billing_seq ('X_PROGRAM_TRANS');
  FOR idx IN
  (SELECT  *
  FROM x_program_purch_hdr
  WHERE x_status         IN ('SUCCESS', 'RECURACHPENDING')
  AND prog_hdr2prog_batch = p_batch_objid
  )
  LOOP
    --        DBMS_OUTPUT.put_line (   'PURCH ID'
    --                              || idx.purch_hdr2prog_enrolled);
    ---Review: Sharat: No direct link between purch_hdr and enrolled. Everything is via purch_dtl table.
    ---           Review the joins
    --------------------------------------------------------------------------------
    -- Pick up all the records that are associated with this payment success.
    --------------------------------------------------------------------------------
    FOR idx1 IN
    (SELECT b.*,
      a.x_charge_desc,
      A.pgm_purch_dtl2prog_hdr,
      c.x_charge_frq_code, -----CR30004
      c.X_IS_RECURRING,    -----CR30004
      c.X_PROG_CLASS,       -----CR30004
      c.x_program_name --CR47120
    FROM x_program_purch_dtl a,
      x_program_enrolled b,
      x_program_parameters c --CR13581
    WHERE a.pgm_purch_dtl2prog_hdr   = idx.objid
    AND a.pgm_purch_dtl2pgm_enrolled = b.objid
    AND A.PGM_PURCH_DTL2PENAL_PEND  IS NULL
    AND b.pgm_enroll2pgm_parameter   = c.objid
    ) --CR13581
    LOOP
      DBMS_OUTPUT.put_line (idx1.pgm_enroll2pgm_parameter);
      DBMS_OUTPUT.put_line ('program enrolled objid:' || idx1.objid);
      -- Insert data into program trans
      INSERT
      INTO x_program_trans
        (
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
        )
        VALUES
        (
          billing_seq ('X_PROGRAM_TRANS'),
          idx1.x_enrollment_status,
          'Recurring payment received successfully',
          NULL,
          NULL,
          NULL,
          v_date,
          'Payment Receipt',
          'RECURRING_PAYMENT',
          idx1.x_charge_desc,
          idx1.x_sourcesystem,
          idx1.x_esn,
          idx1.x_exp_date,
          idx1.x_cooling_exp_date,
          'I',
          'System',
          idx1.objid,
          idx1.pgm_enroll2web_user,
          idx1.pgm_enroll2site_part
        );

--Commented as per CR47120  --{
/*
      IF (idx1.x_is_grp_primary = 1 AND idx.x_status = 'SUCCESS') AND (billing_job_pkg.is_SB_esn (NULL, idx1.x_esn) <> 1) --CR8663
        THEN
        INSERT
        INTO x_program_notify
          (
            objid,
            x_esn,
            x_program_name,
            x_program_status,
            x_notify_process,
            x_notify_status,
            x_source_system,
            x_process_date,
            x_phone,
            x_language,
            x_remarks,
            pgm_notify2pgm_objid,
            pgm_notify2contact_objid,
            pgm_notify2web_user,
            pgm_notify2pgm_enroll,
            pgm_notify2purch_hdr
          )
          VALUES
          (
            billing_seq ('X_PROGRAM_NOTIFY'),
            idx1.x_esn,
            (SELECT x_program_name
            FROM x_program_parameters
            WHERE objid = idx1.pgm_enroll2pgm_parameter
            ),
            'ENROLLED',
            'PAYMENT_HDR_SUCCESS',
            'PENDING',
            idx1.x_sourcesystem,
            v_date,
            NULL,
            idx1.x_language,
            'ENROLLED SUCESSFULLY',
            idx1.pgm_enroll2pgm_parameter,
            idx1.pgm_enroll2contact,
            idx1.pgm_enroll2web_user,
            idx1.objid,
            idx1.pgm_purch_dtl2prog_hdr
          );
      END IF;
*/       --CR47120  --}
      -- For ACH Payments, do not update the charge date and x_next_charge date columns
		IF NVL(IDX1.X_CHARGE_TYPE,'NULL') != 'BUNDLE' THEN --CR34962
			UPDATE x_program_enrolled
			SET x_enrollment_status = DECODE (x_enrollment_status, 'DEENROLLED', 'DEENROLLED', 'READYTOREENROLL', 'READYTOREENROLL', 'ENROLLED'),
			x_charge_date         =
			CASE
			  WHEN idx.x_status = 'SUCCESS'
			  THEN NVL (x_next_charge_date, SYSDATE)
			  ELSE x_charge_date
			END,
			x_next_charge_date =
			CASE
			  WHEN idx.x_status = 'SUCCESS'
			  THEN get_next_cycle_date ( idx1.pgm_enroll2pgm_parameter, x_next_charge_date)
     --CR47120 --{
     WHEN IDX1.X_PROG_CLASS='SWITCHBASE' and idx.x_status = 'RECURACHPENDING' and     IDX1.x_program_name like '%B2B'
     THEN x_next_charge_date
     --CR47120 --}
     --CR47971--ADDED FOR GO SMART
     WHEN sa.validate_ach_next_charge_date(  i_x_prog_class   => idx1.x_prog_class,
                                             i_x_status       => idx.x_status,
                                             i_x_program_name => idx1.x_program_name ) = 'Y'
     THEN x_next_charge_date
     --- CR47971

			  WHEN idx.x_status = 'RECURACHPENDING'
			  THEN get_next_cycle_date_deact ( idx1.pgm_enroll2pgm_parameter, x_next_charge_date ) -- For deactivation protection put the next charge date as NULL
			  ELSE x_next_charge_date
			END,
			X_COOLING_PERIOD = NULL ,
			X_EXP_DATE       = -- Start of CR30004
			CASE
			  WHEN idx.x_status          = 'SUCCESS'
			  AND idx1.x_charge_frq_code = '365'
			  AND idx1.X_IS_RECURRING    = 1
			  AND idx1.X_PROG_CLASS      = 'WARRANTY'
			  THEN TRUNC (SYSDATE) + 365
			  ELSE X_EXP_DATE
			END, -- End of CR30004
			x_update_stamp = v_date
			WHERE objid      = idx1.objid;
		ELSIF NVL(IDX1.X_CHARGE_TYPE,'NULL') = 'BUNDLE' THEN --CR34962
			sa.BILLING_BUNDLE_PKG.SP_RECON_BUNDLED_ESNS
				(IDX1.X_ESN				--IP_ESN
				, IDX1.OBJID			--IP_PROG_ENR_OBJID
				, IDX.X_STATUS			--IP_PROG_PURCH_HDR_X_STATUS
				, OP_RESULT
				, OP_MSG);
		END IF;
		DBMS_OUTPUT.put_line (idx1.objid);
      -------------------------- Deliver Service days as applicable. --------------------------------------------
      billing_deliverservicedays (idx1.objid,l_error_code,l_error_message);
      IF (l_error_code != 0) THEN
        DBMS_OUTPUT.put_line ( 'Error in delivering service days for  ' || idx1.x_esn || ' Enrolled : ' || TO_CHAR (idx1.objid) );
        --         RAISE APPERROR;
      END IF;
      -------------------------------- Service Days Delivery End -------------------------------------------------
      --Notify on the primary ESN
      --Changed x_notify_status form NULL as PENDING
      ----------------- Check if there are any benefits to be delivered. Just mark the next_delivery_date as sysdate.
      ----------------- ASSUMPTION: Delivery Job runs after payment success job
      SELECT x_delivery_frq_code,
        x_is_recurring,
	x_program_name,
	x_charge_frq_code
      INTO l_delivery_frq_code,
        l_is_recurring,
	l_program_name,
	l_charge_frq_code
      FROM x_program_parameters
      WHERE objid             = idx1.pgm_enroll2pgm_parameter;
      IF (l_delivery_frq_code = 'AFTERCHARGE') THEN
        /*
        update x_program_enrolled
        set   x_next_delivery_date = sysdate
        where  objid = idx1.objid;
        */
        -- Deliver the benefits immediately.
        BILLING_DELIVERBENEFITS (idx1.objid,l_error_code,l_error_message);

		--CR43498 calling new recon procedure to update x_balance_transaction_order for dataclub
	IF l_program_name LIKE '%Data Club Plan%B2B%' AND l_charge_frq_code ='LOWBALANCE' THEN
	  sa.data_club_pkg.batch_addon_recon(i_prog_purch_hdr_id     => idx.objid,
	                                     i_prog_purch_hdr_status => idx.x_status,
                                             i_esn		     => idx1.x_esn  );
        END IF;

        IF (l_error_code != 0) THEN
          DBMS_OUTPUT.put_line ( 'Error is delivering benefits for  ' || idx1.x_esn || ' Enrolled : ' || TO_CHAR (idx1.objid) );
        END IF;
        /* If this is a sample deactivation protection program, de-enroll from the program */
        IF (l_is_recurring = 0) THEN
          INSERT
          INTO x_program_trans
            (
              objid,
              x_enrollment_status,
              x_enroll_status_reason,
              x_trans_date,
              x_action_text,
              x_action_type,
              x_reason,
              x_sourcesystem,
              x_esn,
              x_exp_date,
              pgm_tran2pgm_entrolled,
              pgm_trans2web_user,
              pgm_trans2site_part
            )
            VALUES
            (
              billing_seq ('X_PROGRAM_TRANS'),
              idx1.x_enrollment_status,
              'Deactivation protection-Sample Program',
              SYSDATE,
              'De-enroll sample program',
              'DEENROLL',
              (SELECT x_program_name
                || ' De-enrolled due to benefits delivery from sample program'
              FROM x_program_parameters
              WHERE objid = idx1.pgm_enroll2pgm_parameter
              ),
              idx1.x_sourcesystem,
              idx1.x_esn,
              idx1.x_exp_date,
              idx1.objid,
              idx1.pgm_enroll2web_user,
              idx1.pgm_enroll2site_part
            );
          UPDATE x_program_enrolled
          SET x_enrollment_status = 'DEENROLLED',
            x_reason              = 'System Deenrollment',
            x_cooling_exp_date    = NULL,
            PGM_ENROLL2X_PYMT_SRC = NULL,
            x_update_stamp        = SYSDATE
          WHERE objid             = idx1.objid;
        END IF;
        /* -------------------------------------------------------------------------------- */
      END IF;
      -------------- Minutes delivery - immediately after charge -- end.
      --CR47120 --{
      IF  IDX1.X_PROG_CLASS='SWITCHBASE' AND IDX1.x_program_name LIKE '%B2B'
      THEN
       v_b2b_sb := '1';
      END IF;
      --CR47120 --}
      IF  sa.validate_ach_next_charge_date(  i_x_prog_class   => idx1.x_prog_class,
                                             i_x_status       => idx.x_status,
                                             i_x_program_name => idx1.x_program_name ) = 'Y'
      THEN
       v_b2b_sb := '1';
      END IF;
      --CR47971--
    END LOOP;
    ------------------ Update the status of Purchase header to processed for the record.
    DBMS_OUTPUT.put_line ('Befor calling purch hdr upd');
    UPDATE x_program_purch_hdr
    SET x_status =
      CASE
        WHEN idx.x_status = 'SUCCESS'
        THEN 'PROCESSED'
        --CR47120 --{
        WHEN idx.x_status = 'RECURACHPENDING' AND v_b2b_sb = '1'
        THEN 'PROCESSED'
        --CR47120 --}
        ELSE idx.x_status
      END
    WHERE objid = idx.objid;
    DBMS_OUTPUT.put_line ('After purch upd success');
    ------------------- Log the payment details
    l_error_message := payment_log (idx.objid);

    	--CR44499 START
	IF idx.x_status = 'SUCCESS'
	THEN
		BEGIN
			SELECT PE.x_esn, DISC_HIST.pgm_discount2x_promo
			INTO 	lv_esn, lv_promo_objid
			FROM 	X_PROGRAM_ENROLLED PE
			,X_PROGRAM_DISCOUNT_HIST DISC_HIST
			,X_PROGRAM_PURCH_HDR HDR
			WHERE 1 		= 1
			AND DISC_HIST.pgm_discount2pgm_enrolled 	= PE.OBJID
			AND DISC_HIST.PGM_DISCOUNT2PROG_HDR 	      	= HDR.OBJID
			AND HDR.OBJID                               	= idx.objid
			;
		EXCEPTION WHEN OTHERS
		THEN
			lv_promo_objid	:= NULL;
		END;
		sa.PKG_FLIP_ENROLLED_ESN_PROMO.UPDATE_HOLIDAY_PROMO_BALANCE	-- decrement holiday promo usage counter
		(lv_esn
		,lv_promo_objid
		,lv_hp_error_code
		,lv_hp_error_msg
		);
	END IF;
	--CR44499 END



  END LOOP;
  /*  ------------------------------------------ Special Handling for advance PayNow cases ---------------------------- */
  /*  There may be some records that have been paid earlier but service days havent been delivered.
  Pick up these records are deliver the service days.
  ASSUMPTION: No need to worry about minutes delivery since the front-end would have put in the right values
  for the job to pick up.
  ------------------------------------------------------------------------------------------------------------------
  */
  FOR idx1 IN
  (SELECT   *
  FROM x_program_enrolled
  WHERE x_enrollment_status   = 'ENROLLED'
  AND x_next_charge_date      > SYSDATE
  AND X_SERVICE_DELIVERY_DATE < SYSDATE
  )
  LOOP
    -------------------------- Deliver Service days as applicable. --------------------------------------------
    billing_deliverservicedays (idx1.objid,l_error_code,l_error_message);
    IF (l_error_code != 0) THEN
      DBMS_OUTPUT.put_line ( 'Error in delivering service days for  ' || idx1.x_esn || ' Enrolled : ' || TO_CHAR (idx1.objid));
    END IF;
    -------------------------------- Service Days Delivery End -------------------------------------------------
    ----------------- Check if there are any benefits to be delivered. Just mark the next_delivery_date as sysdate.
    ----------------- ASSUMPTION: Delivery Job runs after payment success job
    SELECT x_delivery_frq_code
    INTO l_delivery_frq_code
    FROM x_program_parameters
    WHERE objid             = idx1.pgm_enroll2pgm_parameter;
    IF (l_delivery_frq_code = 'AFTERCHARGE') THEN
      -- Deliver the benefits immediately.
      BILLING_DELIVERBENEFITS (idx1.objid, l_error_code, l_error_message);
      IF (l_error_code != 0) THEN
        DBMS_OUTPUT.put_line ( 'Error is delivering benefits for  ' || idx1.x_esn || ' Enrolled : ' || TO_CHAR (idx1.objid));
      END IF;
    END IF;
    -------------- Minutes delivery - immediately after charge -- end.
    ----------------------------------------------------------------------------------------------------------
    UPDATE x_program_enrolled
    SET X_SERVICE_DELIVERY_DATE = NULL
    WHERE objid                 = idx1.objid;
    ---------------------------------------------------------------------------------------------------------
  END LOOP;
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  op_result := -900;
  op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
END payment_hdr_success;
FUNCTION get_next_cycle_date(
    p_prog_param_objid   IN NUMBER,
    p_current_cycle_date IN DATE)
  RETURN DATE
IS
  l_next_cycle_date DATE;
BEGIN
  SELECT ---- Start of CR30004
    (case when  x_charge_frq_code =  'MONTHLY'
			then  ADD_MONTHS (NVL(p_current_cycle_date, SYSDATE), 1)
		  when x_charge_frq_code in ('LOWBALANCE', 'PASTDUE') then  NULL
		  when x_prog_class = 'WARRANTY' and X_IS_RECURRING=1 and x_charge_frq_code = '365' then NULL  -- CR30004 new change
          else NVL (p_current_cycle_date, SYSDATE) + TO_NUMBER (x_charge_frq_code)
      end
	)---- End of CR30004
      INTO l_next_cycle_date
      FROM x_program_parameters
      WHERE objid = p_prog_param_objid;
      RETURN TRUNC(l_next_cycle_date); --Truncate the date so that the jobs that run in the morning can pick up the records
      EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
END;

FUNCTION get_next_cycle_date_deact(
    p_prog_param_objid   IN NUMBER,
    p_current_cycle_date IN DATE)
  RETURN DATE
IS
  l_next_cycle_date DATE;
BEGIN
  SELECT DECODE ('LOWBALANCE', NULL, 'PASTDUE', NULL, p_current_cycle_date)
  INTO l_next_cycle_date
  FROM x_program_parameters
  WHERE objid = p_prog_param_objid;
  RETURN l_next_cycle_date;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END;
/*
This function returns the next_cycle_date for the primary ESN
*/
FUNCTION get_primary_cycle_date(
    p_prog_enroll_objid IN NUMBER)
  RETURN DATE
IS
  l_next_cycle_date DATE;
BEGIN
  SELECT x_next_charge_date
  INTO l_next_cycle_date
  FROM x_program_enrolled
  WHERE objid = p_prog_enroll_objid;
  RETURN l_next_cycle_date;
EXCEPTION
WHEN OTHERS THEN
  DBMS_OUTPUT.put_line ( 'Exception Raised - Returning next charge date as null ' || SQLERRM);
  RETURN NULL;
END;
/* This procedure is used to treat a payment as success (ACH) if we do not receive
any negative information */
/*
ACH Recon Cut off date is changed to 5 business days instead of 5 days
Assuming 5 Business days is equal to 8 days by keeping the long weekends in consideration
This is discussed with Business and PMO agreed on 04/20/2007 ... Ramu
*/
PROCEDURE ach_recon(
    op_code OUT NUMBER,
    op_result OUT VARCHAR2)
IS
  -- CutOff days changed to 6 days as per Business decision...
  --EME CR43048 - Removed hardcoding and made it as Configurable parameter.
  l_days_cutoff NUMBER ; -- 5 Business days


  l_program_purch_hdr x_program_purch_hdr.objid%TYPE;
  v_date DATE DEFAULT SYSDATE;
  CURSOR ach_payment_c (p_days_cutoff  NUMBER)    --EME CR43048
  IS
    SELECT objid,
      x_status
    FROM x_program_purch_hdr
    WHERE x_status                    IN ('PAYNOWACHPENDING', 'ENROLLACHPENDING', 'RECURACHPENDING') -- is always assumed positive
    AND (TRUNC (x_rqst_date) < SYSDATE - p_days_cutoff);     --EME CR43048
  ach_payment_rec ach_payment_c%ROWTYPE;
  -- Notification Details
  l_enroll_objid  NUMBER;
  l_program_objid NUMBER;
  l_esn x_program_enrolled.x_esn%TYPE;
  l_source_system x_program_enrolled.x_sourcesystem%TYPE;
  l_language x_program_enrolled.x_language%TYPE;
  l_enrollment_status x_program_enrolled.x_enrollment_status%TYPE;
  -- Ramu 06/27/2007
  l_enrollment_status_new x_program_enrolled.x_enrollment_status%TYPE;
  l_contact NUMBER;
  l_webuser NUMBER;
  l_primary NUMBER;
  -- Delivery
  l_delivery_frq_code x_program_parameters.x_delivery_frq_code%TYPE;
  -- Program Parameters
  l_is_recurring x_program_parameters.x_is_recurring%TYPE;
  l_benefit_days x_program_parameters.x_benefit_days%TYPE;
  -- Payment
  l_next_charge_date x_program_enrolled.x_next_charge_date%TYPE;
  -- Ramu Changes 04/18/2007
  l_delay_enroll_flag x_program_parameters.X_DELAY_ENROLL_ACH_FLAG%TYPE;
  -- PEC Parallel operation
  pec_parallel_operation BOOLEAN := TRUE;
  l_is_pec_customer      NUMBER;
  l_error                NUMBER;
  l_error_message        VARCHAR2 (255);
  --CR47971
  l_program_class        x_program_parameters.x_prog_class%TYPE;
BEGIN
  /* Pickup all the records that used ACH as a payment type and the current status is
  ENROLLACHPENDING / PAYNOWACHPENDING. If no response is received for 8 business days, then
  the payment is treated as SUCCESS */
  op_code   := 0;
  op_result := 'Success';
  --EME CR43048 - Start
  BEGIN
  SELECT  X_PARAM_VALUE
    INTO  l_days_cutoff
    FROM  table_x_parameters
   WHERE  x_param_name = 'ACH_RECON_CUTOFF_DAYS';
  EXCEPTION
    WHEN  OTHERS THEN
	l_days_cutoff := 0;
  END;
  --EME CR43048 - End

  OPEN ach_payment_c (l_days_cutoff) ;    --EME CR43048
  LOOP
    FETCH ach_payment_c
    INTO ach_payment_rec;
    EXIT
  WHEN ach_payment_c%NOTFOUND;
    --         IF ( ach_payment_rec.x_status != 'RECURACHPENDING' ) then
    FOR program_purch_loop IN
    (SELECT pgm_purch_dtl2pgm_enrolled
    FROM x_program_purch_dtl
    WHERE pgm_purch_dtl2prog_hdr  = ach_payment_rec.objid
    AND PGM_PURCH_DTL2PENAL_PEND IS NULL
    ORDER BY objid
    )
    LOOP
      BEGIN
        --- Update records in ACH Trans
        INSERT
        INTO x_program_trans
          (
            objid,
            x_enrollment_status,
            x_enroll_status_reason,
            x_trans_date,
            x_action_text,
            x_action_type,
            x_reason,
            x_sourcesystem,
            x_esn,
            x_exp_date,
            pgm_tran2pgm_entrolled,
            pgm_trans2web_user,
            pgm_trans2site_part
          )
        SELECT billing_seq ('X_PROGRAM_TRANS'),
          x_enrollment_status,
          'ACH Payment assumed successful',
          v_date,
          'Payment Success',
          CASE
            WHEN x_enrollment_status IN ('ENROLLMENTSCHEDULED', 'ENROLLMENTPENDING')
            THEN 'ENROLLMENT'
            ELSE 'Payment'
          END,
          (SELECT x_program_name
            || ' '
            || DECODE ( x_enrollment_status, 'ENROLLMENTPENDING', 'Enrollment Pending', 'ENROLLMENTSCHEDULED', 'Enrollment Scheduled', INITCAP (x_enrollment_status))
            || ' - ACH payment assumed successful'
          FROM x_program_parameters
          WHERE objid = pgm_enroll2pgm_parameter
          ),
          x_sourcesystem,
          x_esn,
          x_exp_date,
          objid,
          pgm_enroll2web_user,
          pgm_enroll2site_part
        FROM x_program_enrolled
        WHERE objid IN (program_purch_loop.pgm_purch_dtl2pgm_enrolled);
        --- Insert new record in ACH Trans
        --- if the enrollment is transitioning from 'ENROLLMENTPENDING' to 'ENROLLED'
        --- Ramu 06/27/2007 -- This change is for Datawarehouse reporting purpose..  CR6441
        SELECT x_enrollment_status
        INTO l_enrollment_status_new
        FROM x_program_enrolled
        WHERE objid                 IN (program_purch_loop.pgm_purch_dtl2pgm_enrolled);
        IF (l_enrollment_status_new IN ('ENROLLMENTSCHEDULED', 'ENROLLMENTPENDING')) THEN
          INSERT
          INTO x_program_trans
            (
              objid,
              x_enrollment_status,
              x_enroll_status_reason,
              x_trans_date,
              x_action_text,
              x_action_type,
              x_reason,
              x_sourcesystem,
              x_esn,
              x_exp_date,
              pgm_tran2pgm_entrolled,
              pgm_trans2web_user,
              pgm_trans2site_part
            )
          SELECT billing_seq ('X_PROGRAM_TRANS'),
            'ENROLLED',
            'Enrolled Successfully',
            v_date,
            'Payment Success',
            'ENROLLMENT',
            (SELECT x_program_name
              || ' Enrolled - ACH payment assumed successful'
            FROM x_program_parameters
            WHERE objid = pgm_enroll2pgm_parameter
            ),
            x_sourcesystem,
            x_esn,
            x_exp_date,
            objid,
            pgm_enroll2web_user,
            pgm_enroll2site_part
          FROM x_program_enrolled
          WHERE objid IN (program_purch_loop.pgm_purch_dtl2pgm_enrolled);
        END IF;
        -------------------------------------------------------------------------------------------------------
        ---- Get the delivery frequency code. If the code says 'AFTERCHARGE', set the next_delivery_Date to now.
        SELECT x_delivery_frq_code,
          x_is_recurring,
          x_benefit_days,
          X_DELAY_ENROLL_ACH_FLAG,
          ---CR47971 GO SMART ACH RECON
          x_prog_class
          ---CR47971 GO SMART ACH RECON
        INTO l_delivery_frq_code,
          l_is_recurring,
          l_benefit_days,
          l_delay_enroll_flag,
          ---CR47971 GO SMART ACH RECON
          l_program_class
          ---CR47971 GO SMART ACH RECON
        FROM x_program_parameters
        WHERE objid =
          (SELECT pgm_enroll2pgm_parameter
          FROM x_program_enrolled
          WHERE objid = program_purch_loop.pgm_purch_dtl2pgm_enrolled
          );
        ---------- If the enrollment status is ENROLLMENTPENDING then compute and put the next delivery date.
        -- Ramu Changes 04/18/2007
        -- Update the Next Delivery Date of X_PROGRAM_ENROLLED table
        -- only if the Delay Enroll Flag is "Yes" and a recurring program
        -- This change should be applicable to Enrollment, Recurring and PayNOW
        -- transactions.....
        -- Pending : Needs to add if possible to check the benefits already delivered or not
        -- This needs to be added after discussing with Sankar
        IF (l_delay_enroll_flag = 1 AND l_is_recurring = 1) THEN
          computeDeliveryPendEnrollment ( program_purch_loop.pgm_purch_dtl2pgm_enrolled, l_delivery_frq_code, l_is_recurring, l_benefit_days );
        END IF;
        ---------- Compute the next charge date.
        ---------- If this is group primary, compute the next cycle date.
        ---------- If this is additional phone, get the next cycle for the primary phone.
        SELECT
          CASE
            WHEN x_is_grp_primary = 1
            THEN get_next_cycle_date ( pgm_enroll2pgm_parameter, NVL (x_next_charge_date,SYSDATE - l_days_cutoff) -- CR6704 change .. Ramu
              )
            ELSE get_primary_cycle_date (pgm_enroll2pgm_group)
          END,
          x_enrollment_status
        INTO l_next_charge_date,
          l_enrollment_status
        FROM x_program_enrolled
        WHERE objid = program_purch_loop.pgm_purch_dtl2pgm_enrolled;
        --------------------------------------------------------------
        -- Update the enrollment status to Enrolled.
        IF (ach_payment_rec.x_status = 'RECURACHPENDING') THEN
          --- If the enrollment is transitioning from 'ENROLLMENTPENDING' to 'ENROLLED'
          --- send a notification
          UPDATE x_program_enrolled
          SET x_enrollment_status = 'ENROLLED',
            x_charge_date         = NVL (x_next_charge_date, SYSDATE),
            x_next_charge_date    = l_next_charge_date,
            -- x_next_delivery_date  = DECODE (l_delivery_frq_code, 'AFTERCHARGE', SYSDATE, x_next_delivery_date ), -- CR6704 Changes
			x_next_delivery_date  = CASE WHEN NVL(l_program_class,'X') = 'SWITCHBASE'   -- Added as part of CR45710
                                         THEN NULL
                                         ELSE DECODE (l_delivery_frq_code, 'AFTERCHARGE', SYSDATE, x_next_delivery_date )
                                    END,
            x_update_stamp        = v_date,
            X_ENROLLED_DATE       =
            CASE
              WHEN x_enrollment_status = 'ENROLLMENTPENDING'
              THEN SYSDATE
              ELSE X_ENROLLED_DATE
            END
          WHERE objid                 IN (program_purch_loop.pgm_purch_dtl2pgm_enrolled)
          AND x_enrollment_status NOT IN ('DEENROLLED', 'READYTOREENROLL') -- Sometimes customer may voluntarily de-enroll while we wait for payment
            -- READYTOREENROLL is added in above statement .. CR6704 ... Ramu
            RETURNING objid,
            pgm_enroll2pgm_parameter,
            x_esn,
            x_sourcesystem,
            x_language,
            pgm_enroll2contact,
            pgm_enroll2web_user,
            x_is_grp_primary,
            x_pec_customer
          INTO l_enroll_objid,
            l_program_objid,
            l_esn,
            l_source_system,
            l_language,
            l_contact,
            l_webuser,
            l_primary,
            l_is_pec_customer;
          DBMS_OUTPUT.put_line ( 'Enrollment Pending or Enrollment Scheduled');

--Commented as per CR47120  --{
/*
          IF ( l_enrollment_status = 'ENROLLMENTPENDING' OR l_enrollment_status = 'ENROLLMENTSCHEDULED') AND (billing_job_pkg.is_SB_esn ( program_purch_loop.pgm_purch_dtl2pgm_enrolled, NULL) <> 1) --CR8663
            THEN
            ---- Insert into x_program_notify
            --Changed x_notify_status from NULL as PENDING
            INSERT
            INTO x_program_notify
              (
                objid,
                x_esn,
                x_program_name,
                x_program_status,
                x_notify_process,
                x_notify_status,
                x_source_system,
                x_process_date,
                x_phone,
                x_language,
                x_remarks,
                pgm_notify2pgm_objid,
                pgm_notify2contact_objid,
                pgm_notify2web_user,
                pgm_notify2pgm_enroll,
                pgm_notify2purch_hdr,
                x_message_name
              )
              VALUES
              (
                billing_seq ('X_PROGRAM_NOTIFY'),
                l_esn,
                (SELECT x_program_name
                FROM x_program_parameters
                WHERE objid = l_program_objid
                ),
                'ENROLLED',
                'ACH_RECON',
                'PENDING',
                l_source_system,
                v_date,
                NULL,
                l_language,
                'ENROLLED SUCESSFULLY',
                l_program_objid,
                l_contact,
                l_webuser,
                l_enroll_objid,
                ach_payment_rec.objid,
                'Enrolled due payment success'
              );
          END IF;
*/           --CR47120 --}
          -- Notify Payment Assumption success for primary esn only
--Commented as per CR47120  --{
/*
         IF (l_primary = 1) THEN
            ---- Insert into x_program_notify
            --Changed x_notify_Status from NULL as PENDING

            INSERT
            INTO x_program_notify
              (
                objid,
                x_esn,
                x_program_name,
                x_program_status,
                x_notify_process,
                x_notify_status,
                x_source_system,
                x_process_date,
                x_phone,
                x_language,
                x_remarks,
                pgm_notify2pgm_objid,
                pgm_notify2contact_objid,
                pgm_notify2web_user,
                pgm_notify2pgm_enroll,
                pgm_notify2purch_hdr,
                x_message_name
              )
              VALUES
              (
                billing_seq ('X_PROGRAM_NOTIFY'),
                l_esn,
                (SELECT x_program_name
                FROM x_program_parameters
                WHERE objid = l_program_objid
                ),
                'ENROLLED',
                'ACH_RECON',
                'PENDING',
                l_source_system,
                v_date,
                NULL,
                l_language,
                'Payment assumed successful',
                l_program_objid,
                l_contact,
                l_webuser,
                l_enroll_objid,
                ach_payment_rec.objid,
                'Payment Receipt'
              );
          END IF;
*/ --CR47120    --}
        ELSE
          -- Flow for PAYNOWACHPENDING, ENROLLACHPENDING
          UPDATE x_program_enrolled
          SET x_enrollment_status = 'ENROLLED',
            x_charge_date         = SYSDATE, ---NVL(x_next_charge_date,sysdate), Always put the x_charge_date as sysdate
            --CR47971 GO SMART ACH RECON
            /*x_next_charge_date    = l_next_charge_date,
            x_next_delivery_date  = DECODE (l_delivery_frq_code, 'AFTERCHARGE', SYSDATE, x_next_delivery_date ),*/
            -- IF X_PROGRAM_CLASS IS SWITHBASE THEN DO NOT UPDATE X_NEXT_CHARGE_DATE
            x_next_charge_date    = CASE WHEN NVL(l_program_class,'X') = 'SWITCHBASE'
                                         THEN x_next_charge_date
                                         ELSE l_next_charge_date
                                    END,
            -- IF X_PROGRAM_CLASS IS SWITHBASE THEN SET X_NEXT_DELIEVERY DATE AS NULL
            x_next_delivery_date  = CASE WHEN NVL(l_program_class,'X') = 'SWITCHBASE'
                                         THEN NULL
                                         ELSE DECODE (l_delivery_frq_code, 'AFTERCHARGE', SYSDATE, x_next_delivery_date )
                                    END,
            x_update_stamp        = v_date,
            X_ENROLLED_DATE       =
            CASE
              WHEN x_enrollment_status = 'ENROLLMENTPENDING'
              THEN SYSDATE
              ELSE X_ENROLLED_DATE
            END
          WHERE objid IN (program_purch_loop.pgm_purch_dtl2pgm_enrolled) --No need to check additional conditions here since during ENROLLACHPENDING we dont allow a de-enrollment
            RETURNING objid,
            pgm_enroll2pgm_parameter,
            x_esn,
            x_sourcesystem,
            x_language,
            pgm_enroll2contact,
            pgm_enroll2web_user,
            x_is_grp_primary,
            x_pec_customer
          INTO l_enroll_objid,
            l_program_objid,
            l_esn,
            l_source_system,
            l_language,
            l_contact,
            l_webuser,
            l_primary,
            l_is_pec_customer;
          --- Deliver these benefits only if the previous attempt is not RECURRING.--------
          --- i.e. the benefits are delivered
           --------
           ---CR47971 GO SMART ACH RECON
          IF (haveBenefitsAlreadyDelivered (l_enroll_objid) = 0) AND NVL(l_program_class,'X') != 'SWITCHBASE' THEN
            ---------------------------------------------------------------------------------
            -- Delivery the service days associated with the program.
            billing_deliverservicedays (l_enroll_objid, l_error, l_error_message);
          END IF;
          IF (l_error != 0) THEN
            DBMS_OUTPUT.put_line ( 'Error is delivering service days for  ' || l_esn || ' Enrolled : ' || TO_CHAR (l_enroll_objid));
          END IF;
          -------------------------------- Service Days Delivery End -------------------------------------------------
          -------------------------------- Notification --------------------------------------
--Commented as per CR47120  --{
/*
          IF (l_enrollment_status IN ('ENROLLMENTPENDING', 'ENROLLMENTSCHEDULED')) AND (billing_job_pkg.is_SB_esn ( program_purch_loop.pgm_purch_dtl2pgm_enrolled, NULL) <> 1) --CR8663
            THEN
            ---- Insert into x_program_notify
            --Changed x_notify_Status from NULL as PENDING
            INSERT
            INTO x_program_notify
              (
                objid,
                x_esn,
                x_program_name,
                x_program_status,
                x_notify_process,
                x_notify_status,
                x_source_system,
                x_process_date,
                x_phone,
                x_language,
                x_remarks,
                pgm_notify2pgm_objid,
                pgm_notify2contact_objid,
                pgm_notify2web_user,
                pgm_notify2pgm_enroll,
                pgm_notify2purch_hdr,
                x_message_name
              )
              VALUES
              (
                billing_seq ('X_PROGRAM_NOTIFY'),
                l_esn,
                (SELECT x_program_name
                FROM x_program_parameters
                WHERE objid = l_program_objid
                ),
                'ENROLLED',
                'ACH_RECON',
                'PENDING',
                l_source_system,
                v_date,
                NULL,
                l_language,
                'ENROLLED SUCESSFULLY',
                l_program_objid,
                l_contact,
                l_webuser,
                l_enroll_objid,
                ach_payment_rec.objid,
                'Enrollment Success'
              );
          END IF;
*/ -- CR47120 }
          ------------------------------------------------------------------------------------
          ---------------------------------------------------------------------------------
--Commented as per CR47120  --{
/*
          -- insert a record into the notification header
          IF (l_primary = 1) THEN
            -- Changed x_notify_status from NULL as PENDING
            INSERT
            INTO x_program_notify
              (
                objid,
                x_esn,
                x_program_name,
                x_program_status,
                x_notify_process,
                x_notify_status,
                x_source_system,
                x_process_date,
                x_phone,
                x_language,
                x_remarks,
                pgm_notify2pgm_objid,
                pgm_notify2contact_objid,
                pgm_notify2web_user,
                pgm_notify2pgm_enroll,
                pgm_notify2purch_hdr
              )
              VALUES
              (
                billing_seq ('X_PROGRAM_NOTIFY'),
                l_esn,
                (SELECT x_program_name
                FROM x_program_parameters
                WHERE objid = l_program_objid
                ),
                'ENROLLED',
                'PAYMENT_HDR_SUCCESS',
                'PENDING',
                l_source_system,
                v_date,
                NULL,
                l_language,
                'ENROLLED SUCESSFULLY',
                l_program_objid,
                l_contact,
                l_webuser,
                l_enroll_objid,
                ach_payment_rec.objid
              );
            --- Payment success notification
            -- Changed x_notify_status from NULL as PENDING
            INSERT
            INTO x_program_notify
              (
                objid,
                x_esn,
                x_program_name,
                x_program_status,
                x_notify_process,
                x_notify_status,
                x_source_system,
                x_process_date,
                x_phone,
                x_language,
                x_remarks,
                pgm_notify2pgm_objid,
                pgm_notify2contact_objid,
                pgm_notify2web_user,
                pgm_notify2pgm_enroll,
                pgm_notify2purch_hdr,
                x_message_name
              )
              VALUES
              (
                billing_seq ('X_PROGRAM_NOTIFY'),
                l_esn,
                (SELECT x_program_name
                FROM x_program_parameters
                WHERE objid = l_program_objid
                ),
                'ENROLLED',
                'ACH_RECON',
                'PENDING',
                l_source_system,
                v_date,
                NULL,
                l_language,
                'Payment assumed successful',
                l_program_objid,
                l_contact,
                l_webuser,
                l_enroll_objid,
                ach_payment_rec.objid,
                'Payment Receipt'
              );
            -----
          END IF;
*/ --  CR47120 }
          -------------------- PEC PARALLEL OPERATION -------------------------------------
          -- Check if the ESN is enrolled into existing autopay.
          SELECT COUNT (*)
          INTO l_is_pec_customer
          FROM table_x_autopay_details
          WHERE x_esn           = l_esn
          AND x_status          = 'A'
          AND ( x_end_date     IS NULL
          OR x_end_date         = TO_DATE ('01/01/1753', 'mm/dd/yyyy'));
          IF (l_is_pec_customer > 0) THEN
            -- Drop the de-enrollment record.
            BILLING_PEC_PARALLEL_PKG.DE_ENROLL_OLD_PROG ( l_esn, l_error, l_error_message);
            IF (l_error != 0) THEN
              DBMS_OUTPUT.put_line ( 'Could not de-register ' || l_esn || ' from PEC');
            END IF;
          END IF;
          -------------------- PEC PARALLEL OPERATION -------------------------------------
        END IF; -- RecurACHPending
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- Cover for data inconsistency
        NULL;
      END;
    END LOOP;
    -- Update the payment header record to success
    UPDATE x_program_purch_hdr
    SET x_status    = 'PROCESSED',
      x_bill_amount = ROUND(x_amount + x_tax_amount + x_e911_tax_amount + x_usf_taxamount + x_rcrf_tax_amount,2),
      x_rqst_date   = SYSDATE --CR11553
      --- all the other fields will not be changed, since we dont expect response from the gateway
    WHERE objid = ach_payment_rec.objid;
    ---------------------------------------------------------------------------------
    ------------------- Log the payment details
    l_error_message := payment_log (ach_payment_rec.objid);
  END LOOP;
  CLOSE ach_payment_c;
  --      COMMIT;
EXCEPTION
WHEN OTHERS THEN
  op_code   := -900;
  op_result := SQLCODE || SUBSTR (SQLERRM, 1, 255);
  DBMS_OUTPUT.put_line (op_result);
END;
FUNCTION payment_log(
    p_purch_hdr_objid IN x_program_purch_hdr.objid%TYPE,
    p_submission_flag IN NUMBER DEFAULT 0)
  RETURN VARCHAR2 --- Returns the log details
IS
  l_details        VARCHAR2 (4000); -- variable that hold the payment information for a given purchase header.
  l_payment_source VARCHAR2 (255);
  l_first_name x_program_purch_hdr.X_CUSTOMER_FIRSTNAME%TYPE;
  l_last_name x_program_purch_hdr.X_CUSTOMER_LASTNAME%TYPE;
  l_rqst_source x_program_purch_hdr.X_RQST_SOURCE%TYPE;
  l_web_user x_program_purch_hdr.PROG_HDR2WEB_USER%TYPE;
  l_merchant_ref_number x_program_purch_hdr.X_MERCHANT_REF_NUMBER%TYPE;
  l_status VARCHAR2 (40);
  CURSOR program_details_cur ( c_purch_objid NUMBER)
  IS
    SELECT a.x_program_name
      || '     '
      || TO_CHAR ( b.x_amount + b.x_tax_amount + b.x_e911_tax_amount + b.x_rcrf_tax_amount + b.x_usf_taxamount, '$999990.90')
      || '    '
      || b.x_esn
      || DECODE (c.x_is_grp_primary -- add tax usf and rcrf for CR11553
      , 1, '(Primary)', '(Additional)') details,
      b.x_esn,
      a.x_program_name,
      billing_getnickname (b.x_esn) nickname
    FROM x_program_purch_dtl b,
      x_program_enrolled c,
      x_program_parameters a
    WHERE a.objid                = c.pgm_enroll2pgm_parameter
    AND c.objid                  = b.PGM_PURCH_DTL2PGM_ENROLLED
    AND b.PGM_PURCH_DTL2PROG_HDR = c_purch_objid
    ORDER BY c.x_is_grp_primary;
  program_details_rec program_details_cur%ROWTYPE;
BEGIN
  ----- 1. Get the payment details used for the order.
  SELECT DECODE (b.X_PYMT_TYPE, 'CREDITCARD', c.x_cc_type
    || '    '
    || LPAD ( SUBSTR (X_CUSTOMER_CC_NUMBER, LENGTH (X_CUSTOMER_CC_NUMBER)- 3 ), LENGTH (X_CUSTOMER_CC_NUMBER), '*'), 'ACH', d.x_aba_transit
    || '       '
    || LPAD ( SUBSTR (X_CUSTOMER_ACCT, LENGTH (X_CUSTOMER_ACCT) - 3), LENGTH (X_CUSTOMER_ACCT), '*'))
    || '       '
    || TO_CHAR ( DECODE ( a.x_bill_amount, 0, a.x_amount + a.x_tax_amount + a.x_e911_tax_amount + a.x_usf_taxamount + a.x_rcrf_tax_amount, a.x_bill_amount), --tax add usf and rcrf for CR11553
    '999990.90'),
    a.X_CUSTOMER_FIRSTNAME,
    a.X_CUSTOMER_LASTNAME,
    a.X_RQST_SOURCE,
    CASE
      WHEN p_submission_flag = 1
      THEN 'Pending Response'
      WHEN a.x_status LIKE '%ACHPENDING'
      THEN 'Verification Success - Pending Confirmation'
      ELSE DECODE (a.x_ics_rcode, 1, 'Success', 100, 'Success', 'Failed')
    END status,
    PROG_HDR2WEB_USER
  INTO l_payment_source,
    l_first_name,
    l_last_name,
    l_rqst_source,
    l_status,
    l_web_user
  FROM x_program_purch_hdr a,
    x_payment_source b,
    table_x_credit_card c,
    table_x_bank_account d
  WHERE a.PROG_HDR2X_PYMT_SRC   = b.objid
  AND b.PYMT_SRC2X_CREDIT_CARD  = c.objid(+)
  AND b.PYMT_SRC2X_BANK_ACCOUNT = d.objid(+)
  AND a.objid                   = p_purch_hdr_objid;
  OPEN program_details_cur (p_purch_hdr_objid);
  LOOP
    FETCH program_details_cur INTO program_details_rec;
    EXIT
  WHEN program_details_cur%NOTFOUND;
    IF (LENGTH (l_details) > 0) THEN
      l_details           := l_details || ', \n';
    END IF;
    l_details := l_details || program_details_rec.details;
  END LOOP;
  CLOSE program_details_cur;
  ---- Log the details into the BILLING_LOG table
  INSERT
  INTO x_billing_log
    (
      objid,
      x_log_category,
      x_log_title,
      x_log_date,
      x_details,
      x_additional_details,
      x_program_name,
      x_nickname,
      x_esn,
      x_originator,
      x_contact_first_name,
      x_contact_last_name,
      x_agent_name,
      x_sourcesystem,
      BILLING_LOG2WEB_USER
    )
    VALUES
    (
      billing_seq ('X_BILLING_LOG'),
      'Payment',
      CASE
        WHEN p_submission_flag = 1
        THEN 'Payment Submitted'
        ELSE 'Payment'
      END,
      SYSDATE,
      l_payment_source
      || ' - '
      || l_status,
      l_details,
      program_details_rec.x_program_name,
      program_details_rec.nickname,
      program_details_rec.x_esn, -- For multiple payments this record will be a random one.
      'System',
      l_first_name,
      l_last_name,
      'System',
      l_rqst_source,
      l_web_user
    );
  --        dbms_output.put_line(l_payment_source);
  RETURN l_details;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END;
/*
Procedure that computes the next delivery date in case of ACHPending records
*/
PROCEDURE computeDeliveryPendEnrollment
  (
    p_enrollObjid       NUMBER,
    p_delivery_frq_code VARCHAR2,
    p_is_recurring      NUMBER,
    p_benefit_days      NUMBER
  )
IS
BEGIN
  UPDATE x_program_enrolled
  SET x_next_delivery_date = DECODE ( UPPER (p_delivery_frq_code), 'MONTHLY', ADD_MONTHS (TRUNC (SYSDATE), 1), 'MON', NEXT_DAY (TRUNC (SYSDATE), 'MON'), 'TUE', NEXT_DAY (TRUNC (SYSDATE), 'TUE'), 'WED', NEXT_DAY (TRUNC (SYSDATE), 'WED'), 'THU', NEXT_DAY (TRUNC (SYSDATE), 'THU'), 'FRI', NEXT_DAY (TRUNC (SYSDATE), 'FRI'), 'SAT', NEXT_DAY (TRUNC (SYSDATE), 'SAT'), 'SUN', NEXT_DAY (TRUNC (SYSDATE), 'SUN'), 'AFTERCHARGE', SYSDATE, --Immediately after charged. Always set the next delivery date as null.
    x_next_delivery_date + TO_NUMBER (p_delivery_frq_code)                                                                                                                                                                                                                                                                                                                                                                                   -- Every x days
    ),
    x_exp_date             = DECODE (p_is_recurring, 1, x_exp_date, TRUNC (SYSDATE + p_benefit_days))
  WHERE objid              = p_enrollObjid
  AND x_enrollment_status IN ('ENROLLMENTPENDING', 'ENROLLMENTSCHEDULED');
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  NULL;
END;
/* ----------------------------------------------------------------------------------------------------------
Function that returns if benefits have been delivered earlier as part of ACH Verification and Validation
success.
---------------------------------------------------------------------------------------------------------- */
FUNCTION haveBenefitsAlreadyDelivered(
    p_enroll_objid IN x_program_enrolled.objid%TYPE)
  RETURN NUMBER -- Return the benefits status
IS
  l_count NUMBER;
  -- Counter to hold the benefits delivered flag.
BEGIN
  /*
  LOGIC: Get all the past payments attempted in this cycle. If any of the payment record
  is of type RECURRING and the x_ics_rcode is the ACH Reject code, then don't deliver
  service days.
  */
  /* Get all the recurring payment attempts made during the current cycle
  that have ACH reject code
  */
  SELECT COUNT (*)
  INTO l_count
  FROM x_program_purch_hdr a,
    x_program_purch_dtl b,
    x_program_enrolled c
  WHERE a.objid                    = b.PGM_PURCH_DTL2PROG_HDR
  AND b.PGM_PURCH_DTL2PGM_ENROLLED = c.objid
  AND c.objid                      = p_enroll_objid
  AND a.x_rqst_date                > c.x_charge_date
  AND a.x_payment_type             = 'RECURRING'
  AND EXISTS
    (SELECT 1
    FROM x_billing_code_table
    WHERE x_code_type = 'CB_ECP_RCODES'
    AND x_code        = a.x_ics_rcode
    );
  RETURN l_count; -- Flag indicating if the benefits have been delivered or not.
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END;
END billing_payment_recon_pkg;
/