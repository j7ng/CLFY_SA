CREATE OR REPLACE PACKAGE BODY sa.billing_rule_cond_eval_pkg
IS
   PROCEDURE billing_rule_cond_eval (
      p_enroll_objid           IN       NUMBER,
      p_create_objid           IN       NUMBER,
      p_mrchnt_rf_id           IN       VARCHAR2,
      p_cc_objid               IN       NUMBER,
      p_prog_id                IN       NUMBER,
      p_session_id             IN       VARCHAR2,
      p_esn                    IN       VARCHAR2,
      p_pay_type               IN       VARCHAR2,
      p_web_user_objid         IN       NUMBER,
      p_charge_reason_code     IN       VARCHAR2,
      p_charge_source_type     IN       VARCHAR2,
      p_web_csr_deact_reason   IN       VARCHAR2,
      p_attempt_no             IN       NUMBER,
      p_first_resp_code        IN       x_program_purch_hdr.x_ics_rcode%TYPE,
      p_second_resp_code       IN       x_program_purch_hdr.x_ics_rcode%TYPE,
      p_third_resp_code        IN       x_program_purch_hdr.x_ics_rcode%TYPE,
      p_first_resp_flag        IN       x_program_purch_hdr.x_ics_rflag%TYPE,
      p_second_resp_flag       IN       x_program_purch_hdr.x_ics_rflag%TYPE,
      p_third_resp_flag        IN       x_program_purch_hdr.x_ics_rflag%TYPE,
      o_result                 OUT      NUMBER,
      o_err_num                OUT      VARCHAR2,
      o_err_msg                OUT      VARCHAR2
   )
   IS
      CURSOR c1
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE cond_trans2create_trans = p_create_objid
            AND x_update_status != 'D';

      l_metrics_count   NUMBER;
      l_result          NUMBER;
      l_msg             VARCHAR (255);
	  l_chargeback_src_type VARCHAR (255);
   BEGIN


	  --Added for SETTING Source as Savings or Checking
	  --If chargeback payment source is ACH -- RUCHI

	  IF UPPER(p_charge_source_type) = 'ACH'
	  THEN

		 SELECT X_ABA_TRANSIT into l_chargeback_src_type
		 FROM TABLE_X_BANK_ACCOUNT a, X_PAYMENT_SOURCE b, X_PROGRAM_PURCH_HDR c
		 WHERE 1 = 1
		 AND a.OBJID = b.PYMT_SRC2X_BANK_ACCOUNT
		 AND b.OBJID = c.PROG_HDR2X_PYMT_SRC
		 AND c.X_MERCHANT_REF_NUMBER = p_mrchnt_rf_id;

	  ELSE
	    l_chargeback_src_type := p_charge_source_type;
	  END IF;

      FOR cond_rec IN c1
      LOOP
	     IF cond_rec.x_rule_cond_query = 'ATTEMPT_RESP_CODE'--Attempt Resp Code
         THEN
            billing_rule_engine_pkg.attempt_resp_code (
               cond_rec.objid,
               p_mrchnt_rf_id,
               p_esn,
               p_attempt_no,
               p_first_resp_code,
               p_second_resp_code,
               p_third_resp_code,
               p_first_resp_flag,
               p_second_resp_flag,
               p_third_resp_flag,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'TOT_NUM_DEC_CUST'
         THEN
            billing_rule_engine_pkg.tot_num_dec_cust (
               cond_rec.objid,
               p_web_user_objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'TOT_NUM_DEC_ESN'--Total Dclined in ESN
         THEN
            billing_rule_engine_pkg.tot_num_dec_esn (
               cond_rec.objid,
               p_esn,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'TOT_NUM_REV_CUST'--Total no of Rev by Customer
         THEN
            billing_rule_engine_pkg.tot_num_rev_cust (
               cond_rec.objid,
               p_web_user_objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'TOT_NUM_REV_ESN'--Total no of Rev by ESN
         THEN
            billing_rule_engine_pkg.tot_num_rev_esn (
               cond_rec.objid,
               p_esn,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'TOT_REDEBIT_ATTMT_CUST'--Total no redebit by customer
         THEN
            billing_rule_engine_pkg.tot_redebit_attmt_cust (
               cond_rec.objid,
               p_web_user_objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'AUTO_NUM_PAYMENT_RESP_ESN'
         THEN
            billing_rule_engine_pkg.auto_num_payment_resp_esn (
               cond_rec.objid,
               p_web_user_objid,
               p_mrchnt_rf_id,
               p_esn,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'AUTO_NUM_PAYMENT_RESP_CUST'
         THEN
            billing_rule_engine_pkg.auto_num_payment_resp_cust (
               cond_rec.objid,
               p_web_user_objid,
               p_mrchnt_rf_id,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'AUTO_TOT_REDEBIT_ATTMT_ESN'
         THEN
            billing_rule_engine_pkg.auto_tot_redebit_attmt_esn (
               cond_rec.objid,
               p_esn,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'AUTO_TOT_REDEBIT_ATTMT_CUST'
         THEN
            billing_rule_engine_pkg.auto_tot_redebit_attmt_cust (
               cond_rec.objid,
               p_web_user_objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'AUTO_TOT_NUM_REV_ESN'
         THEN
            billing_rule_engine_pkg.auto_tot_num_rev_esn (
               cond_rec.objid,
               p_esn,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'AUTO_TOT_NUM_REV_CUST'
         THEN
            billing_rule_engine_pkg.auto_tot_num_rev_cust (
               cond_rec.objid,
               p_web_user_objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'AUTO_NUM__DEC_CUST'
         THEN
            billing_rule_engine_pkg.auto_num_dec_cust (
               cond_rec.objid,
               p_web_user_objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'TOT_REDEBIT_ATTMT_ESN'--Total Redebet by ESN
         THEN
            billing_rule_engine_pkg.tot_redebit_attmt_esn (
               cond_rec.objid,
               p_esn,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'CC_BLOCKED_FTR_ENROLL'--CC Blocked ftr enrollment
         THEN
            billing_rule_engine_pkg.cc_blocked_ftr_enroll (
               p_cc_objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

		 IF cond_rec.x_rule_cond_query = 'ESN_BLOCKED_FTR_ENROLL'--ESN Blocked ftr enrollment
         THEN
            billing_rule_engine_pkg.esn_blocked_ftr_enroll (
               p_esn,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

        IF cond_rec.x_rule_cond_query = 'CUSTOMER_BLOCKED_FTR_ENROLL'--Custome Blocked ftr enrollment
         THEN
            billing_rule_engine_pkg.customer_blocked_ftr_enroll (
               p_web_user_objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'ESN_IN_COOLING_PRD'
         THEN
            billing_rule_engine_pkg.esn_in_cooling_prd (
               p_enroll_objid,
               p_esn,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'ESN_PROG_LENGTH'--Program Length
         THEN
            billing_rule_engine_pkg.esn_prog_length (
               cond_rec.objid,
               p_enroll_objid,
               p_esn,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'NAME_AUTOPAY_PGM_ENROLL'--Enrolled Prog name
         THEN
            billing_rule_engine_pkg.name_autopay_pgm_enroll (
               cond_rec.objid,
               p_enroll_objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'PAYMENT_METHOD'
         THEN
            billing_rule_engine_pkg.payment_method (
               cond_rec.objid,
               p_pay_type,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'CC_BLACK_LISTED'--Credit Card Blacklisted
         THEN
            billing_rule_engine_pkg.cc_black_listed (
               p_cc_objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'CC_NOT_BLOCKED_FTR_ENROLL'--CC blocked for Enrollment
         THEN
            billing_rule_engine_pkg.cc_not_blocked_ftr_enroll (
               p_cc_objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'ESN_NOT_IN_COOLING_PRD'
         THEN
            billing_rule_engine_pkg.esn_not_in_cooling_prd (
               p_enroll_objid,
               p_esn,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'CC_NOT_BLACK_LISTED'
         THEN
            billing_rule_engine_pkg.cc_not_black_listed (
               p_cc_objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'FAIL_ENROLL_ATTMT_CUST'--Fail enrollment attempt by cutomer
         THEN
            billing_rule_engine_pkg.auto_fail_enroll_attmt_cust (
               cond_rec.objid,
               p_web_user_objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'AUTO_FAIL_ENROLL_ATTMT_DAY'--FAIL_ENROLL_ATTMT_DAY
         THEN
            billing_rule_engine_pkg.auto_fail_enroll_attmt_day (
               cond_rec.objid,
               p_web_user_objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'FAIL_ENROLL_ATTMT_PROG'
         THEN
            billing_rule_engine_pkg.auto_fail_enroll_attmt_prog (
               cond_rec.objid,
               p_prog_id,
               p_web_user_objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'TOT_AMT_ADDED_AFT_ENROLL'--Tot amt added after enrollment
         THEN
            billing_rule_engine_pkg.tot_amt_added_aft_enroll (
               cond_rec.objid,
               p_esn,
               p_web_user_objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'TOT_AMT_ADDED_LAST30DAY'
         THEN
            billing_rule_engine_pkg.tot_amt_added_last30day (
               cond_rec.objid,
               p_esn,
               p_web_user_objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'TOT_AMT_ADDED_SESSION'--Total amt added after session
         THEN
            billing_rule_engine_pkg.tot_amt_added_session (
               cond_rec.objid,
               p_session_id,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'NUM_PAYMENT_RESP_CUST'
         THEN
            billing_rule_engine_pkg.num_payment_resp_cust (
               cond_rec.objid,
               p_web_user_objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'NUM_PAYMENT_RESP_ESN'
         THEN
            billing_rule_engine_pkg.num_payment_resp_esn (
               cond_rec.objid,
               p_web_user_objid,
               p_esn,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'AUTO_NAME_PROG_TRYING'--Program trying to enroll
         THEN
            billing_rule_engine_pkg.auto_name_prog_trying (
               -- to find out the name of the autopay program trying to enroll
               p_prog_id,
               cond_rec.objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'PNOW_PAYMENT_ATTEMPT_REVERSAL'
         THEN
            billing_rule_engine_pkg.pnow_payment_attempt_reversal (
               p_enroll_objid,
               cond_rec.objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'WEB_CSR_IS_ENROLL_GROUP'--Ernolled in Group Program
         THEN
            billing_rule_engine_pkg.web_csr_is_enroll_group (
               p_prog_id,
               p_esn,
               cond_rec.objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'CHARGE_BACK_REASON_CODE'--Checked
         THEN
            billing_rule_engine_pkg.charge_back_reason_code (
               p_charge_reason_code,
               cond_rec.objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'CHARGE_BACK_FUND_SRC_TYPE'--checked
         THEN
            billing_rule_engine_pkg.charge_back_fund_src_type (
               l_chargeback_src_type,
               cond_rec.objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'WEB_CSR_DEACTIVATION_REASON'--Checked
         THEN
            billing_rule_engine_pkg.web_csr_deactivation_reason (
               p_web_csr_deact_reason,
               cond_rec.objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'PNOW_FOR_PAST_DUE'--Checked
         THEN
            billing_rule_engine_pkg.pnow_for_past_due (
               p_enroll_objid,
               cond_rec.objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'PNOW_FOR_FTR_CYL'
         THEN
            billing_rule_engine_pkg.pnow_for_ftr_cyl (
               p_enroll_objid,
               cond_rec.objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'CURRENT_RESPONSE_CODE'--Checked
         THEN
            billing_rule_engine_pkg.current_response_code (
               p_enroll_objid,
               cond_rec.objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;


         IF cond_rec.x_rule_cond_query = 'CURRENT_AUTOPAY_STATUS'--Checked
         THEN
            billing_rule_engine_pkg.current_autopay_status (
               p_enroll_objid,
               cond_rec.objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;

         IF cond_rec.x_rule_cond_query = 'TOT_NUM_FAIL_RESP_IN_CYL'--checked
         THEN
            billing_rule_engine_pkg.tot_num_fail_resp_in_cyl (
               p_enroll_objid,
               cond_rec.objid,
               o_result,
               o_err_num,
               o_err_msg
            );

            IF o_result = 0
            THEN
               EXIT;
            END IF;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (-20001, 'Condition objid Is invalid..');
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END;
END billing_rule_cond_eval_pkg;
/