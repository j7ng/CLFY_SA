CREATE OR REPLACE procedure sa.billing_seq_jing (p_seq_name in VARCHAR2, seq_name out varchar2, v_next_value out number )
IS
   --PRAGMA AUTONOMOUS_TRANSACTION;
  -- v_next_value   NUMBER;
   temp_value     NUMBER := 1;
BEGIN
   IF UPPER (p_seq_name) = 'X_BILLING_CODE_TABLE'
   THEN
      SELECT sa.seq_x_billing_code_table.NEXTVAL
        INTO v_next_value
        FROM DUAL;
     seq_name:='seq_x_billing_code_table';

   ELSIF UPPER (p_seq_name) = 'X_JOB_MASTER'
   THEN
      SELECT sa.seq_x_job_master.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_job_master';

   ELSIF UPPER (p_seq_name) = 'X_NTFY_CAT_MAS'
   THEN
      SELECT sa.seq_x_ntfy_cat_mas.NEXTVAL
        INTO v_next_value
        FROM DUAL;
         seq_name:='seq_x_ntfy_cat_mas';

   ELSIF UPPER (p_seq_name) = 'X_NTFY_LANG_MAS'
   THEN
      SELECT sa.seq_x_ntfy_lang_mas.NEXTVAL
        INTO v_next_value
        FROM DUAL;
          seq_name:='seq_x_ntfy_lang_mas';
   ELSIF UPPER (p_seq_name) = 'X_NTFY_SRC_MAS'
   THEN
      SELECT sa.seq_x_ntfy_src_mas.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_ntfy_src_mas';

   ELSIF UPPER (p_seq_name) = 'X_NTFY_CHNL_MAS'
   THEN
      SELECT sa.seq_x_ntfy_chnl_mas.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_ntfy_chnl_mas';

   ELSIF UPPER (p_seq_name) = 'X_NTFY_TMPLT_MAS'
   THEN
      SELECT sa.seq_x_ntfy_tmplt_mas.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_ntfy_tmplt_mas';

   ELSIF UPPER (p_seq_name) = 'X_NTFY_FLUP_MAS'
   THEN
      SELECT sa.seq_x_ntfy_flup_mas.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_ntfy_flup_mas';

   ELSIF UPPER (p_seq_name) = 'X_RULE_MESSAGE_MASTER'
   THEN
      SELECT sa.seq_x_rule_msg_mas.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_rule_msg_mas';

   ELSIF UPPER (p_seq_name) = 'X_RULE_CATEGORY_MASTER'
   THEN
      SELECT sa.seq_x_rule_cat_mas.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_rule_cat_mas';

   ELSIF UPPER (p_seq_name) = 'X_RULE_ACTION_MASTER'
   THEN
      SELECT sa.seq_x_rule_action_master.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_rule_action_master';

   ELSIF UPPER (p_seq_name) = 'X_RULE_ATTEMPT_MASTER'
   THEN
      SELECT sa.seq_x_rule_attmt_mas.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_rule_attmt_mas';

   ELSIF UPPER (p_seq_name) = 'X_RULE_COND_DEF_MASTER'
   THEN
      SELECT sa.seq_x_rule_cond_mas.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_rule_cond_mas';

   ELSIF UPPER (p_seq_name) = 'X_ALERT_TRANS'
   THEN
      SELECT sa.seq_x_alert_trans.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_alert_trans';

   ELSIF UPPER (p_seq_name) = 'X_NTFY_TRANS_LOG'
   THEN
      SELECT sa.seq_x_ntfy_trans_log.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_ntfy_trans_log';

   ELSIF UPPER (p_seq_name) = 'X_ADMIN_CONSOLE_ACTIVITY'
   THEN
      SELECT sa.seq_x_adm_cons_act.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_adm_cons_act';

   ELSIF UPPER (p_seq_name) = 'X_MERCHANT_REF_NUMBER'
   THEN
      SELECT sa.seq_x_merch_ref_no.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_merch_ref_no';

   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_DEACT_PEND'
   THEN
      SELECT sa.seq_x_program_deact_pend.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_program_deact_pend';

   ELSIF UPPER (p_seq_name) = 'X_METRICS_PENALTY_PEND'
   THEN
      SELECT sa.seq_x_metrx_pen_pend.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_metrx_pen_pend';

   ELSIF UPPER (p_seq_name) = 'X_PAYMENT_RESP'
   THEN
      SELECT sa.seq_x_payment_resp.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_payment_resp';

   ELSIF UPPER (p_seq_name) = 'X_METRICS_ENROLL_ATTEMPT'
   THEN
      SELECT sa.seq_x_metx_enrl_attmt.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_metx_enrl_attmt';

   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_GENCODE'
   THEN
      SELECT sa.seq_x_program_gencode.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_program_gencode';

   ELSIF UPPER (p_seq_name) = 'X_ACH_CHARGEBACK_TRANS'
   THEN
      SELECT sa.seq_x_ach_chgback_tra.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_ach_chgback_tra';

   ELSIF UPPER (p_seq_name) = 'X_ACH_PROG_TRANS'
   THEN
      SELECT sa.seq_x_ach_prog_trans.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_ach_prog_trans';

   ELSIF UPPER (p_seq_name) = 'X_CC_CHARGEBACK_TRANS'
   THEN
      SELECT sa.seq_x_cc_chgback_tra.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_cc_chgback_tra';

   ELSIF UPPER (p_seq_name) = 'X_CC_PROG_TRANS'
   THEN
      SELECT sa.seq_x_cc_prog_trans.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_cc_prog_trans';

   ELSIF UPPER (p_seq_name) = 'X_JOB_RUN_DETAILS'
   THEN
      SELECT sa.seq_x_job_run_details.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_job_run_details';

   ELSIF UPPER (p_seq_name) = 'X_JOB_RUN_LOG'
   THEN
      SELECT sa.seq_x_job_run_log.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_job_run_log';

   ELSIF UPPER (p_seq_name) = 'X_METRICS_ACH_BLOCK'
   THEN
      SELECT sa.seq_x_metrics_ach_block.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_metrics_ach_block';

   ELSIF UPPER (p_seq_name) = 'X_METRICS_BLOCK_STATUS'
   THEN
      SELECT sa.seq_x_metx_blk_status.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_metx_blk_status';

   ELSIF UPPER (p_seq_name) = 'X_METRICS_CC_BLOCK'
   THEN
      SELECT sa.seq_x_metrics_cc_block.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_metrics_cc_block';

   ELSIF UPPER (p_seq_name) = 'X_METRICS_FAILED_ENROLLMENT'
   THEN
      SELECT sa.seq_x_metrx_fail_enrl.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_metrx_fail_enrl';

   ELSIF UPPER (p_seq_name) = 'X_METRICS_REDEBITS'
   THEN
      SELECT sa.seq_x_metrics_redebits.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_metrics_redebits';

   ELSIF UPPER (p_seq_name) = 'X_METRICS_RULE_ENGINE_CALL'
   THEN
      SELECT sa.seq_x_metx_rul_eng_cal.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_metx_rul_eng_cal';

   ELSIF UPPER (p_seq_name) = 'X_NTFY_CAT_CONFIG'
   THEN
      SELECT sa.seq_x_ntfy_cat_config.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_ntfy_cat_config';

   ELSIF UPPER (p_seq_name) = 'X_NTFY_FLUP_ITM'
   THEN
      SELECT sa.seq_x_ntfy_flup_itm.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_ntfy_flup_itm';

   ELSIF UPPER (p_seq_name) = 'X_NTFY_HISTORY'
   THEN
      SELECT sa.seq_x_ntfy_history.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_ntfy_history';

   ELSIF UPPER (p_seq_name) = 'X_NTFY_LINK_TMPLT'
   THEN
      SELECT sa.seq_x_ntfy_link_tmplt.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_ntfy_link_tmplt';

   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_PURCH_HDR'
   THEN
      SELECT sa.seq_x_program_purch_hdr.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_program_purch_hdr';

   ELSIF UPPER (p_seq_name) = 'X_PAYMENT_REAL_TIME'
   THEN
      SELECT sa.seq_x_payment_real_time.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_payment_real_time';

   ELSIF UPPER (p_seq_name) = 'X_PAYMENT_SOURCE'
   THEN
      SELECT sa.seq_x_payment_source.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_payment_source';

   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_BONUS_MINUTES'
   THEN
      SELECT sa.seq_x_prog_bonus_min.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_prog_bonus_min';

   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_DELIVERY_TRANS'
   THEN
      SELECT sa.seq_x_prog_del_tra.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_prog_del_tra';

   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_ENROLLED'
   THEN
      SELECT sa.seq_x_program_enrolled.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_program_enrolled';

   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_H_SET_PERMITTED'
   THEN
      SELECT sa.seq_x_prog_h_set_perm.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_prog_h_set_perm';

   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_NOTIFY'
   THEN
      SELECT sa.seq_x_program_notify.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_program_notify';

   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_PARAMETERS'
   THEN
      SELECT sa.seq_x_program_parameters.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_program_parameters';

   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_PURCH_DTL'
   THEN
      SELECT sa.seq_x_program_purch_dtl.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_program_purch_dtl';

   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_TRANS'
   THEN
      SELECT sa.seq_x_program_trans.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_program_trans';

   ELSIF UPPER (p_seq_name) = 'X_RULE_COND_TRANS'
   THEN
      SELECT sa.seq_x_rule_cond_trans.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_rule_cond_trans';

   ELSIF UPPER (p_seq_name) = 'X_RULE_COND_TRANS_VERSION'
   THEN
      SELECT sa.seq_x_rule_cond_tra_vr.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_rule_cond_tra_vr';

   ELSIF UPPER (p_seq_name) = 'X_RULE_CREATE_TRANS'
   THEN
      SELECT sa.seq_x_rule_create_trans.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_rule_create_trans';

   ELSIF UPPER (p_seq_name) = 'X_RULE_CREATE_TRANS_VERSION'
   THEN
      SELECT sa.seq_x_rule_cr_tra_vr.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_rule_cr_tra_vr';

   ELSIF UPPER (p_seq_name) = 'X_SEQ_TABLE'
   THEN
      SELECT sa.seq_x_seq_table.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_seq_table';

   ELSIF UPPER (p_seq_name) = 'X_DATA_SERVICES_FUNDS'
   THEN
      SELECT sa.seq_x_data_ser_fnds.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_data_ser_fnds';

   ELSIF UPPER (p_seq_name) = 'X_METRICS_BLK_DATA_SERV'
   THEN
      SELECT sa.seq_x_metx_blk_data.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_metx_blk_data';

   ELSIF UPPER (p_seq_name) = 'X_RULE_ACTION_PARAMS'
   THEN
      SELECT sa.seq_x_rule_action_params.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_rule_action_params';

   ELSIF UPPER (p_seq_name) = 'X_RULE_ACTION_PARAMS_VERSION'
   THEN
      SELECT sa.seq_x_rule_action_par_ver.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_rule_action_par_ver';

   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_PENALTY_PEND'
   THEN
      SELECT sa.seq_x_prog_pen_pend.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_prog_pen_pend';

   ELSIF UPPER (p_seq_name) = 'X_METRICS_REJECT_ENROLL'
   THEN
      SELECT sa.seq_x_metx_rej_enrl.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_metx_rej_enrl';

   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_DISCOUNT_HIST'
   THEN
      SELECT sa.seq_x_prog_disc_hist.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_prog_disc_hist';

   ELSIF UPPER (p_seq_name) = 'X_BILLING_LOG'
   THEN
      SELECT sa.seq_x_billing_log.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_billing_log';

   ELSIF UPPER (p_seq_name) = 'X_CHARGEBACK_TRANS'
   THEN
      SELECT sa.seq_x_chargeback_trans.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_chargeback_trans';

   ELSIF UPPER (p_seq_name) = 'X_METRICS_REVERSAL'
   THEN
      SELECT sa.seq_x_metrics_reversal.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_metrics_reversal';

   ELSIF UPPER (p_seq_name) = 'X_RULE_VERSION'
   THEN
      SELECT sa.seq_x_rule_version.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_rule_version';

   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_UPGRADE'
   THEN
      SELECT sa.seq_x_program_upgrade.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_program_upgrade';

   ELSIF UPPER (p_seq_name) = 'X_NTFY_FLUP_ACT'
   THEN
      SELECT sa.seq_x_ntfy_flup_act.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_ntfy_flup_act';

   ELSIF UPPER (p_seq_name) = 'X_NTFY_SENT'
   THEN
      SELECT sa.seq_x_ntfy_sent.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_ntfy_sent';

   ELSIF UPPER (p_seq_name) = 'X_NTFY_BATCH'
   THEN
      SELECT sa.seq_x_ntfy_batch.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_ntfy_batch';

   ELSIF UPPER (p_seq_name) = 'X_PROGRAM_BATCH'
   THEN
      SELECT sa.seq_x_program_batch.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_program_batch';

   ELSIF UPPER (p_seq_name) = 'X_LIFELINE_ACTION_TRANS'
   THEN
      SELECT sa.seq_x_ll_action_trans.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_x_ll_action_trans';

   ELSIF UPPER (p_seq_name) = 'X_NTFY_BOUNCE_EMAIL_TRANS'
   THEN
      SELECT sa.seq_ntfy_bounce_email.NEXTVAL
        INTO v_next_value
        FROM DUAL;
        seq_name:='seq_ntfy_bounce_email';

   END IF;
--
                        -- This condition should not occur.
END;
/