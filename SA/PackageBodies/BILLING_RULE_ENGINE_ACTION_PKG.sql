CREATE OR REPLACE PACKAGE BODY sa."BILLING_RULE_ENGINE_ACTION_PKG"
/********************************************************************************/
/*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved
/*
/********************************************************************************/
/********************************************************************************/
/*
   /* NAME:         billing_rule_engine_action_pkg (BODY)
   /* PURPOSE:      This package executes actions when rules conditions are met
   /*          on the Billing Platform
   /* FREQUENCY:
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.
   /*
   /* REVISIONS:
   /* VERSION  DATE        WHO     PURPOSE
   /* -------  ---------- ----- ---------------------------------------------
   /*  1.0                   Initial  Revision
   /*  1.1          05/23/08 rvurimi  Fixes for CR7136
   /*  1.2/1.3/1.4  05/27/09 VAdapa   Cr8663 - Walmart Monthly Plans
   /*  1.5          08/27/09 NGuada   BRAND_SEP Separate the Brand and Source System
/********************************************************************************/
/******************************** NEW CVS FILE STRUCTURE ************************/
/*  1.2-3           06/30/10 ICanavan CR13649  DEENROLL RULES                   */
/*  1.4             09/14/10 Skuthadi CR13094  NET10 MegaCard                   */
/*                                    de_enroll_rule_action is modified         */
/*   1.5            04/11/11 YMILLAN  CR11553  Tax collection Mod Project
/********************************************************************************/
/*
/* Name:     block_funds_action
/* Description : Available in the specification part of package
/********************************************************************************/
  --
  --********************************************************************************
  --$RCSfile: BILLING_RULE_ENGINE_ACTION_PKG.sql,v $
  --$Revision: 1.14 $
  --$Author: jarza $
  --$Date: 2015/12/09 18:33:55 $
  --$ $Log: BILLING_RULE_ENGINE_ACTION_PKG.sql,v $
  --$ Revision 1.14  2015/12/09 18:33:55  jarza
  --$ Updating columns being updated.
  --$
  --$ Revision 1.12  2015/08/07 17:51:31  jarza
  --$ CR34962
  --$
  --$ Revision 1.11  2015/08/03 11:26:40  jarza
  --$ CR34962
  --$
  --$ Revision 1.10  2015/07/20 14:56:41  jarza
  --$ CR34962 - De-enroll bundle promo
  --$
  --$ Revision 1.9  2015/05/12 20:31:02  ddevaraj
  --$ FOR CR33039
  --$
  --$ Revision 1.7  2012/04/03 13:54:54  kacosta
  --$ CR14818 WEBCSR - Agents unable to de-enroll Family Value Plan
  --$
  --$
  --********************************************************************************
  --
IS
   PROCEDURE block_funds_action (
      p_esn        IN       x_metrics_block_status.x_esn%TYPE,
      p_reason     IN       x_metrics_block_status.x_reason%TYPE,
      p_rule_cat   IN       x_metrics_block_status.x_rule_category%TYPE,
      op_result    OUT      NUMBER,
      op_msg       OUT      VARCHAR2
   )
   IS
      l_part_inst_objid   NUMBER;
      l_contact_objid     NUMBER;
      sys_user            VARCHAR2 (30);
      op_result1          NUMBER;
   BEGIN
      IF p_esn IS NULL
      THEN
         raise_application_error (-20001, 'ESN is Required.');
      ELSIF p_reason IS NULL
      THEN
         raise_application_error (-20001, 'Reason is Required.');
      END IF;

      BEGIN
         SELECT objid
           INTO l_part_inst_objid
           FROM table_part_inst
          WHERE part_serial_no = p_esn AND x_part_inst_status = 'Active';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            op_result := SQLCODE;
            op_msg := 'No data Found';
      END;

      BEGIN
         SELECT x_contact_part_inst2contact
           INTO l_contact_objid
           FROM table_x_contact_part_inst
          WHERE x_contact_part_inst2part_inst = l_part_inst_objid;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            op_result := SQLCODE;
            op_msg := 'No data Found';
      END;

      INSERT INTO x_metrics_blk_data_serv
           VALUES (billing_seq ('X_METRICS_BLOCK_STATUS'), p_esn, p_reason,
                   l_contact_objid, p_rule_cat);

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
         op_result1 := SQLCODE;

         IF (op_result1 = -1400)
         THEN
            op_result := -1400;
            op_msg :=
                  'Entered is NULL, You cannot modify'
               || TO_NUMBER (NULL)
               || ' records';
         END IF;
   END block_funds_action;

   PROCEDURE de_act_esn_rule_action (
      p_esn            IN       x_program_deact_pend.x_esn%TYPE,
      p_enroll_objid   IN       x_program_deact_pend.deact_pend2prog_enroll%TYPE,
      p_reason         IN       x_program_deact_pend.x_deact_reason%TYPE,
      p_rule_cat       IN       x_program_deact_pend.x_rule_cat%TYPE,
      op_result        OUT      NUMBER,
      op_msg           OUT      VARCHAR2
   )
   IS
      v_date             DATE   DEFAULT SYSDATE;
      v_web_user_objid   NUMBER;
   BEGIN
      FOR i IN 1 .. 1
      LOOP
         IF p_enroll_objid IS NULL
         THEN
            op_result := -2;
            op_msg := 'Enrollment objid is null';
            EXIT;
         ELSE
            IF p_enroll_objid = 0
            THEN
               op_result := -1;
               op_msg := 'Enrollment objid is zero';
            END IF;
         END IF;

         EXIT;
      END LOOP;

      BEGIN
         SELECT pgm_enroll2web_user
           INTO v_web_user_objid
           FROM x_program_enrolled
          WHERE objid = p_enroll_objid;

         IF v_web_user_objid IS NULL
         THEN
            op_result := -1400;
            op_msg := 'null return the enrolled table';
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            IF (op_result = -1400)
            THEN
               op_msg := 'null return the enrolled table';
            END IF;

            op_result := 1;
            op_msg := 'No program enrolled record exits';
      END;

      INSERT INTO x_program_deact_pend
                  (objid, x_esn, x_deact_date,
                   x_deact_reason, x_deact_status, x_rule_cat,
                   deact_pend2prog_enroll, deact_pend2web_user
                  )
           VALUES (billing_seq ('X_PROGRAM_DEACT_PEND'), p_esn, v_date,
                   p_reason, 'PENDING', p_rule_cat,
                   p_enroll_objid, v_web_user_objid
                  );
   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
   END de_act_esn_rule_action;

   PROCEDURE retry_redebit_rule_action (
      p_purch_objid    IN       x_program_purch_hdr.objid%TYPE,
      p_redebit_days   IN       NUMBER,
      p_reason         IN       x_metrics_redebits.x_reason%TYPE,
      p_rule_cat       IN       x_metrics_redebits.x_rule_category%TYPE,
      op_result        OUT      NUMBER,
      op_msg           OUT      VARCHAR2
   )
   IS
      v_date          DATE                          DEFAULT SYSDATE;
      l_purc_record   x_program_purch_hdr%ROWTYPE;
      v_purch_objid   NUMBER;
   BEGIN
      v_date := v_date + p_redebit_days;

      FOR i IN 1 .. 1
      LOOP
         IF p_purch_objid IS NULL OR p_redebit_days IS NULL
         THEN
            op_result := -2;
            op_msg := 'purchase objid or redebits is null';
            RETURN;
         ELSE
            IF p_purch_objid = 0 OR p_redebit_days = 0
            THEN
               op_result := -1;
               op_msg := 'purchase objid or redebits is zero';
               RETURN;
            END IF;
         END IF;
      END LOOP;

      v_purch_objid := billing_seq ('X_PROGRAM_PURCH_HDR');

      BEGIN
         SELECT *
           INTO l_purc_record
           FROM x_program_purch_hdr
          WHERE objid = p_purch_objid;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            op_result := SQLCODE;
            op_msg := 'No data Found';
            RETURN;
      END;

      -- If this was a Credit Card transaction
      IF l_purc_record.x_rqst_type = 'CREDITCARD_PURCH'
      THEN
         INSERT INTO x_cc_prog_trans
                     (objid, x_ignore_bad_cv, x_ignore_avs, x_avs,
                      x_disable_avs, x_auth_avs, x_auth_cv_result,
                      x_score_factors, x_score_host_severity, x_score_rcode,
                      x_score_rflag, x_score_rmsg, x_score_result,
                      x_score_time_local, x_customer_cc_number,
                      x_customer_cc_expmo, x_customer_cc_expyr,
                      x_customer_cvv_num, x_cc_lastfour,
                      x_cc_trans2x_credit_card, x_cc_trans2x_purch_hdr
                                                                      --,x_cc_trans2pgm_entrolled
                     )
            SELECT billing_seq ('X_CC_PROG_TRANS'),                  --objid,
                                                   x_ignore_bad_cv,
                   x_ignore_avs, x_avs, x_disable_avs, x_auth_avs,
                   x_auth_cv_result, x_score_factors, x_score_host_severity,
                   x_score_rcode, x_score_rflag, x_score_rmsg,
                   x_score_result, x_score_time_local, x_customer_cc_number,
                   x_customer_cc_expmo, x_customer_cc_expyr,
                   x_customer_cvv_num, x_cc_lastfour,
                   x_cc_trans2x_credit_card, v_purch_objid
              FROM x_cc_prog_trans
             WHERE x_cc_trans2x_purch_hdr = l_purc_record.objid;
      ELSE
         INSERT INTO x_ach_prog_trans
                     (objid, x_bank_num, x_ecp_account_no,
                      x_ecp_account_type, x_ecp_rdfi,
                      x_ecp_settlement_method, x_ecp_payment_mode,
                      x_ecp_debit_request_id, x_ecp_verfication_level,
                      x_ecp_ref_number, x_ecp_debit_ref_number,
                      x_ecp_debit_avs, x_ecp_debit_avs_raw, x_ecp_rcode,
                      x_ecp_trans_id, x_ecp_ref_no, x_ecp_result_code,
                      x_ecp_rflag, x_ecp_rmsg, x_ecp_credit_ref_number,
                      x_ecp_credit_trans_id, x_decline_avs_flags,
                      ach_trans2x_purch_hdr, ach_trans2x_bank_account)
            SELECT billing_seq ('X_ACH_PROG_TRANS'),                 --objid,
                                                    x_bank_num,
                   x_ecp_account_no, x_ecp_account_type, x_ecp_rdfi,
                   x_ecp_settlement_method, x_ecp_payment_mode,
                   x_ecp_debit_request_id, x_ecp_verfication_level,
                   x_ecp_ref_number, x_ecp_debit_ref_number, x_ecp_debit_avs,
                   x_ecp_debit_avs_raw, x_ecp_rcode, x_ecp_trans_id,
                   x_ecp_ref_no, x_ecp_result_code, x_ecp_rflag, x_ecp_rmsg,
                   x_ecp_credit_ref_number, x_ecp_credit_trans_id,
                   x_decline_avs_flags, v_purch_objid,
                   ach_trans2x_bank_account
              FROM x_ach_prog_trans
             WHERE ach_trans2x_purch_hdr = l_purc_record.objid;
      END IF;

      INSERT INTO x_program_purch_dtl
                  (objid, x_esn, x_amount, x_tax_amount, x_e911_tax_amount,
                   x_usf_taxamount, x_rcrf_tax_amount, --CR11553
                   x_charge_desc, x_cycle_start_date, x_cycle_end_date,

                   --x_merchant_ref_number,   -- No need of this
                   pgm_purch_dtl2pgm_enrolled, pgm_purch_dtl2prog_hdr)
         SELECT billing_seq ('X_PROGRAM_PURCH_DTL'), x_esn, x_amount,
                x_tax_amount, x_e911_tax_amount,
                x_usf_taxamount, x_rcrf_tax_amount, --CR11553
                'Retry/Redebit - ' || x_charge_desc, x_cycle_start_date,
                x_cycle_end_date, pgm_purch_dtl2pgm_enrolled, v_purch_objid
           FROM x_program_purch_dtl
          WHERE pgm_purch_dtl2prog_hdr = l_purc_record.objid;

      INSERT INTO x_metrics_redebits
                  (objid, x_esn, x_reason, x_redebit_date, x_rule_category,
                   redebit2purch_hdr, redebit2web_user   --,redebit2prog_enrol
                                                      )
         SELECT billing_seq ('X_METRICS_REDEBITS'), x_esn, p_reason, v_date,
                p_rule_cat, l_purc_record.objid,
                l_purc_record.prog_hdr2web_user
                                    --,--l_purc_record.purch_hdr2prog_enrolled
           FROM x_program_purch_dtl
          WHERE pgm_purch_dtl2prog_hdr = l_purc_record.objid;

      INSERT INTO x_program_purch_hdr
                  (objid, x_rqst_source,
                   x_rqst_type, x_rqst_date,
                   x_ics_applications,
                   x_merchant_id, x_merchant_ref_number,
                   x_offer_num, x_quantity,
                   x_merchant_product_sku,
                   x_payment_line2program,
                   x_product_code, x_ignore_avs,
                   x_user_po, x_avs,
                   x_disable_avs,
                   x_customer_hostname,
                   x_customer_ipaddress,
                   x_auth_request_id,
                   x_auth_code, x_auth_type,
                   x_ics_rcode, x_ics_rflag, x_ics_rmsg, x_request_id,
                   x_auth_avs, x_auth_response, x_auth_time, x_auth_rcode,
                   x_auth_rflag, x_auth_rmsg,
                   x_bill_request_time,
                   x_bill_rcode, x_bill_rflag, x_bill_rmsg,
                   x_bill_trans_ref_no, x_customer_firstname,
                   x_customer_lastname,
                   x_customer_phone,
                   x_customer_email, x_status,
                   x_bill_address1,
                   x_bill_address2, x_bill_city,
                   x_bill_state, x_bill_zip,
                   x_bill_country, x_esn,
                   x_amount, x_tax_amount,
                   x_e911_tax_amount,
                   x_usf_taxamount, --CR11553
                   x_rcrf_tax_amount, --CR11553
                   x_auth_amount, x_bill_amount,
                   x_user, x_credit_code,
                   purch_hdr2creditcard,
                   purch_hdr2bank_acct,
                   purch_hdr2user, purch_hdr2esn,
                   purch_hdr2rmsg_codes,
                   purch_hdr2cr_purch,
                   prog_hdr2x_pymt_src,
                   prog_hdr2web_user, prog_hdr2prog_batch, x_payment_type
                  --                   purch_hdr2prog_enrolled
                  )
           VALUES (v_purch_objid, l_purc_record.x_rqst_source,
                   l_purc_record.x_rqst_type, v_date,
                   l_purc_record.x_ics_applications,
                   l_purc_record.x_merchant_id, merchant_ref_number,
                   l_purc_record.x_offer_num, l_purc_record.x_quantity,
                   l_purc_record.x_merchant_product_sku,
                   l_purc_record.x_payment_line2program,
                   l_purc_record.x_product_code, l_purc_record.x_ignore_avs,
                   l_purc_record.x_user_po, l_purc_record.x_avs,
                   l_purc_record.x_disable_avs,
                   l_purc_record.x_customer_hostname,
                   l_purc_record.x_customer_ipaddress,
                   l_purc_record.x_auth_request_id,
                   l_purc_record.x_auth_code, l_purc_record.x_auth_type,
                   NULL,                          --l_purc_record.x_ics_rcode,
                        NULL,                     --l_purc_record.x_ics_rflag,
                             NULL,                 --l_purc_record.x_ics_rmsg,
                                  NULL,          --l_purc_record.x_request_id,
                   NULL,                           --l_purc_record.x_auth_avs,
                        NULL,                 --l_purc_record.x_auth_response,
                             NULL,                --l_purc_record.x_auth_time,
                                  NULL,          --l_purc_record.x_auth_rcode,
                   NULL,                         --l_purc_record.x_auth_rflag,
                        NULL,                     --l_purc_record.x_auth_rmsg,
                   TO_CHAR (l_purc_record.x_rqst_date,
                            'yyyy-mm-dd hh24:mi:ss'),
                                          --l_purc_record.x_bill_request_time,
                   NULL,                         --l_purc_record.x_bill_rcode,
                        NULL,                    --l_purc_record.x_bill_rflag,
                             NULL,                --l_purc_record.x_bill_rmsg,
                   NULL,                  --l_purc_record.x_bill_trans_ref_no,
                        l_purc_record.x_customer_firstname,
                   l_purc_record.x_customer_lastname,
                   l_purc_record.x_customer_phone,
                   l_purc_record.x_customer_email, 'RECURINCOMPLETE',
                                -- This flag will be used by Recurring Payment
                   l_purc_record.x_bill_address1,
                   l_purc_record.x_bill_address2, l_purc_record.x_bill_city,
                   l_purc_record.x_bill_state, l_purc_record.x_bill_zip,
                   l_purc_record.x_bill_country, l_purc_record.x_esn,
                   l_purc_record.x_amount, l_purc_record.x_tax_amount,
                   l_purc_record.x_e911_tax_amount,
                   l_purc_record.x_usf_taxamount, --CR11553
                   l_purc_record.x_rcrf_tax_amount, --CR11553
                   l_purc_record.x_auth_amount, l_purc_record.x_bill_amount,
                   l_purc_record.x_user, l_purc_record.x_credit_code,
                   l_purc_record.purch_hdr2creditcard,
                   l_purc_record.purch_hdr2bank_acct,
                   l_purc_record.purch_hdr2user, l_purc_record.purch_hdr2esn,
                   l_purc_record.purch_hdr2rmsg_codes,
                   l_purc_record.purch_hdr2cr_purch,
                   l_purc_record.prog_hdr2x_pymt_src,
                   l_purc_record.prog_hdr2web_user, NULL,
                                                          --l_purc_record.prog_hdr2prog_batch,--l_purc_record.purch_hdr2prog_enrolled,
                   'RECURRING'
                  );

      ----------- Update the old record to indicate that a new record is entered - This attempt is redebited
      UPDATE x_program_purch_hdr
         SET x_payment_type = 'REDEBIT'
       WHERE objid = p_purch_objid;
   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
   END retry_redebit_rule_action;

   PROCEDURE de_enroll_rule_action (
      p_esn                 IN       x_program_enrolled.x_esn%TYPE,
      p_enrolled_objid      IN       x_program_enrolled.objid%TYPE,
      p_cool_period         IN       NUMBER,
      p_penalty_part_num    IN       table_part_num.objid%TYPE,
      p_create_tran_objid   IN       x_rule_create_trans.objid%TYPE,
      p_reason              IN       x_program_penalty_pend.x_penalty_reason%TYPE,
      p_rule_cat            IN       x_program_trans.x_action_text%TYPE,
      op_result             OUT      NUMBER,
      op_msg                OUT      VARCHAR2
   )
   IS
      flag                    CHAR (1)                                 := 'N';
      l_program_name          x_program_parameters.x_program_name%TYPE;
      for_cursor              EXCEPTION;
      v_pgm_enrolled          x_program_enrolled%ROWTYPE;
      l_date                  DATE                            DEFAULT SYSDATE;
      l_phone                 table_contact.objid%TYPE;
      l_pgm_enroll2web_user   NUMBER;
      l_flag                  NUMBER                                DEFAULT 0;
      l_penalty_amt           table_x_pricing.x_retail_price%TYPE;
      l_de_enroll_status      VARCHAR2 (30);
      l_de_enroll_code        x_program_parameters.x_de_enroll_cutoff_code%TYPE;
      l_benefit_cutoff_code   x_program_parameters.x_benefit_cutoff_code%TYPE;
      l_grace_condition       x_program_parameters.x_vol_deenro_ser_days_less%TYPE;
      l_grace_days            x_program_parameters.x_deenroll_add_ser_days%TYPE;
      l_error                 NUMBER;
      l_message               VARCHAR2 (255);
      l_is_mc                 NUMBER := 0;  -- NET10MC
      lv_cool_period		      sa.x_program_enrolled.x_cooling_period%type;--CR39833
   BEGIN
	  lv_cool_period := 0;--CR39833
      IF (p_enrolled_objid IS NULL OR p_enrolled_objid = 0)
      THEN
         op_result := -2;
         op_msg := 'Enrollment objid  is null or zero';
         RETURN;
      END IF;

