CREATE OR REPLACE FUNCTION sa."BILLING_SEQ" (

   /*************************************************************************************************/
   /*                                                                                          	 */
   /* Name         :   billing_seq									 	 	 	 	 		 		 */
   /*                                                                                          	 */
   /* Purpose      :   To create sequences for billing platform									 */
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
   /*  1.1                                 CR7512                                                         	 */
   /*                                                                                          	 */
   /*************************************************************************************************/
   p_seq_name VARCHAR2
)
   RETURN NUMBER
IS
   PRAGMA autonomous_transaction;
   v_next_value NUMBER;
   temp_value NUMBER := 1;
BEGIN
   IF p_seq_name IS NULL
   THEN
      INSERT
      INTO error_table(
         error_text,
         error_date,
         action,
         KEY,
         program_name
      )       VALUES(
         'Billing Platform Table Name is required to generate the sequence',
         SYSDATE,
         'Generate Sequence',
         'BP_ERROR',
         'BILLING_SEQ'
      );
      COMMIT;
      raise_application_error ( - 20001, 'Table Name is required');
   END IF;
   IF UPPER (p_seq_name) = 'X_BILLING_CODE_TABLE'
   THEN
      SELECT sa.SEQ_X_BILLING_CODE_TABLE.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_JOB_MASTER'
   THEN
      SELECT sa.SEQ_X_JOB_MASTER.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_NTFY_CAT_MAS'
   THEN
      SELECT sa.SEQ_X_NTFY_CAT_MAS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_NTFY_LANG_MAS'
   THEN
      SELECT sa.SEQ_X_NTFY_LANG_MAS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_NTFY_SRC_MAS'
   THEN
      SELECT sa.SEQ_X_NTFY_SRC_MAS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_NTFY_CHNL_MAS'
   THEN
      SELECT sa.SEQ_X_NTFY_CHNL_MAS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_NTFY_TMPLT_MAS'
   THEN
      SELECT sa.SEQ_X_NTFY_TMPLT_MAS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_NTFY_FLUP_MAS'
   THEN
      SELECT sa.SEQ_X_NTFY_FLUP_MAS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_RULE_MESSAGE_MASTER'
   THEN
      SELECT sa.SEQ_X_RULE_MSG_MAS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_RULE_CATEGORY_MASTER'
   THEN
      SELECT sa.SEQ_X_RULE_CAT_MAS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_RULE_ACTION_MASTER'
   THEN
      SELECT sa.SEQ_X_RULE_ACTION_MASTER.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_RULE_ATTEMPT_MASTER'
   THEN
      SELECT sa.SEQ_X_RULE_ATTMT_MAS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_RULE_COND_DEF_MASTER'
   THEN
      SELECT sa.SEQ_X_RULE_COND_MAS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_ALERT_TRANS'
   THEN
      SELECT sa.SEQ_X_ALERT_TRANS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_NTFY_TRANS_LOG'
   THEN
      SELECT sa.SEQ_X_NTFY_TRANS_LOG.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_ADMIN_CONSOLE_ACTIVITY'
   THEN
      SELECT sa.SEQ_X_ADM_CONS_ACT.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_MERCHANT_REF_NUMBER'
   THEN
      SELECT sa.SEQ_X_MERCH_REF_NO.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_DEACT_PEND'
   THEN
      SELECT sa.SEQ_X_PROGRAM_DEACT_PEND.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_METRICS_PENALTY_PEND'
   THEN
      SELECT sa.SEQ_X_METRX_PEN_PEND.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_PAYMENT_RESP'
   THEN
      SELECT sa.SEQ_X_PAYMENT_RESP.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_METRICS_ENROLL_ATTEMPT'
   THEN
      SELECT sa.SEQ_X_METX_ENRL_ATTMT.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_GENCODE'
   THEN
      SELECT sa.SEQ_X_PROGRAM_GENCODE.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_ACH_CHARGEBACK_TRANS'
   THEN
      SELECT sa.SEQ_X_ACH_CHGBACK_TRA.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_ACH_PROG_TRANS'
   THEN
      SELECT sa.SEQ_X_ACH_PROG_TRANS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_CC_CHARGEBACK_TRANS'
   THEN
      SELECT sa.SEQ_X_CC_CHGBACK_TRA.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_CC_PROG_TRANS'
   THEN
      SELECT sa.SEQ_X_CC_PROG_TRANS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_JOB_RUN_DETAILS'
   THEN
      SELECT sa.SEQ_X_JOB_RUN_DETAILS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_JOB_RUN_LOG'
   THEN
      SELECT sa.SEQ_X_JOB_RUN_LOG.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_METRICS_ACH_BLOCK'
   THEN
      SELECT sa.SEQ_X_METRICS_ACH_BLOCK.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_METRICS_BLOCK_STATUS'
   THEN
      SELECT sa.SEQ_X_METX_BLK_STATUS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_METRICS_CC_BLOCK'
   THEN
      SELECT sa.SEQ_X_METRICS_CC_BLOCK.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_METRICS_FAILED_ENROLLMENT'
   THEN
      SELECT sa.SEQ_X_METRX_FAIL_ENRL.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_METRICS_REDEBITS'
   THEN
      SELECT sa.SEQ_X_METRICS_REDEBITS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_METRICS_RULE_ENGINE_CALL'
   THEN
      SELECT sa.SEQ_X_METX_RUL_ENG_CAL.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_NTFY_CAT_CONFIG'
   THEN
      SELECT sa.SEQ_X_NTFY_CAT_CONFIG.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_NTFY_FLUP_ITM'
   THEN
      SELECT sa.SEQ_X_NTFY_FLUP_ITM.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_NTFY_HISTORY'
   THEN
      SELECT sa.SEQ_X_NTFY_HISTORY.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_NTFY_LINK_TMPLT'
   THEN
      SELECT sa.SEQ_X_NTFY_LINK_TMPLT.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_PURCH_HDR'
   THEN
      SELECT sa.SEQ_X_PROGRAM_PURCH_HDR.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_PAYMENT_REAL_TIME'
   THEN
      SELECT sa.SEQ_X_PAYMENT_REAL_TIME.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_PAYMENT_SOURCE'
   THEN
      SELECT sa.SEQ_X_PAYMENT_SOURCE.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_BONUS_MINUTES'
   THEN
      SELECT sa.SEQ_X_PROG_BONUS_MIN.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_DELIVERY_TRANS'
   THEN
      SELECT sa.SEQ_X_PROG_DEL_TRA.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_ENROLLED'
   THEN
      SELECT sa.SEQ_X_PROGRAM_ENROLLED.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_H_SET_PERMITTED'
   THEN
      SELECT sa.SEQ_X_PROG_H_SET_PERM.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_NOTIFY'
   THEN
      SELECT sa.SEQ_X_PROGRAM_NOTIFY.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_PARAMETERS'
   THEN
      SELECT sa.SEQ_X_PROGRAM_PARAMETERS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_PURCH_DTL'
   THEN
      SELECT sa.SEQ_X_PROGRAM_PURCH_DTL.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_TRANS'
   THEN
      SELECT sa.SEQ_X_PROGRAM_TRANS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_RULE_COND_TRANS'
   THEN
      SELECT sa.SEQ_X_RULE_COND_TRANS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_RULE_COND_TRANS_VERSION'
   THEN
      SELECT sa.SEQ_X_RULE_COND_TRA_VR.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_RULE_CREATE_TRANS'
   THEN
      SELECT sa.SEQ_X_RULE_CREATE_TRANS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_RULE_CREATE_TRANS_VERSION'
   THEN
      SELECT sa.SEQ_X_RULE_CR_TRA_VR.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_SEQ_TABLE'
   THEN
      SELECT sa.SEQ_X_SEQ_TABLE.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_DATA_SERVICES_FUNDS'
   THEN
      SELECT sa.SEQ_X_DATA_SER_FNDS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_METRICS_BLK_DATA_SERV'
   THEN
      SELECT sa.SEQ_X_METX_BLK_DATA.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_RULE_ACTION_PARAMS'
   THEN
      SELECT sa.SEQ_X_RULE_ACTION_PARAMS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_RULE_ACTION_PARAMS_VERSION'
   THEN
      SELECT sa.SEQ_X_RULE_ACTION_PAR_VER.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_PENALTY_PEND'
   THEN
      SELECT sa.SEQ_X_PROG_PEN_PEND.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_METRICS_REJECT_ENROLL'
   THEN
      SELECT sa.SEQ_X_METX_REJ_ENRL.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_DISCOUNT_HIST'
   THEN
      SELECT sa.SEQ_X_PROG_DISC_HIST.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_BILLING_LOG'
   THEN
      SELECT sa.SEQ_X_BILLING_LOG.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_CHARGEBACK_TRANS'
   THEN
      SELECT sa.SEQ_X_CHARGEBACK_TRANS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_METRICS_REVERSAL'
   THEN
      SELECT sa.SEQ_X_METRICS_REVERSAL.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_RULE_VERSION'
   THEN
      SELECT sa.SEQ_X_RULE_VERSION.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_UPGRADE'
   THEN
      SELECT sa.SEQ_X_PROGRAM_UPGRADE.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_NTFY_FLUP_ACT'
   THEN
      SELECT sa.SEQ_X_NTFY_FLUP_ACT.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_NTFY_SENT'
   THEN
      SELECT sa.SEQ_X_NTFY_SENT.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_NTFY_BATCH'
   THEN
      SELECT sa.SEQ_X_NTFY_BATCH.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_BATCH'
   THEN
      SELECT sa.SEQ_X_PROGRAM_BATCH.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
   ELSIF UPPER (p_seq_name) = 'X_LIFELINE_ACTION_TRANS'
   THEN
      SELECT sa.SEQ_X_LL_ACTION_TRANS.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
	ELSIF UPPER (p_seq_name) = 'X_SETTLEMENTS_HISTORY' --CR38473
   THEN
      SELECT sa.SEQU_STLMNTS_HIST.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;
	ELSIF UPPER (p_seq_name) = 'X_SETTLEMENT_LOG'
   THEN
      SELECT sa.SEQU_STLMNTS_LOG.NEXTVAL
      INTO v_next_value
      FROM DUAL;
      RETURN v_next_value;  --CR38473
   ELSE
      INSERT
      INTO error_table(
         error_text,
         error_date,
         action,
         KEY,
         program_name
      )       VALUES(
         'Specified Sequence ' || p_seq_name || ' not found',
         SYSDATE,
         'Generate Sequence',
         'BP_ERROR',
         'BILLING_SEQ'
      );
      COMMIT;
      --raise_application_error (-20001, 'Table or Sequence Name not found');
      RETURN - 101;
   END IF;
   -- RETURN v_next_value;
   EXCEPTION
   WHEN OTHERS
   THEN
      INSERT
      INTO error_table(
         error_text,
         error_date,
         action,
         KEY,
         program_name
      )       VALUES(

         'An Exception Occured while generating the sequence for BillingPlatform table '
         || p_seq_name,
         SYSDATE,
         'Generate Sequence',
         'BP_ERROR',
         'BILLING_SEQ'
      );
      COMMIT;
      DBMS_OUTPUT.put_line(
      'An Exception Occured while generating the sequence for BillingPlatform table '
      || p_seq_name);
      --raise_application_error (-20001, 'An Exception Occured while generating the sequence');
      RETURN - 102 ;
-- This condition should not occur.
END;
/