--------------------------------------------------------------------------------------------------------
-- Get the program parameters for the benefits cutoff
      SELECT x_de_enroll_cutoff_code, x_benefit_cutoff_code, x_program_name
        INTO l_de_enroll_code, l_benefit_cutoff_code, l_program_name
        FROM x_program_parameters
       WHERE objid IN (SELECT pgm_enroll2pgm_parameter
                         FROM x_program_enrolled
                        WHERE objid = p_enrolled_objid);

-------------------------------------------
-- NET10MC Starts
-- To check if the ESN is Mega Card, if yes then insert the value for x_action_text accordingly
-- taking count to aviod NO_DATA_FOUND scenario
-- l_is_mc = 1 then it is MC else it is NON MC and x_action_text is BAU

      SELECT COUNT(1)
        INTO l_is_mc
       FROM x_service_plan_site_part spsp, x_service_plan sp
      WHERE sp.objid = spsp.x_service_plan_id
      AND sp.mkt_name IN ('Net10 Mega Card','Net10 Mega Card 750 Minutes')
      --CR14818 Start kacosta 04/03/2012
      --AND spsp.table_site_part_id = (SELECT pgm_enroll2site_part
      AND spsp.table_site_part_id IN (SELECT pgm_enroll2site_part
      --CR14818 End kacosta 04/03/2012
                                      FROM x_program_enrolled
                                     WHERE objid = p_enrolled_objid
                                     OR pgm_enroll2pgm_group = p_enrolled_objid );

-- NET10MC Ends
-------------------------------------------
      --      dbms_output.put_line('Got the program parameters ' || to_char ( l_de_enroll_code) );
      IF (l_de_enroll_code = 0)
      THEN
---- Cutoff at cycle date.
         flag := 'Y';

         -- Update only the expiry date for the program. Dont do anything else.
         -- Before that, insert a record into the program_trans table for logging.
         INSERT INTO x_program_trans
                     (objid, x_enrollment_status, x_enroll_status_reason,
                      x_trans_date, x_action_text, x_action_type, x_reason,
                      x_cooling_given, x_esn, x_exp_date, x_update_user,
                      pgm_tran2pgm_entrolled, pgm_trans2web_user,
                      pgm_trans2site_part)
            SELECT billing_seq ('X_PROGRAM_TRANS'), x_enrollment_status,
                   'DeEnrollment Scheduled', SYSDATE,
                   --DECODE (p_rule_cat,'Voluntary DeEnrollment Rules', 'Voluntary DeEnrollment','Payment DeEnrollment'),
                   (CASE WHEN (p_rule_cat = 'Voluntary DeEnrollment Rules' AND l_is_mc = 0) THEN 'Voluntary DeEnrollment'
                         WHEN (p_rule_cat = 'Voluntary DeEnrollment Rules' AND l_is_mc = 1) THEN 'MegaCard Redemption DeEnroll'
                    ELSE 'Payment DeEnrollment'
                    END), -- NET10MC
                   'DE_ENROLL', l_program_name || '    ' || '', lv_cool_period,
                    x_esn, x_exp_date,
                  --DECODE (p_rule_cat,'Voluntary DeEnrollment Rules', p_reason,'System'),
                   (CASE WHEN (p_rule_cat = 'Voluntary DeEnrollment Rules' AND l_is_mc = 0) THEN p_reason
                    ELSE 'System'
                    END),-- NET10MC
                   objid, pgm_enroll2web_user, pgm_enroll2site_part
              FROM x_program_enrolled
             WHERE (   objid = p_enrolled_objid
                    OR pgm_enroll2pgm_group = p_enrolled_objid
                   );
			/*-- commented as part of CR39833
         --        dbms_output.put_line('After insert into program trans ');
         UPDATE x_program_enrolled
            SET x_exp_date = x_next_charge_date,
                x_cooling_period =
                   GREATEST (NVL (p_cool_period, 0),
                             NVL (x_cooling_period, 0)),
                             -- If any past cooling period is applied, use MAX
                x_cooling_exp_date =
                   GREATEST (NVL (x_next_charge_date, SYSDATE),
                               SYSDATE
                             + GREATEST (NVL (p_cool_period, 0),
                                         NVL (x_cooling_period, 0)
                                        )
                            ),
                x_reason = p_reason,
                --x_next_charge_date = null,  -- Since at the next charge date, system will be de-enrolled, no need to charge the customer
                x_enrollment_status = 'DEENROLLED',
         -- DeEnroll the customer. Benefits will continue till the cycle date.
                x_tot_grace_period_given = 1,
  -- Flag to indicate that the customer will receive benefits till cycle date.
                x_wait_exp_date = NULL,
                x_update_stamp = l_date
          WHERE (   objid = p_enrolled_objid
                 OR pgm_enroll2pgm_group = p_enrolled_objid
                );
			*/
			--CR39833
            UPDATE x_program_enrolled
               SET x_enrollment_status = 'READYTOREENROLL',
				   x_exp_date = NULL,
                   x_cooling_exp_date = NULL,
                   x_next_delivery_date = NULL,
                   x_next_charge_date = NULL,
                   x_grace_period = NULL,
                   x_cooling_period = NULL,
                   x_service_days = NULL,
                   x_wait_exp_date = NULL,
                   x_tot_grace_period_given = NULL,
                   x_update_stamp = l_date
             WHERE (   objid = p_enrolled_objid
                 OR pgm_enroll2pgm_group = p_enrolled_objid
                );
         -- dbms_output.put_line('After update of enrolled table ');
         -- For each enrollment, extend the service days as per service cutoff paramters.
         FOR pgm_enrolled_rec IN (SELECT *
                                    FROM x_program_enrolled
                                   WHERE (   objid = p_enrolled_objid
                                          OR pgm_enroll2pgm_group =
                                                              p_enrolled_objid
                                         ))
         LOOP
----------------------------------------------------------------------------------------------------
--- Check for de-enroll status set for the program. ------------------------------------------------
            SELECT x_vol_deenro_ser_days_less, x_deenroll_add_ser_days
              INTO l_grace_condition, l_grace_days
              FROM x_program_parameters
             WHERE objid = pgm_enrolled_rec.pgm_enroll2pgm_parameter;

            -------------------------------- Deliver additional service days, if applicable. -------------------
            billing_extend_servicedays (pgm_enrolled_rec.x_esn,
                                        l_grace_days,
                                        l_grace_condition,
                                        l_error,
                                        l_message
                                       );
----------------------------------------------------------------------------------------------------
         END LOOP;

         RETURN;
      END IF;

      FOR pgm_enrolled_rec IN
         (SELECT *
            FROM x_program_enrolled
           WHERE (    (   objid = p_enrolled_objid
                       OR pgm_enroll2pgm_group = p_enrolled_objid
                      )
                  AND (   x_enrollment_status = 'SUSPENDED'
                       OR x_enrollment_status IN
                                          ('ENROLLED', 'ENROLLMENTSCHEDULED')
                      )
                 ))
      LOOP
         flag := 'Y';
         l_pgm_enroll2web_user := pgm_enrolled_rec.pgm_enroll2web_user;
        --CR34962
        sa.BILLING_BUNDLE_PKG.SP_DEENROLL_BUNDLE_PROG(
                pgm_enrolled_rec.x_esn          --IP_ESN
                , pgm_enrolled_rec.objid        --, IP_PROGRAM_ENROLLED_OBJID
                , op_result                     --, OP_ERROR_CODE
                , op_msg                        --, OP_ERROR_MSG
                );
         -- Check the program status. If the status says IMMEDIATE de-enroll, then set the status to
         -- de-enroll.
         -- If the status says, de-enroll on cycle date, change the exp_date to cycle_date.
         IF (    (lv_cool_period IS NULL OR lv_cool_period = 0)
             AND (pgm_enrolled_rec.x_enrollment_status != 'SUSPENDED')
            )
         THEN
            -- Insert the trans record.
            INSERT INTO x_program_trans
                        (objid, x_enrollment_status,
                         x_enroll_status_reason, x_float_given,
                         x_cooling_given, x_grace_period_given,
                         x_trans_date,
                         x_action_text,
                         x_action_type,
                         x_reason,
                         x_sourcesystem,
                         x_esn, x_exp_date, x_cooling_exp_date,
                         x_update_status,
                         x_update_user,
                         pgm_tran2pgm_entrolled,
                         pgm_trans2web_user,
                         pgm_trans2site_part
                        )
                 VALUES (billing_seq ('X_PROGRAM_TRANS'), 'DEENROLLED',
                         p_reason, NULL,
                         NVL (lv_cool_period, 0), NULL,
                         l_date,
                       --DECODE (p_rule_cat,'Voluntary DeEnrollment Rules', 'Voluntary DeEnrollment','Payment DeEnrollment'),
                        (CASE WHEN (p_rule_cat = 'Voluntary DeEnrollment Rules' AND l_is_mc = 0) THEN 'Voluntary DeEnrollment'
                              WHEN (p_rule_cat = 'Voluntary DeEnrollment Rules' AND l_is_mc = 1) THEN 'MegaCard Redemption DeEnroll'
                         ELSE 'Payment DeEnrollment'
                         END), -- NET10MC
                         'DE_ENROLL',
                         l_program_name || '    ' || 'READY TO REENROLL',
                         pgm_enrolled_rec.x_sourcesystem,
                         pgm_enrolled_rec.x_esn, l_date, l_date,
                         'I',
                      -- DECODE (p_rule_cat,'Voluntary DeEnrollment Rules', p_reason,'System'),
                        (CASE WHEN (p_rule_cat = 'Voluntary DeEnrollment Rules' AND l_is_mc = 0) THEN p_reason
                         ELSE 'System'
                         END),-- NET10MC
                         pgm_enrolled_rec.objid,
                         pgm_enrolled_rec.pgm_enroll2web_user,
                         pgm_enrolled_rec.pgm_enroll2site_part
                        );

            UPDATE x_program_enrolled
               SET x_enrollment_status = 'READYTOREENROLL',
				   x_exp_date = NULL,
                   x_cooling_exp_date = NULL,
                   x_next_delivery_date = NULL,
                   x_next_charge_date = NULL,
                   x_grace_period = NULL,
                   x_cooling_period = NULL,
                   x_service_days = NULL,
                   x_wait_exp_date = NULL,
                   x_tot_grace_period_given = NULL,
                   x_update_stamp = l_date
             WHERE objid = pgm_enrolled_rec.objid;


-- Added code for Extend Service Days
----------------------------------------------------------------------------------------------------
--- Check for de-enroll status set for the program. ------------------------------------------------
            SELECT x_vol_deenro_ser_days_less, x_deenroll_add_ser_days
              INTO l_grace_condition, l_grace_days
              FROM x_program_parameters
             WHERE objid = pgm_enrolled_rec.pgm_enroll2pgm_parameter;

            -------------------------------- Deliver additional service days, if applicable.
            billing_extend_servicedays (pgm_enrolled_rec.x_esn,
                                        l_grace_days,
                                        l_grace_condition,
                                        l_error,
                                        l_message
                                       );
         ELSE
			/*
            UPDATE x_program_enrolled
               SET x_enrollment_status = 'DEENROLLED',
                   x_cooling_exp_date =
                      DECODE (pgm_enrolled_rec.x_enrollment_status,
                              'SUSPENDED', TRUNC (l_date)
                               + GREATEST (NVL (x_cooling_period, 0),
                                           NVL (p_cool_period, 0)
                                          ),
                              GREATEST (TRUNC (l_date)
                                        + NVL (p_cool_period, 0)
                                                                --, NVL (x_cooling_exp_date, l_date)
                              )
                             ),
                   x_reason = p_reason,
                   x_update_stamp = l_date,
                   x_wait_exp_date = NULL
             WHERE objid = pgm_enrolled_rec.objid;
			*/
			--CR39833
            UPDATE x_program_enrolled
               SET x_enrollment_status = 'READYTOREENROLL',
				   x_exp_date = NULL,
                   x_cooling_exp_date = NULL,
                   x_next_delivery_date = NULL,
                   x_next_charge_date = NULL,
                   x_grace_period = NULL,
                   x_cooling_period = NULL,
                   x_service_days = NULL,
                   x_wait_exp_date = NULL,
                   x_tot_grace_period_given = NULL,
                   x_update_stamp = l_date
             WHERE objid = pgm_enrolled_rec.objid;
----------------------------------------------------------------------------------------------------
--- Check for de-enroll status set for the program. ------------------------------------------------
            SELECT x_vol_deenro_ser_days_less, x_deenroll_add_ser_days
              INTO l_grace_condition, l_grace_days
              FROM x_program_parameters
             WHERE objid = pgm_enrolled_rec.pgm_enroll2pgm_parameter;

            -------------------------------- Deliver additional service days, if applicable.
            billing_extend_servicedays (pgm_enrolled_rec.x_esn,
                                        l_grace_days,
                                        l_grace_condition,
                                        l_error,
                                        l_message
                                       );

----------------------------------------------------------------------------------------------------
            IF (pgm_enrolled_rec.objid = p_enrolled_objid)
            THEN
               -- This is the primary record. Apply penalties against this record
               IF     (p_penalty_part_num IS NOT NULL)
                  AND (billing_get_penalty_amt (p_penalty_part_num) IS NOT NULL
                      )
               THEN
                  INSERT INTO x_program_penalty_pend
                              (objid,
                               x_esn,
                               x_penalty_amt,
                               x_penalty_date, x_penalty_reason,
                               x_penalty_status, penal_pend2prog_enroll,
                               penal_pend2web_user,
                               penal_pend2prog_param,
                               penal_pend2part_num
                              )
                       VALUES (billing_seq ('X_PROGRAM_PENALTY_PEND'),
                               pgm_enrolled_rec.x_esn,
                               billing_get_penalty_amt (p_penalty_part_num),
                               l_date, p_reason,
                               'PENDING', pgm_enrolled_rec.objid,
                               pgm_enrolled_rec.pgm_enroll2web_user,
                               pgm_enrolled_rec.pgm_enroll2pgm_parameter,
                               p_penalty_part_num
                              );
               END IF;

               -- Notification code moved from here below
               -- Insert the notification record. -- Defect: Notify for primary and secondary
               --CR8663
               IF billing_job_pkg.is_sb_esn (p_enrolled_objid, NULL) <> 1
               THEN
                  INSERT INTO x_program_notify
                              (objid,
                               x_esn, x_program_name,
                               x_program_status, x_notify_process,
                               x_notify_status, x_source_system,
                               x_process_date, x_phone, x_language,
                               x_remarks,
                               pgm_notify2pgm_objid,
                               pgm_notify2contact_objid,
                               pgm_notify2web_user
                              )
                       VALUES (billing_seq ('X_PROGRAM_NOTIFY'),
                               pgm_enrolled_rec.x_esn, l_program_name,
                               'DEENROLLED', 'DE_ENROLL_RULE_ACTION',
                               'PENDING', pgm_enrolled_rec.x_sourcesystem,
                               l_date, l_phone, pgm_enrolled_rec.x_language,
                               p_reason,
                               pgm_enrolled_rec.pgm_enroll2pgm_group,
                               pgm_enrolled_rec.pgm_enroll2contact,
                               pgm_enrolled_rec.pgm_enroll2web_user
                              );
               END IF;
--CR8663
            END IF;

            -- Insert the trans record.
            INSERT INTO x_program_trans
                        (objid, x_enrollment_status,
                         x_enroll_status_reason, x_float_given,
                         x_cooling_given, x_grace_period_given, x_trans_date,
                         x_action_text,
                         x_action_type, x_reason,
                         x_sourcesystem,
                         x_esn, x_exp_date, x_cooling_exp_date,
                         x_update_status,
                         x_update_user,
                         pgm_tran2pgm_entrolled,
                         pgm_trans2web_user,
                         pgm_trans2site_part
                        )
                 VALUES (billing_seq ('X_PROGRAM_TRANS'), 'DEENROLLED',
                         p_reason, NULL,
                         NVL (lv_cool_period, 0), NULL, l_date,
                      -- DECODE (p_rule_cat,'Voluntary DeEnrollment Rules', 'Voluntary DeEnrollment','Payment DeEnrollment'),
                        (CASE WHEN (p_rule_cat = 'Voluntary DeEnrollment Rules' AND l_is_mc = 0) THEN 'Voluntary DeEnrollment'
                              WHEN (p_rule_cat = 'Voluntary DeEnrollment Rules' AND l_is_mc = 1) THEN 'MegaCard Redemption DeEnroll'
                         ELSE 'Payment DeEnrollment'
                         END), -- NET10MC
                         'DE_ENROLL', l_program_name || '    ' || '',
                         pgm_enrolled_rec.x_sourcesystem,
                         pgm_enrolled_rec.x_esn, l_date, l_date,
                         'I',
                      -- DECODE (p_rule_cat,'Voluntary DeEnrollment Rules', p_reason,'System'),
                        (CASE WHEN (p_rule_cat = 'Voluntary DeEnrollment Rules' AND l_is_mc = 0) THEN p_reason
                         ELSE 'System'
                         END),-- NET10MC
                         --                      'System',
                         pgm_enrolled_rec.objid,
                         pgm_enrolled_rec.pgm_enroll2web_user,
                         pgm_enrolled_rec.pgm_enroll2site_part
                        );
         END IF;
      END LOOP;

      IF     (    l_pgm_enroll2web_user IS NOT NULL
              AND p_create_tran_objid IS NOT NULL
             )
         AND flag = 'Y'
      THEN
         billing_rule_engine_action_pkg.set_cooling_others (l_pgm_enroll2web_user,
                             p_create_tran_objid,
                             p_reason,
                             op_result,
                             op_msg
                            );
         null;
      END IF;

      IF flag = 'N'
      THEN
         op_result := -1;
         op_msg := 'RECORD NOT FOUND';
         RAISE for_cursor;
      END IF;
   EXCEPTION
      WHEN for_cursor
      THEN
         op_result := -2;
         op_msg := 'RECORD NOT FOUND IN ENROLLMENT';
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
         DBMS_OUTPUT.put_line (op_msg);
   END de_enroll_rule_action;

   PROCEDURE reject_enroll_rule_action (
      p_esn              IN       x_metrics_reject_enroll.x_esn%TYPE,
      p_program_objid    IN       x_program_parameters.objid%TYPE,
      p_web_user_objid   IN       x_metrics_reject_enroll.reject_enrol2web_user%TYPE,
      p_reject_reason    IN       x_metrics_reject_enroll.x_reject_reason%TYPE,
      p_rule_cat         IN       x_metrics_reject_enroll.x_rule_cat%TYPE,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   )
   IS
      l_metrics_objid   NUMBER;
      l_date            DATE   DEFAULT SYSDATE;
   BEGIN
      FOR i IN 1 .. 1
      LOOP
         IF p_program_objid IS NULL OR p_web_user_objid IS NULL
         THEN
            op_result := -2;
            op_msg := 'Program Objid or Web user Objid is null';
            RETURN;
         ELSE
            IF p_program_objid = 0 OR p_web_user_objid = 0
            THEN
               op_result := -1;
               op_msg := 'Program objid or Web user Objid is zero';
               RETURN;
            END IF;
         END IF;
      END LOOP;

      l_metrics_objid := billing_seq ('x_metrics_reject_enroll');

      INSERT INTO x_metrics_reject_enroll
                  (objid, x_esn, x_reject_date, x_reject_reason,
                   x_rule_cat, reject_enrol2web_user, reject_enrol2prog_param
                  )
           VALUES (l_metrics_objid, p_esn, l_date, p_reject_reason,
                   p_rule_cat, p_web_user_objid, p_program_objid
                  );
   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
   END reject_enroll_rule_action;

-- CR13649 for Deenroll

   PROCEDURE set_cooling_period_rule_action (
      p_enrolled_objid   IN       x_program_enrolled.objid%TYPE,
      p_cool_period      IN       NUMBER,
      p_reason           IN       x_program_penalty_pend.x_penalty_reason%TYPE,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   )
   IS
      v_pgm_enrolled          x_program_enrolled%ROWTYPE;
      l_program_trans_objid   NUMBER;
      l_cooling_date          DATE;
      l_x                     DATE;
      l_date                  DATE                            DEFAULT SYSDATE;

      CURSOR c1
      IS
         SELECT *
           FROM x_program_enrolled
          WHERE objid = p_enrolled_objid;

      pgm_enrolled_rec        c1%ROWTYPE;
      grp_enroll_rec          x_program_enrolled%ROWTYPE;
      l_program_name          x_program_parameters.x_program_name%TYPE;
      l_prog_class x_program_parameters.x_prog_class%TYPE;      -- CR13649 for Deenroll
	  lv_cool_period		  sa.x_program_enrolled.x_cooling_period%type;--CR39833
   BEGIN
	  lv_cool_period := 0;--CR39833
      FOR i IN 1 .. 1
      LOOP
         IF p_enrolled_objid IS NULL
         THEN
            op_result := -2;
            op_msg := 'Enrollment Objid is null';
            RETURN;
         ELSE
            IF p_enrolled_objid = 0
            THEN
               op_result := -1;
               op_msg := 'Enrollment objid is zero';
               RETURN;
            END IF;
         END IF;
      END LOOP;

      l_cooling_date := l_date + lv_cool_period;

      OPEN c1;

      LOOP
         FETCH c1
          INTO pgm_enrolled_rec;

         EXIT WHEN c1%NOTFOUND;

         SELECT x_program_name, x_prog_class     -- CR13649
           INTO l_program_name , l_prog_class    -- CR13649
           FROM x_program_parameters
          WHERE objid = pgm_enrolled_rec.pgm_enroll2pgm_parameter;
          -- CR13649 STARRT
         IF pgm_enrolled_rec.x_enrollment_status IN ('ENROLLMENTBLOCKED','DEENROLLED')
           AND l_prog_class IS NOT NULL AND l_prog_class = 'LIFELINE'
         THEN
           UPDATE x_program_enrolled
           SET x_enrollment_status = 'READYTOREENROLL', x_update_stamp = l_date,
              X_COOLING_EXP_DATE = NULL,X_DELIVERY_CYCLE_NUMBER = NULL,
              X_NEXT_DELIVERY_DATE = NULL, X_CHARGE_DATE = NULL,
              X_NEXT_CHARGE_DATE = NULL, X_GRACE_PERIOD=NULL,
              X_COOLING_PERIOD = NULL, X_SERVICE_DAYS = NULL,
              X_WAIT_EXP_DATE = NULL, X_TOT_GRACE_PERIOD_GIVEN=NULL
           WHERE objid = p_enrolled_objid;
         -- CR13649  Ends
         -- IF pgm_enrolled_rec.x_enrollment_status IN ('ENROLLMENTBLOCKED', 'DEENROLLED') -- CR13649
         ELSIF pgm_enrolled_rec.x_enrollment_status IN ('ENROLLMENTBLOCKED', 'DEENROLLED')
            AND NVL (pgm_enrolled_rec.x_cooling_exp_date, SYSDATE) > l_cooling_date
         THEN
            NULL;
         ELSIF pgm_enrolled_rec.x_enrollment_status IN ('ENROLLMENTBLOCKED', 'DEENROLLED')
           AND NVL (pgm_enrolled_rec.x_cooling_exp_date, SYSDATE) < l_cooling_date
         THEN
            UPDATE x_program_enrolled
               SET x_cooling_exp_date = l_cooling_date, x_update_stamp = l_date
             WHERE objid = p_enrolled_objid;

            INSERT INTO x_program_trans
                        (objid,
                         x_enrollment_status, x_enroll_status_reason,
                         x_float_given, x_cooling_given,
                         x_grace_period_given, x_trans_date, x_action_text,
                         x_action_type,
                         x_reason,
                         x_sourcesystem,
                         x_esn, x_exp_date, x_cooling_exp_date,
                         x_update_status, x_update_user,
                         pgm_tran2pgm_entrolled,
                         pgm_trans2web_user,
                         pgm_trans2site_part
                        )
                 VALUES (billing_seq ('X_PROGRAM_TRANS'),
                         pgm_enrolled_rec.x_enrollment_status, p_reason,
                         NULL, lv_cool_period,
                         NULL, l_date, 'Cooling Period',
                         'DEENROLLED',
                            l_program_name
                         || '    '
                         || 'Cooling Period expires '
                         || l_cooling_date,
                         pgm_enrolled_rec.x_sourcesystem,
                         pgm_enrolled_rec.x_esn, l_date, l_date,
                         'I', 'System',
                         pgm_enrolled_rec.objid,
                         pgm_enrolled_rec.pgm_enroll2web_user,
                         pgm_enrolled_rec.pgm_enroll2site_part
                        );
         ELSIF pgm_enrolled_rec.x_enrollment_status IN
                                      ('ENROLLMENTFAILED', 'READYTOREENROLL')
         THEN
            UPDATE x_program_enrolled
               SET x_enrollment_status = 'ENROLLMENTBLOCKED',
                   x_cooling_exp_date = l_cooling_date,
                   x_update_stamp = l_date
             WHERE objid = p_enrolled_objid;

            INSERT INTO x_program_trans
                        (objid,
                         x_enrollment_status, x_enroll_status_reason,
                         x_float_given, x_cooling_given,
                         x_grace_period_given, x_trans_date, x_action_text,
                         x_action_type,
                         x_reason,
                         x_sourcesystem,
                         x_esn, x_exp_date, x_cooling_exp_date,
                         x_update_status, x_update_user,
                         pgm_tran2pgm_entrolled,
                         pgm_trans2web_user,
                         pgm_trans2site_part
                        )
                 VALUES (billing_seq ('X_PROGRAM_TRANS'),
                         pgm_enrolled_rec.x_enrollment_status, p_reason,
                         NULL, lv_cool_period,
                         NULL, l_date, 'Cooling Period',
                         'ENROLLMENTBLOCKED',
                            l_program_name
                         || '    '
                         || 'Enrollment blocked till '
                         || l_cooling_date,
                         pgm_enrolled_rec.x_sourcesystem,
                         pgm_enrolled_rec.x_esn, l_date, l_date,
                         'I', 'System',
                         pgm_enrolled_rec.objid,
                         pgm_enrolled_rec.pgm_enroll2web_user,
                         pgm_enrolled_rec.pgm_enroll2site_part
                        );
         ELSE
            NULL;
         /*
         op_result := 7001;
         op_msg := 'Invalid enrollment status to apply cooling period';
         EXIT;
         */
         END IF;

         -------------------------

         FOR idx2 IN (
         SELECT pe.*, pp.x_prog_class  -- CR13649
         FROM x_program_enrolled pe, x_program_parameters pp       -- CR13649
         WHERE pe.pgm_enroll2pgm_group = pgm_enrolled_rec.objid
          AND pe.pgm_enroll2pgm_parameter = pp.objid)            -- CR13649

         LOOP
            -- CR13649 Begin
            IF idx2.x_enrollment_status IN ('ENROLLMENTBLOCKED','DEENROLLED')
            AND idx2.x_prog_class IS NOT NULL AND idx2.x_prog_class = 'LIFELINE'
            THEN
              UPDATE x_program_enrolled
              SET x_enrollment_status = 'READYTOREENROLL', x_update_stamp = l_date,
              X_COOLING_EXP_DATE = NULL,X_DELIVERY_CYCLE_NUMBER = NULL,
              X_NEXT_DELIVERY_DATE = NULL, X_CHARGE_DATE = NULL,
              X_NEXT_CHARGE_DATE = NULL, X_GRACE_PERIOD=NULL,
              X_COOLING_PERIOD = NULL, X_SERVICE_DAYS = NULL,
              X_WAIT_EXP_DATE = NULL, X_TOT_GRACE_PERIOD_GIVEN=NULL
              WHERE objid = idx2.objid ;
              --WHERE pgm_enroll2pgm_group = pgm_enrolled_rec.objid;
              -- CR13649 Ends
            ELSIF idx2.x_enrollment_status IN ('ENROLLMENTBLOCKED', 'DEENROLLED')
               AND idx2.x_cooling_exp_date > l_cooling_date
            THEN
               NULL;
            ELSIF idx2.x_enrollment_status IN ('ENROLLMENTBLOCKED', 'DEENROLLED')
                  AND idx2.x_cooling_exp_date < l_cooling_date
            THEN
               UPDATE x_program_enrolled
                  SET x_cooling_exp_date = l_cooling_date,
                      x_update_stamp = l_date
                WHERE pgm_enroll2pgm_group = pgm_enrolled_rec.objid;

               --
               INSERT INTO x_program_trans
                           (objid,
                            x_enrollment_status, x_enroll_status_reason,
                            x_float_given, x_cooling_given,
                            x_grace_period_given, x_trans_date,
                            x_action_text, x_action_type,
                            x_reason,
                            x_sourcesystem, x_esn,
                            x_exp_date, x_cooling_exp_date, x_update_status,
                            x_update_user, pgm_tran2pgm_entrolled,
                            pgm_trans2web_user,
                            pgm_trans2site_part
                           )
                    VALUES (billing_seq ('X_PROGRAM_TRANS'),
                            idx2.x_enrollment_status, p_reason,
                            NULL, lv_cool_period,
                            NULL, l_date,
                            'Cooling Period', 'DEENROLLED',
                               l_program_name
                            || '    '
                            || 'Cooling Period expires '
                            || l_cooling_date,
                            pgm_enrolled_rec.x_sourcesystem, idx2.x_esn,
                            l_date, l_date, 'I',
                            'System', pgm_enrolled_rec.objid,
                            idx2.pgm_enroll2web_user,
                            pgm_enrolled_rec.pgm_enroll2site_part
                           );
            ELSIF idx2.x_enrollment_status IN
                                      ('ENROLLMENTFAILED', 'READYTOREENROLL')
            THEN
               UPDATE x_program_enrolled
                  SET x_enrollment_status = 'ENROLLMENTBLOCKED',
                      x_cooling_exp_date = l_cooling_date,
                      x_update_stamp = l_date
                WHERE pgm_enroll2pgm_group = pgm_enrolled_rec.objid;

               --
               INSERT INTO x_program_trans
                           (objid,
                            x_enrollment_status, x_enroll_status_reason,
                            x_float_given, x_cooling_given,
                            x_grace_period_given, x_trans_date,
                            x_action_text, x_action_type,
                            x_reason,
                            x_sourcesystem, x_esn,
                            x_exp_date, x_cooling_exp_date, x_update_status,
                            x_update_user, pgm_tran2pgm_entrolled,
                            pgm_trans2web_user,
                            pgm_trans2site_part
                           )
                    VALUES (billing_seq ('X_PROGRAM_TRANS'),
                            idx2.x_enrollment_status, p_reason,
                            NULL, lv_cool_period,
                            NULL, l_date,
                            'Cooling Period', 'ENROLLMENTBLOCKED',
                               l_program_name
                            || '    '
                            || 'Enrollment blocked till '
                            || l_cooling_date,
                            pgm_enrolled_rec.x_sourcesystem, idx2.x_esn,
                            l_date, l_date, 'I',
                            'System', pgm_enrolled_rec.objid,
                            idx2.pgm_enroll2web_user,
                            pgm_enrolled_rec.pgm_enroll2site_part
                           );
            ELSE
               NULL;
            /*
            op_result := 7001;
            op_msg := 'Invalid enrollment status to apply cooling period';
            */
            END IF;
         END LOOP;
      END LOOP;

      CLOSE c1;
   --      CLOSE v_rc1;
   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
   END set_cooling_period_rule_action;

   PROCEDURE set_grace_period_rule_action (
      p_esn                   IN       x_program_enrolled.x_esn%TYPE,
      p_pgmenrolled2program   IN       x_program_enrolled.objid%TYPE,
      p_grace_period          IN       NUMBER,
      op_result               OUT      NUMBER,
      op_msg                  OUT      VARCHAR2
   )
   IS
      for_cursor       EXCEPTION;
      flag             CHAR (1)                                   := 'N';
      l_date           DATE                                   DEFAULT SYSDATE;
      l_program_name   x_program_parameters.x_program_name%TYPE;
------------------------------------------------------------------
      l_result         NUMBER;
      l_msg            VARCHAR2 (255);
   BEGIN
      IF p_pgmenrolled2program IS NULL OR p_pgmenrolled2program = 0
      THEN
         op_result := -1;
         op_msg := 'Enrollment objid is zero or Null';
         RETURN;
      END IF;

      /*
      FOR pgm_enrolled_rec IN  (SELECT *
                                  FROM x_program_enrolled
                                 WHERE x_esn = p_esn
                                   AND pgm_enroll2pgm_group =
                                                         p_pgmenrolled2program)
      */
      FOR pgm_enrolled_rec IN (SELECT *
                                 FROM x_program_enrolled
                                WHERE (   objid = p_pgmenrolled2program
                                       OR pgm_enroll2pgm_group =
                                                         p_pgmenrolled2program
                                      ))
      LOOP
         flag := 'Y';

         -- Get the program name for logging.
         SELECT x_program_name
           INTO l_program_name
           FROM x_program_parameters
          WHERE objid = pgm_enrolled_rec.pgm_enroll2pgm_parameter;

         IF (p_grace_period = -1
            )             --If grace period is -1 sets expiry date to Infinite
         THEN
            UPDATE x_program_enrolled
               SET x_exp_date =
                      TO_DATE ('31/Dec/2049:23:59:59',
                               'dd/mm/yyyy HH24:MI:SS'),
                   x_update_stamp = l_date
             WHERE x_esn = pgm_enrolled_rec.x_esn
               AND objid = pgm_enrolled_rec.objid;

            INSERT INTO x_program_trans
                        (objid, x_enrollment_status,
                         x_enroll_status_reason, x_float_given,
                         x_cooling_given, x_grace_period_given, x_trans_date,
                         x_action_text, x_action_type,
                         x_reason,
                         x_sourcesystem,
                         x_esn, x_exp_date, x_cooling_exp_date,
                         x_update_status, x_update_user,
                         pgm_tran2pgm_entrolled,
                         pgm_trans2web_user,
                         pgm_trans2site_part
                        )
                 VALUES (billing_seq ('X_PROGRAM_TRANS'), 'SUSPENDED',
                         'Suspend Others Action', NULL,
                         NULL, p_grace_period, l_date,
                         'Grace Period Extension', 'GRACE_PEROD_EXTENSION',
                            l_program_name
                         || '    '
                         || TO_DATE ('31/Dec/2049:23:59:59',
                                     'dd/mm/yyyy HH24:MI:SS'
                                    ),
                         pgm_enrolled_rec.x_sourcesystem,
                         pgm_enrolled_rec.x_esn, l_date, l_date,
                         'I', 'System',
                         pgm_enrolled_rec.objid,
                         pgm_enrolled_rec.pgm_enroll2web_user,
                         pgm_enrolled_rec.pgm_enroll2site_part
                        );
         ELSE
-- Else Sets Grace  Period for the given no of days
            -------------------------------- Deliver additional service days, if applicable.--------------------
            billing_extend_servicedays (pgm_enrolled_rec.x_esn,
                                        p_grace_period,
                                        p_grace_period,
                                        l_result,
                                        l_msg
                                       );

----------------------------------------------------------------------------------------------------
            UPDATE x_program_enrolled
               SET x_exp_date = l_date + p_grace_period,
                   x_update_stamp = l_date,
                   x_grace_period = p_grace_period,
                   x_wait_exp_date = NULL,
                   x_service_days =
                      CASE
                         WHEN l_result = 1
                            THEN TO_NUMBER (l_msg)
                         ELSE x_service_days
                      END
             WHERE objid = pgm_enrolled_rec.objid;

            INSERT INTO x_program_trans
                        (objid, x_enrollment_status,
                         x_enroll_status_reason, x_float_given,
                         x_cooling_given, x_grace_period_given, x_trans_date,
                         x_action_text, x_action_type,
                         x_reason,
                         x_sourcesystem,
                         x_esn, x_exp_date, x_cooling_exp_date,
                         x_update_status, x_update_user,
                         pgm_tran2pgm_entrolled,
                         pgm_trans2web_user,
                         pgm_trans2site_part
                        )
                 VALUES (billing_seq ('X_PROGRAM_TRANS'), 'SUSPENDED',
                         'This ESN is suspended ', NULL,
                         NULL, p_grace_period, l_date,
                         'Grace Period Extension', 'GRACE_PEROD_EXTENSION',
                         l_program_name || '    ' || l_date + p_grace_period,
                         pgm_enrolled_rec.x_sourcesystem,
                         pgm_enrolled_rec.x_esn, l_date, l_date,
                         'I', 'System',
                         pgm_enrolled_rec.objid,
                         pgm_enrolled_rec.pgm_enroll2web_user,
                         pgm_enrolled_rec.pgm_enroll2site_part
                        );
         END IF;

         --- Put in a record for notification only for the group primary esn
         -- Change x_notify_status from NULL as PENDING
         IF     (pgm_enrolled_rec.objid = p_pgmenrolled2program)
            AND (billing_job_pkg.is_sb_esn (pgm_enrolled_rec.objid, NULL) <> 1
                )                                                     --CR8663
         THEN
            INSERT INTO x_program_notify
                        (objid,
                         x_esn, x_program_name,
                         x_program_status, x_notify_process,
                         x_notify_status, x_source_system, x_process_date,
                         x_phone, x_language, x_remarks,
                         pgm_notify2pgm_objid,
                         pgm_notify2contact_objid,
                         pgm_notify2web_user,
                         pgm_notify2pgm_enroll
                        )
                 VALUES (billing_seq ('X_PROGRAM_NOTIFY'),
                         pgm_enrolled_rec.x_esn, l_program_name,
                         'SUSPENDED', 'set_grace_period_rule_action',
                         'PENDING', NULL, l_date,
                         NULL, NULL, NULL,
                         pgm_enrolled_rec.pgm_enroll2pgm_group,
                         pgm_enrolled_rec.pgm_enroll2contact,
                         pgm_enrolled_rec.pgm_enroll2web_user,
                         pgm_enrolled_rec.objid
                        );
         END IF;
      END LOOP;

      IF flag = 'N'
      THEN
         RAISE for_cursor;
      END IF;
   EXCEPTION
      WHEN for_cursor
      THEN
         op_result := SQLCODE;
         op_msg := ' Record not found in Enrollment';
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
   END set_grace_period_rule_action;

   PROCEDURE set_penalty_rule_action (
      p_esn                 IN       x_program_enrolled.x_esn%TYPE,
      p_create_tran_objid   IN       x_rule_create_trans.objid%TYPE,
      p_prog_enroll_objid   IN       x_program_enrolled.objid%TYPE,
      p_reason              IN       x_program_penalty_pend.x_penalty_reason%TYPE,
      p_penalty_part_num    IN       table_part_num.objid%TYPE,
      op_result             OUT      NUMBER,
      op_msg                OUT      VARCHAR2
   )
   IS
      for_cursor        EXCEPTION;
      flag              CHAR (1)  := 'N';
      l_penalty_objid   NUMBER;
      l_date            DATE      DEFAULT SYSDATE;
   BEGIN
      IF p_prog_enroll_objid IS NULL OR p_prog_enroll_objid = 0
      THEN
         op_result := -1;
         op_msg := 'Enrollment objid is zero or Null';
         RETURN;
      END IF;

      FOR pgm_enrolled_rec IN (SELECT *
                                 FROM x_program_enrolled
                                WHERE objid = p_prog_enroll_objid)
      LOOP
         flag := 'Y';

         INSERT INTO x_program_penalty_pend
                     (objid, x_esn,
                      x_penalty_amt, x_penalty_date,
                      x_penalty_reason, x_penalty_status,
                      penal_pend2prog_enroll,
                      penal_pend2web_user,
                      penal_pend2prog_param,
                      penal_pend2part_num
                     )
              VALUES (billing_seq ('X_PROGRAM_PENALTY_PEND'), p_esn,
                      billing_get_penalty_amt (p_penalty_part_num), l_date,
                      (SELECT 'Rule-' || x_rule_set_name
                         FROM x_rule_create_trans
                        WHERE objid = p_create_tran_objid), 'PENDING',
                      p_prog_enroll_objid,
                      pgm_enrolled_rec.pgm_enroll2web_user,
                      pgm_enrolled_rec.pgm_enroll2pgm_parameter,
                      p_penalty_part_num
                     );
      END LOOP;

      IF flag = 'N'
      THEN
         RAISE for_cursor;
      END IF;
   EXCEPTION
      WHEN for_cursor
      THEN
         op_result := SQLCODE;
         op_msg := ' Record not found in Enrollment';
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
   END set_penalty_rule_action;

   PROCEDURE suspend_esn_rule_action (
      p_esn                 IN       x_program_enrolled.x_esn%TYPE,
      p_enrolled_objid      IN       x_program_enrolled.objid%TYPE,
      p_grace_period        IN       NUMBER,
      p_cooling_period      IN       NUMBER,
      p_penalty_part_num    IN       table_part_num.objid%TYPE,
      p_create_tran_objid   IN       x_rule_create_trans.objid%TYPE,
      p_reason              IN       x_program_penalty_pend.x_penalty_reason%TYPE,
      op_result             OUT      NUMBER,
      op_msg                OUT      VARCHAR2
   )
   IS
      v_pgm_enrolled          x_program_enrolled%ROWTYPE;
      l_error                 VARCHAR2 (100);
      l_message               VARCHAR2 (100);

      CURSOR c1
      IS
         SELECT *
           FROM x_program_enrolled
          WHERE objid = p_enrolled_objid
            AND (   x_enrollment_status = 'ENROLLED'
                 OR x_enrollment_status = 'SUSPENDED'
                );

      pgm_enrolled_rec        c1%ROWTYPE;

      TYPE rc1 IS REF CURSOR;

      v_rc1                   rc1;
      l_date                  DATE                             DEFAULT SYSDATE;
      l_pgm_enroll2web_user   NUMBER;
      l_program_name          x_program_parameters.x_program_name%TYPE;
      l_computed_exp_date     DATE                             DEFAULT SYSDATE;
   BEGIN
      OPEN c1;

      LOOP
         FETCH c1
          INTO pgm_enrolled_rec;

         EXIT WHEN c1%NOTFOUND;

         -- Get the program name for logging
         SELECT x_program_name
           INTO l_program_name
           FROM x_program_parameters
          WHERE objid = pgm_enrolled_rec.pgm_enroll2pgm_parameter;

         -- Check for Grace Period and Penalty
         IF p_grace_period IS NOT NULL AND p_penalty_part_num IS NOT NULL
         THEN
            IF (p_grace_period = -1
               )          --If grace period is -1 sets expiry date to Infinite
            THEN
               l_computed_exp_date :=
                    TO_DATE ('31/Dec/2049:23:59:59', 'dd/mm/yyyy HH24:MI:SS');

               UPDATE x_program_enrolled
                  SET x_enrollment_status = 'SUSPENDED',
                      x_exp_date = l_computed_exp_date,
                      x_cooling_period = p_cooling_period,
                      x_reason =
                           (SELECT x_rule_set_name || ';' || x_rule_set_desc
                              FROM x_rule_create_trans
                             WHERE objid = p_create_tran_objid),
                      x_update_stamp = l_date,
                      x_wait_exp_date = NULL
                --      x_penalty = p_penalty
               WHERE  (   objid = p_enrolled_objid
                       OR pgm_enroll2pgm_group = p_enrolled_objid
                      )
                  AND (   x_enrollment_status = 'ENROLLED'
                       OR x_enrollment_status = 'SUSPENDED'
                      );
            ELSE
-- Else Sets Grace  Period for the given no of days
               l_computed_exp_date := l_date + p_grace_period;

               UPDATE x_program_enrolled
                  SET x_enrollment_status = 'SUSPENDED',
                      x_exp_date = l_computed_exp_date,
                      x_cooling_period = p_cooling_period,
                      x_reason =
                           (SELECT x_rule_set_name || ';' || x_rule_set_desc
                              FROM x_rule_create_trans
                             WHERE objid = p_create_tran_objid),
                      x_update_stamp = l_date,
                      x_wait_exp_date = NULL
                --      x_penalty = p_penalty
               WHERE  (   objid = p_enrolled_objid
                       OR pgm_enroll2pgm_group = p_enrolled_objid
                      )
                  AND (   x_enrollment_status = 'ENROLLED'
                       OR x_enrollment_status = 'SUSPENDED'
                      );

               -------------------------------- Deliver additional service days, if applicable. -------------------
               billing_extend_servicedays (p_esn,
                                           p_grace_period,
                                           NULL,
                                           l_error,
                                           l_message
                                          );

               IF (l_error = 1)
               THEN
-- ESN Expiry date has been changed.
                  UPDATE x_program_enrolled
                     SET x_service_days = TO_NUMBER (l_message)
                   WHERE objid = p_enrolled_objid;
               END IF;
----------------------------------------------------------------------------------------------------
            END IF;

            INSERT INTO x_program_penalty_pend
                        (objid, x_esn,
                         x_penalty_amt,
                         x_penalty_date, x_penalty_reason,
                         x_penalty_status, penal_pend2prog_enroll,
                         penal_pend2web_user,
                         penal_pend2prog_param,
                         penal_pend2part_num
                        )
                 VALUES (billing_seq ('X_PROGRAM_PENALTY_PEND'), p_esn,
                             -- Billing Seq changed from x_program_notify tabl
                         NVL (billing_get_penalty_amt (p_penalty_part_num), 0),
                         l_date, (SELECT 'Rule-' || x_rule_set_name
                                    FROM x_rule_create_trans
                                   WHERE objid = p_create_tran_objid),
                         'PENDING', p_enrolled_objid,
                         pgm_enrolled_rec.pgm_enroll2web_user,
                         pgm_enrolled_rec.pgm_enroll2pgm_parameter,
                         p_penalty_part_num
                        );
         --- Only grace period to be applied. No Penalty.
         ELSIF     p_grace_period IS NOT NULL
               AND (p_penalty_part_num = 0 OR p_penalty_part_num IS NULL)
         THEN
            IF (p_grace_period = -1
               )          --If grace period is -1 sets expery date to Infinite
            THEN
               l_computed_exp_date :=
                    TO_DATE ('31/Dec/2049:23:59:59', 'dd/mm/yyyy HH24:MI:SS');

               UPDATE x_program_enrolled
                  SET x_enrollment_status = 'SUSPENDED',
                      x_exp_date = l_computed_exp_date,
                      x_cooling_period = p_cooling_period,
                      x_reason =
                           (SELECT x_rule_set_name || ';' || x_rule_set_desc
                              FROM x_rule_create_trans
                             WHERE objid = p_create_tran_objid),
                      x_update_stamp = l_date,
                      x_wait_exp_date = NULL
                WHERE (   objid = p_enrolled_objid
                       OR pgm_enroll2pgm_group = p_enrolled_objid
                      )
                  AND (   x_enrollment_status = 'ENROLLED'
                       OR x_enrollment_status = 'SUSPENDED'
                      );
            ELSE
-- Else Sets Grace  Period for the given no of days
               l_computed_exp_date := l_date + p_grace_period;

               UPDATE x_program_enrolled
                  SET x_enrollment_status = 'SUSPENDED',
                      x_exp_date = l_computed_exp_date,
                      x_cooling_period = p_cooling_period,
                      x_reason =
                           (SELECT x_rule_set_name || ';' || x_rule_set_desc
                              FROM x_rule_create_trans
                             WHERE objid = p_create_tran_objid),
                      x_update_stamp = l_date,
                      x_wait_exp_date = NULL
                WHERE (   objid = p_enrolled_objid
                       OR pgm_enroll2pgm_group = p_enrolled_objid
                      )
                  AND (   x_enrollment_status = 'ENROLLED'
                       OR x_enrollment_status = 'SUSPENDED'
                      );

               -------------------------------- Deliver additional service days, if applicable. -------------------
               billing_extend_servicedays (p_esn,
                                           p_grace_period,
                                           NULL,
                                           l_error,
                                           l_message
                                          );

               IF (l_error = 1)
               THEN
-- ESN Expiry date has been changed.
                  UPDATE x_program_enrolled
                     SET x_service_days = TO_NUMBER (l_message)
                   WHERE objid = p_enrolled_objid;
               END IF;
----------------------------------------------------------------------------------------------------
            END IF;
         ---- No grace period, only penalty
         ELSIF p_grace_period IS NULL AND p_penalty_part_num IS NOT NULL
         THEN
            UPDATE x_program_enrolled
               SET x_enrollment_status = 'SUSPENDED',
                   x_exp_date = l_computed_exp_date,
                   x_cooling_period = p_cooling_period,
                   x_reason =
                           (SELECT x_rule_set_name || ';' || x_rule_set_desc
                              FROM x_rule_create_trans
                             WHERE objid = p_create_tran_objid),
                   x_update_stamp = l_date,
                   x_wait_exp_date = NULL
             WHERE (   objid = p_enrolled_objid
                    OR pgm_enroll2pgm_group = p_enrolled_objid
                   )
               AND (   x_enrollment_status = 'ENROLLED'
                    OR x_enrollment_status = 'SUSPENDED'
                   );

            INSERT INTO x_program_penalty_pend
                        (objid, x_esn,
                         x_penalty_amt,
                         x_penalty_date, x_penalty_reason,
                         x_penalty_status, penal_pend2prog_enroll,
                         penal_pend2web_user,
                         penal_pend2prog_param,
                         penal_pend2part_num
                        )
                 VALUES (billing_seq ('X_PROGRAM_PENALTY_PEND'), p_esn,
                         NVL (billing_get_penalty_amt (p_penalty_part_num), 0),
                         l_date, (SELECT 'Rule-' || x_rule_set_name
                                    FROM x_rule_create_trans
                                   WHERE objid = p_create_tran_objid),
                         'PENDING', p_enrolled_objid,
                         pgm_enrolled_rec.pgm_enroll2web_user,
                         pgm_enrolled_rec.pgm_enroll2pgm_parameter,
                         p_penalty_part_num
                        );

            -------------------------------- Deliver additional service days, if applicable. -------------------
            billing_extend_servicedays (p_esn,
                                        p_grace_period,
                                        p_grace_period,
                                        l_error,
                                        l_message
                                       );
----------------------------------------------------------------------------------------------------
         ELSE
            -- No Grace, No Penalty
            UPDATE x_program_enrolled
               SET x_enrollment_status = 'SUSPENDED',
                   x_update_stamp = l_date,
                   x_cooling_period = p_cooling_period,
                   x_reason =
                           (SELECT x_rule_set_name || ';' || x_rule_set_desc
                              FROM x_rule_create_trans
                             WHERE objid = p_create_tran_objid),
                   x_exp_date = l_computed_exp_date,
                   x_wait_exp_date = NULL
             WHERE (   objid = p_enrolled_objid
                    OR pgm_enroll2pgm_group = p_enrolled_objid
                   )
               AND (   x_enrollment_status = 'ENROLLED'
                    OR x_enrollment_status = 'SUSPENDED'
                   );
         END IF;

         -- Insert a log into the program history
         INSERT INTO x_program_trans
                     (objid, x_enrollment_status, x_enroll_status_reason,
                      x_float_given, x_cooling_given, x_grace_period_given,
                      x_trans_date, x_action_text, x_action_type, x_reason,
                      x_sourcesystem, x_esn, x_exp_date, x_cooling_exp_date,
                      x_update_status, x_update_user, pgm_tran2pgm_entrolled,
                      pgm_trans2web_user, pgm_trans2site_part)
            SELECT billing_seq ('X_PROGRAM_TRANS'), 'SUSPENDED',
                   'This ESN is SUSPENDED', NULL, p_cooling_period, NULL,
                   l_date, 'Suspended', 'SUSPENDED',
                   l_program_name || '    ' || 'is Suspended',
                                                            --Payment Reversal
                                                              x_sourcesystem,
                   x_esn, l_computed_exp_date,
                   l_computed_exp_date + NVL (p_cooling_period, 0), 'I',
                   'System', objid, pgm_enroll2web_user, pgm_enroll2part_inst
              FROM x_program_enrolled
             WHERE (   objid = p_enrolled_objid
                    OR pgm_enroll2pgm_group = p_enrolled_objid
                   )
               AND x_enrollment_status = 'SUSPENDED';

         --Change x_notify_status from NULL as PENDING
         --CR8663
         IF billing_job_pkg.is_sb_esn (pgm_enrolled_rec.objid, NULL) <> 1
         THEN
            INSERT INTO x_program_notify
                        (objid,
                         x_esn, x_program_name,
                         x_program_status, x_notify_process,
                         x_notify_status, x_source_system,
                         x_process_date, x_phone, x_language, x_remarks,
                         pgm_notify2pgm_objid,
                         pgm_notify2contact_objid,
                         pgm_notify2web_user,
                         pgm_notify2pgm_enroll
                        )
                 VALUES (billing_seq ('X_PROGRAM_NOTIFY'),
                         pgm_enrolled_rec.x_esn, l_program_name,
                         'SUSPENDED', 'SUSPEND_ESN_RULE_ACTION',
                         'PENDING', pgm_enrolled_rec.x_sourcesystem,
                         SYSDATE, NULL, pgm_enrolled_rec.x_language, NULL,
                         pgm_enrolled_rec.pgm_enroll2pgm_parameter,
                         pgm_enrolled_rec.pgm_enroll2contact,
                         pgm_enrolled_rec.pgm_enroll2web_user,
                         pgm_enrolled_rec.objid
                        );
         END IF;
--CR8663
      END LOOP;

      /*
         OPEN v_rc1 FOR
            SELECT *
              FROM x_program_enrolled
             WHERE pgm_enroll2pgm_group = pgm_enrolled_rec.objid;
            LOOP
            UPDATE x_program_enrolled
               SET x_enrollment_status = 'SUSPENDED',
                    x_exp_date =   l_date
                             + p_grace_period,
                    x_update_stamp = l_date
              WHERE pgm_enroll2pgm_parameter = v_rc1.objid;

             INSERT INTO x_program_trans
                     (objid, x_enrollment_status,
                      x_enroll_status_reason, x_float_given, x_cooling_given,
                      x_grace_period_given, x_trans_date, x_action_text,
                      x_action_type, x_reason, x_sourcesystem,
                      x_esn, x_exp_date, x_cooling_exp_date, x_update_status,
                      x_update_user, pgm_tran2pgm_entrolled,
                      pgm_trans2web_user,
                      pgm_trans2site_part)
              VALUES (billing_seq ('X_PROGRAM_TRANS'), 'SUSPENDED',
                      'This ESN is SUSPENDED ', NULL, 10,
                      NULL, l_date, 'Suspended',
                      'SUSPENDED', l_program_name || '    ' || 'Payment Reversal', v_rc1.x_sourcesystem,
                      v_rc1.x_esn, l_date, l_date, 'I',
                      'System', v_rc1.objid,
                      v_rc1.pgm_enroll2web_user,
                      v_rc1.pgm_enroll2part_inst);


        END LOOP;
      CLOSE v_rc1;
      */
      CLOSE c1;
   /*  -- According to requirement change, Suspend for other programs is not applicable anymorem.
   IF      l_pgm_enroll2web_user IS NOT NULL
       AND p_create_tran_objid IS NOT NULL
   THEN
      suspend_action_others (
         l_pgm_enroll2web_user,
         p_esn,
         p_create_tran_objid,
         p_reason,
         op_result,
         op_msg
      );
   END IF;
   */
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         op_result := SQLCODE;
         op_msg := 'Invalid data input';
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
   END suspend_esn_rule_action;

   PROCEDURE update_metrics_rules_engine (
      p_rule_trans_objid   IN       x_rule_create_trans.objid%TYPE,
      p_metrics_count      OUT      NUMBER,
      op_result            OUT      NUMBER,
      op_msg               OUT      VARCHAR2
   )
   IS
      l_call_date       DATE                                  DEFAULT SYSDATE;
      l_cat_name        VARCHAR2 (255);
      l_rule_set_name   x_rule_create_trans.x_rule_set_name%TYPE;
      l_rule_set_desc   x_rule_create_trans.x_rule_set_desc%TYPE;
      sys_user          VARCHAR2 (30);
   BEGIN
      BEGIN
         --- Get the category name for the given transobjid
         SELECT b.x_rule_cat_name, a.x_rule_set_name, a.x_rule_set_desc
           INTO l_cat_name, l_rule_set_name, l_rule_set_desc
           FROM x_rule_create_trans a, x_rule_category_master b
          WHERE a.set_trans2rule_cat_mas = b.objid
            AND a.objid = p_rule_trans_objid;
      /*
      SELECT objid
        INTO l_cat_objid
        FROM x_rule_category_master
       WHERE x_rule_cat_name = LTRIM (RTRIM (p_rule_cata_name));
      */
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            op_result := SQLCODE;
            op_msg := ' No data found in x_rule_category_master table';
      END;

      INSERT INTO x_metrics_rule_engine_call
                  (objid, x_call_date,
                   x_rule_category, x_rule_set_name, x_rule_set_desc
                  )
           VALUES (billing_seq ('X_METRICS_RULE_ENGINE_CALL'), l_call_date,
                   l_cat_name, l_rule_set_name, l_rule_set_desc
                  );

      COMMIT;
   /*
   SELECT COUNT (*)
     INTO p_metrics_count
     FROM x_metrics_rule_engine_call;
   */
   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);

         IF (op_result = -1400)
         THEN
            op_result := -1400;
            op_msg :=
                  'Entered is NULL, You cannot modify'
               || TO_NUMBER (NULL)
               || ' records';
         END IF;
   END update_metrics_rules_engine;

   PROCEDURE prevent_cc_rule_action (
      p_credit_objid   IN       table_x_credit_card.objid%TYPE,
      p_reason         IN       x_metrics_cc_block.x_reason%TYPE,
      p_rule_cat       IN       x_metrics_cc_block.x_rule_category%TYPE,
      op_result        OUT      NUMBER,
      op_msg           OUT      VARCHAR2
   )
   IS
      cc_objid   x_payment_source.pymt_src2x_credit_card%TYPE;
      sys_user   VARCHAR2 (30);
   BEGIN
      SELECT USER
        INTO sys_user
        FROM DUAL;

      IF p_credit_objid IS NULL OR p_credit_objid = 0
      THEN
         raise_application_error (-20001, 'Credit Card Number Required.');
      ELSIF p_reason IS NULL
      THEN
         raise_application_error (-20001, 'Reason is Required.');
      ELSIF p_rule_cat IS NULL
      THEN
         raise_application_error (-20001, 'Category name is Required');
      END IF;

      -- Commented by Ramu .. No need to take payment objid
      -- SELECT PYMT_SRC2X_CREDIT_CARD
      -- INTO cc_objid
      -- FROM X_PAYMENT_SOURCE
      -- WHERE OBJID=p_credit_objid;
      -- Use CC Objid instead
      INSERT INTO x_metrics_cc_block
           VALUES (billing_seq ('X_METRICS_CC_BLOCK'), p_credit_objid,
                   p_reason, p_rule_cat);

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
   END prevent_cc_rule_action;

   PROCEDURE prevent_ach_rule_action (
      p_ach_objid   IN       table_x_bank_account.objid%TYPE,
      p_reason      IN       x_metrics_ach_block.x_reason%TYPE,
      p_rule_cat    IN       x_metrics_cc_block.x_rule_category%TYPE,
      op_result     OUT      NUMBER,
      op_msg        OUT      VARCHAR2
   )
   IS
      sys_user   VARCHAR2 (30);
   BEGIN
      SELECT USER
        INTO sys_user
        FROM DUAL;

      IF p_ach_objid IS NULL OR p_ach_objid = 0
      THEN
         raise_application_error (-20001, 'Account no is Required.');
      ELSIF p_reason IS NULL
      THEN
         raise_application_error (-20001, 'Reason is Required.');
      ELSIF p_rule_cat IS NULL
      THEN
         raise_application_error (-20001, 'Category name is Required');
      END IF;

      INSERT INTO x_metrics_ach_block
           VALUES (billing_seq ('X_METRICS_BANK_ACCOUNT'), p_ach_objid,
                   p_reason, p_rule_cat);

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
   END prevent_ach_rule_action;

   PROCEDURE prevent_customer_rule_action (
      p_web_user_objid   IN       x_metrics_block_status.block_status2web_user%TYPE,
      p_reason           IN       x_metrics_block_status.x_reason%TYPE,
      p_rule_cat         IN       x_metrics_cc_block.x_rule_category%TYPE,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   )
   IS
      part_objid      NUMBER;
      contact_objid   NUMBER;
      sys_user        VARCHAR2 (30);
   BEGIN
      SELECT USER
        INTO sys_user
        FROM DUAL;

      IF p_web_user_objid IS NULL OR p_web_user_objid = 0
      THEN
         raise_application_error (-20001, 'Web user Objid Number Required.');
      END IF;

      IF p_reason IS NULL
      THEN
         raise_application_error (-20001, 'Reason is Required.');
      ELSIF p_rule_cat IS NULL
      THEN
         raise_application_error (-20001, 'Catagory name is Required');
      END IF;

      --       SELECT objid
      --         INTO part_objid
      --         FROM table_part_inst
      --        WHERE X_PART_INST_STATUS = p_esn
      --          AND X_PART_INST_STATUS = 'active';
      --       SELECT X_CONTACT_PART_INST2CONTACT
      --         INTO contact_objid
      --         FROM table_x_contact_part_inst
      --        WHERE X_CONTACT_PART_INST2PART_INST = part_objid;
      INSERT INTO x_metrics_block_status
           VALUES (billing_seq ('X_METRICS_BLOCK_STATUS'), NULL, p_reason,
                   p_web_user_objid, NULL, p_rule_cat);

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);

         IF (op_result = -1400)
         THEN
            op_result := -1400;
            op_msg :=
                  'Entered is NULL, You cannot modify'
               || TO_NUMBER (NULL)
               || ' records';
         END IF;
   END prevent_customer_rule_action;

   PROCEDURE prevent_esn_rule_action (
      p_esn            IN       x_metrics_block_status.x_esn%TYPE,
      p_pgm_enrolled   IN       x_metrics_block_status.block_status2pgm_enroll%TYPE,
      p_reason         IN       x_metrics_block_status.x_reason%TYPE,
      p_rule_cat       IN       x_metrics_cc_block.x_rule_category%TYPE,
      op_result        OUT      NUMBER,
      op_msg           OUT      VARCHAR2
   )
   IS
      sys_user   VARCHAR2 (30);
   BEGIN
      SELECT USER
        INTO sys_user
        FROM DUAL;

      IF p_esn IS NULL
      THEN
         raise_application_error (-20001, 'ESN Number Required.');
      ELSIF p_pgm_enrolled IS NULL OR p_pgm_enrolled = 0
      THEN
         raise_application_error (-20001, 'Enrolled Objid no is Required.');
      ELSIF p_reason IS NULL
      THEN
         raise_application_error (-20001, 'Reason is Required.');
      ELSIF p_rule_cat IS NULL
      THEN
         raise_application_error (-20001, 'Category name is Required');
      END IF;

      INSERT INTO x_metrics_block_status
           VALUES (billing_seq ('X_METRICS_BLOCK_STATUS'), p_esn, p_reason,
                   NULL, p_pgm_enrolled, p_rule_cat);
   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);

         IF (op_result = -1400)
         THEN
            op_result := -1400;
            op_msg :=
                  'Entered is NULL, You cannot modify'
               || TO_NUMBER (NULL)
               || ' records';
         END IF;
   END prevent_esn_rule_action;

   PROCEDURE set_wait_grace_period_action (
      p_enroll_objid     IN       NUMBER,
      p_grace_period     IN       NUMBER,
      p_wait_days        IN       NUMBER,
      p_cooling_period   IN       NUMBER,
      p_user             IN       VARCHAR2,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   )
   IS
      for_cursor       EXCEPTION;
      flag             CHAR (1)                                   := 'N';
      c_user           VARCHAR2 (20);
      l_date           DATE                                   DEFAULT SYSDATE;
      l_program_name   x_program_parameters.x_program_name%TYPE;
      l_err_num        NUMBER;
      l_err_msg        VARCHAR2 (255);
   BEGIN
      IF p_enroll_objid IS NULL OR p_enroll_objid = 0
      THEN
         op_result := -1;
         op_msg := 'Enrollment objid is zero or Null';
         GOTO kk;
      END IF;

      SELECT USER
        INTO c_user
        FROM DUAL;

      FOR v_pgm_enrolled IN
         (SELECT *
            FROM x_program_enrolled
           WHERE objid = p_enroll_objid
              OR pgm_enroll2pgm_group = p_enroll_objid)
                                 -- Put additional phones in wait period also.
      LOOP
         flag := 'Y';

         SELECT x_program_name
           INTO l_program_name
           FROM x_program_parameters
          WHERE objid = v_pgm_enrolled.pgm_enroll2pgm_parameter;

         ---------------- Extend service days as applicable --------------------------------
         billing_extend_servicedays (v_pgm_enrolled.x_esn,
                                     p_wait_days,
                                     p_wait_days,
                                     l_err_num,
                                     l_err_msg
                                    );

-----------------------------------------------------------------------------------
         UPDATE x_program_enrolled
            SET
                --             SET --x_enrollment_status = 'SUSPENDED',
                --                 x_exp_date = GREATEST (
                --                                 (  l_date
                --                                  + p_grace_period
                --                                 ),
                --                                 NVL (x_exp_date, l_date)
                --                              ),
                x_update_stamp = l_date,
                x_wait_exp_date =
                   GREATEST ((l_date + p_wait_days),
                             NVL (x_wait_exp_date, l_date)
                            ),
                x_grace_period = p_grace_period,
                x_cooling_period = p_cooling_period,
                x_service_days =
                   CASE
                      WHEN l_err_num = 1
                         THEN TO_NUMBER (l_err_msg)
                      ELSE x_service_days
                   END
          WHERE objid = v_pgm_enrolled.objid;

         INSERT INTO x_program_trans
                     (objid,
                      x_enrollment_status,
                      x_enroll_status_reason, x_float_given, x_cooling_given,
                      x_grace_period_given, x_trans_date, x_action_text,
                      x_action_type,
                      x_reason,
                      x_sourcesystem, x_esn,
                      x_exp_date, x_cooling_exp_date, x_update_status,
                      x_update_user,
                      pgm_tran2pgm_entrolled,
                      pgm_trans2web_user,
                      pgm_trans2site_part
                     )
              --               VALUES (billing_seq ('X_PROGRAM_TRANS'), 'ready_to_re_enroll',
              --                       'This ESN SUSPENDED for program =>', NULL, 10,
              --                       NULL, l_date, 'TRANSFER_DAMAGE_TECH_GRACE_PERIOD',
              --                       NULL, NULL, NULL, v_pgm_enrolled.x_esn,
              --                       l_date, l_date, 'I',
              --                       c_user, v_pgm_enrolled.objid,
              --                       v_pgm_enrolled.pgm_enroll2web_user,
              --                       v_pgm_enrolled.pgm_enroll2site_part);
         VALUES      (billing_seq ('X_PROGRAM_TRANS'),
                      v_pgm_enrolled.x_enrollment_status,
                      'This ESN is in wait period ', NULL, NULL,
                      p_grace_period, l_date, 'wait period',
                      'DEACT',
                         l_program_name
                      || '    '
                      || 'Wait period set upto '
                      || TO_CHAR (l_date + p_wait_days),
                      v_pgm_enrolled.x_sourcesystem, v_pgm_enrolled.x_esn,
                      NULL, NULL, 'I',
                      DECODE (p_user, NULL, 'System', p_user),
                      v_pgm_enrolled.objid,
                      v_pgm_enrolled.pgm_enroll2web_user,
                      v_pgm_enrolled.pgm_enroll2site_part
                     );
      END LOOP;

      IF flag = 'N'
      THEN
         RAISE for_cursor;
      END IF;

      <<kk>>
      NULL;
   EXCEPTION
      WHEN for_cursor
      THEN
         op_result := SQLCODE;
         op_msg := 'Record Not found in Enrollment';
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
         DBMS_OUTPUT.put_line (SQLCODE || ' - ' || SQLERRM);
   END set_wait_grace_period_action;

   PROCEDURE set_cooling_others (
      p_web_user_objid   IN       x_program_enrolled.pgm_enroll2web_user%TYPE,
      p_tran_objid       IN       x_rule_action_params.rule_param2rule_trans%TYPE,
      p_reason           IN       VARCHAR2 DEFAULT 'DEENROLLED',
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   )
   IS
   BEGIN
      FOR idx IN (SELECT pe.objid, ap.rule_param2prog_param,
                         ap.x_cooling_period
                    FROM x_program_enrolled pe, x_rule_action_params ap
                   WHERE pe.pgm_enroll2pgm_parameter =
                                                     ap.rule_param2prog_param
                     AND ap.rule_param2rule_trans = p_tran_objid
                     AND pe.pgm_enroll2web_user = p_web_user_objid)
      LOOP
         billing_rule_engine_action_pkg.set_cooling_period_rule_action
                                                       (idx.objid,
                                                        idx.x_cooling_period,
                                                        p_reason,
                                                        op_result,
                                                        op_msg
                                                       );
      END LOOP;
   END set_cooling_others;

   PROCEDURE suspend_action_others (
      p_web_user_objid   IN       x_program_enrolled.pgm_enroll2web_user%TYPE,
      p_esn              IN       x_program_enrolled.x_esn%TYPE,
      p_tran_objid       IN       x_rule_action_params.rule_param2rule_trans%TYPE,
      p_reason           IN       x_program_penalty_pend.x_penalty_reason%TYPE,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   )
   IS
   BEGIN
      FOR idx IN (SELECT pe.objid, pe.x_esn, ap.rule_param2prog_param,
                         ap.x_grace_period
                    FROM x_program_enrolled pe, x_rule_action_params ap
                   WHERE pe.pgm_enroll2pgm_parameter =
                                                     ap.rule_param2prog_param
                     AND ap.rule_param2rule_trans = p_tran_objid
                     AND pe.pgm_enroll2web_user = p_web_user_objid
                     AND pe.x_esn = p_esn)
      LOOP
         billing_rule_engine_action_pkg.set_grace_period_rule_action
                                                         (idx.x_esn,
                                                          idx.objid,
                                                          idx.x_grace_period,
                                                          op_result,
                                                          op_msg
                                                         );
      END LOOP;
   END suspend_action_others;

   FUNCTION billing_get_penalty_amt (
      p_penalty_part_num   IN   table_part_num.objid%TYPE
   )
      RETURN NUMBER
   IS
      /*  This function returns penalty amount */
      l_amt   NUMBER;
   BEGIN
      -- BRAND_SEP
      SELECT x_retail_price
        INTO l_amt
        FROM table_x_pricing b
       WHERE x_pricing2part_num = p_penalty_part_num
         AND SYSDATE BETWEEN b.x_start_date AND b.x_end_date
         AND b.x_channel IS NOT NULL;                           -- new records

      RETURN l_amt;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   PROCEDURE deactivate_esn (
      p_esn       IN       x_program_enrolled.x_esn%TYPE,
      p_reason    IN       VARCHAR2,
      op_result   OUT      NUMBER,
      op_msg      OUT      VARCHAR2
   )
   IS
   BEGIN
      -- Just call the deactivation procedures
      service_deactivation_code.deactivate_any (p_esn,
                                                p_reason,
                                                NULL,
                                                op_result
                                               );

      IF (op_result = 0)
      THEN
         --- There was an error processing deactivation.
         --- Override with -100
         op_result := -100;
         op_msg := 'Unable to deactivate esn due to technical problems.';
      ELSE
         op_result := 0;
         op_msg := 'Success';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
   END deactivate_esn;
END billing_rule_engine_action_pkg;
/