CREATE OR REPLACE PACKAGE sa.safelink_validations_pkg IS
/****************************************************************************
 ****************************************************************************
 * $Revision: 1.60 $
 * $Author: oimana $
 * $Date: 2018/04/12 18:17:24 $
 * $Log: SAFELINK_VALIDATIONS_PKG.sql,v $
 * Revision 1.60  2018/04/12 18:17:24  oimana
 * CR56887 - Package Specs
 *
 *
 *****************************************************************************
 *****************************************************************************/
-- CR29866 - Package created date: 10/09/2014
--
--
 TYPE populate_sp_dtl_record IS RECORD (part_number          sa.table_part_num.part_number%TYPE,
                                        pn_desc              sa.table_part_num.DESCRIPTION%TYPE,
                                        x_retail_price       sa.table_x_pricing.x_retail_price%TYPE,
                                        sp_objid             sa.x_service_plan.objid%TYPE,
                                        plan_type            sa.x_serviceplanfeaturevalue_def.value_name%TYPE, --Added for CR47024 - SL Unlimited
                                        service_plan_group   sa.x_serviceplanfeaturevalue_def.value_name%TYPE, --Added for CR47024 - SL Unlimited
                                        mkt_name             sa.x_service_plan.mkt_name%TYPE,
                                        sp_desc              sa.x_service_plan.DESCRIPTION%TYPE,
                                        customer_price       sa.x_service_plan.customer_price%TYPE,
                                        ivr_plan_id          sa.x_service_plan.ivr_plan_id%TYPE,
                                        webcsr_display_name  sa.x_service_plan.webcsr_display_name%TYPE,
                                        x_sp2program_param   sa.mtm_sp_x_program_param.x_sp2program_param%TYPE,
                                        x_program_name       sa.x_program_parameters.x_program_name%TYPE,
                                        cycle_start_date     sa.table_site_part.x_expire_dt%TYPE,
                                        cycle_end_date       sa.table_site_part.x_expire_dt%TYPE,
                                        quantity             NUMBER,
                                        coverage_script      sa.x_serviceplanfeaturevalue_def.value_name%TYPE,
                                        short_script         sa.x_serviceplanfeaturevalue_def.value_name%TYPE,
                                        trans_script         sa.x_serviceplanfeaturevalue_def.value_name%TYPE,
                                        script_type          sa.x_serviceplanfeaturevalue_def.value_name%TYPE,
                                        sl_program_flag      VARCHAR2(10),
                                        enroll_state         sa.table_state_prov.full_name%TYPE);
--
--
 PROCEDURE job_log (ip_job_name          IN  x_job_master.x_job_name%TYPE,
                    ip_job_desc          IN  x_job_master.x_job_desc%TYPE,
                    ip_job_class         IN  x_job_master.x_job_class%TYPE,
                    ip_job_sourcesystem  IN  x_job_master.x_job_sourcesystem%TYPE,
                    ip_status            IN  x_job_run_details.x_status%TYPE,
                    ip_job_run_mode      IN  x_job_run_details.x_job_run_mode%TYPE,
                    ip_seq_name          IN  VARCHAR2,
                    op_job_run_objid     OUT x_job_run_details.objid%TYPE);
--
--
 PROCEDURE job_log (ip_status        IN x_job_run_details.x_status%TYPE,
                    ip_job_run_objid IN x_job_run_details.objid%TYPE);
--
--
 PROCEDURE p_validate_min (ip_key            IN  VARCHAR2,
                           ip_value          IN  VARCHAR2,
                           ip_source_system  IN  VARCHAR2,
                           op_actiontype     OUT VARCHAR2,
                           op_enroll_zip     OUT VARCHAR2,
                           op_web_user_id    OUT NUMBER,
                           op_lid            OUT NUMBER,
                           op_esn            OUT VARCHAR2,
                           op_contact_objid  OUT NUMBER,
                           op_refcursor      OUT SYS_REFCURSOR,
                           op_err_num        OUT NUMBER,
                           op_err_string     OUT VARCHAR2);
--
--
 PROCEDURE p_redemption_card_actions (ip_esn               IN  table_part_inst.part_serial_no%TYPE,
                                      ip_action_type       IN  VARCHAR2,
                                      ip_source_system     IN  x_program_purch_hdr.x_rqst_source%TYPE,
                                      ip_create_call_trans IN  VARCHAR2,
                                      ip_call_trans_objid  IN  table_x_call_trans.objid%TYPE,
                                      ip_merchant_ref_no   IN  x_program_purch_hdr.x_merchant_ref_number%TYPE,
                                      op_soft_pin          OUT table_x_cc_red_inv.x_red_card_number%TYPE,
                                      op_smp               OUT table_x_cc_red_inv.x_smp%TYPE,
                                      op_err_num           OUT NUMBER,
                                      op_err_string        OUT VARCHAR2);
--
--
 PROCEDURE p_update_purchase_details (ip_merch_ref_number  IN  table_x_purch_hdr.x_merchant_ref_number%TYPE,
                                      ip_lid               IN  x_sl_subs.lid%TYPE,
                                      ip_partnum           IN  VARCHAR2 DEFAULT NULL,
                                      op_err_num           OUT NUMBER,
                                      op_err_string        OUT VARCHAR2);
--
--
 PROCEDURE p_move_sl_cycle_date (ip_enrolled_objid  IN  x_program_enrolled.objid%TYPE,
                                 ip_esn             IN  x_program_enrolled.x_esn%TYPE,
                                 ip_cycle_days      IN  NUMBER,
                                 op_err_num         OUT NUMBER,
                                 op_err_string      OUT VARCHAR2);
--
--
 PROCEDURE p_safelink_data_feed (op_err_num    OUT NUMBER,
                                 op_err_string OUT VARCHAR2);
--
--
 PROCEDURE p_benefit_receipt_rec_insert (ip_process_date IN  VARCHAR2,
                                         op_err_num      OUT NUMBER,
                                         op_err_string   OUT VARCHAR2);
--
--
 PROCEDURE p_get_part_num_by_zip_sl (ip_zip             IN table_x_zip_code.x_zip%TYPE,
                                     ip_program_name    IN x_program_parameters.x_program_name%TYPE,
                                     ip_device_type     IN x_sl_subs.x_device_type%TYPE,
                                     ip_simtype_carrier IN VARCHAR2,
                                     ip_sim_size        IN VARCHAR2,
                                     op_part_number     OUT table_part_num.part_number%TYPE,
                                     op_err_num         OUT NUMBER,
                                     op_err_string      OUT VARCHAR2);
--
--
 PROCEDURE p_get_valid_e911_txn_allowed (ip_lid           IN  x_sl_subs.lid%TYPE,
                                         ip_program_objid IN  x_program_parameters.objid%TYPE,
                                         ip_part_number   IN  table_part_num.part_number%TYPE,
                                         op_txns_allowed  OUT PLS_INTEGER,
                                         op_err_num       OUT NUMBER,
                                         op_err_string    OUT VARCHAR2);
--
--
 PROCEDURE calculate_taxes_prc (ip_zipcode          IN  VARCHAR2,
                                ip_partnumbers      IN  VARCHAR2,
                                ip_esn              IN  VARCHAR2,
                                ip_cc_id            IN  NUMBER,
                                ip_promo            IN  VARCHAR2,
                                ip_brand_name       IN  VARCHAR2,
                                ip_transaction_type IN  VARCHAR2, --'ACTIVATION', 'REACTIVATION','REDEMPTION','PURCHASE', 'PROMOENROLLMENT'
                                ip_sourcesystem     IN  VARCHAR2,
                                op_combstaxamt      OUT NUMBER,
                                op_e911amt          OUT NUMBER,
                                op_usfamt           OUT NUMBER,
                                op_rcrfamt          OUT NUMBER,
                                op_subtotalamount   OUT NUMBER,
                                op_totaltaxamount   OUT NUMBER,
                                op_totalcharges     OUT NUMBER,
                                op_combstaxrate     OUT NUMBER,
                                op_e911rate         OUT NUMBER,
                                op_usfrate          OUT NUMBER,
                                op_rcrfrate         OUT NUMBER,
                                op_result           OUT NUMBER,
                                op_msg              OUT VARCHAR2);
--
--
 PROCEDURE p_get_certif_model_details (ip_zip_cde        IN  table_x_zip_code.x_zip%TYPE,
                                       ip_device_type    IN  x_sl_subs.x_device_type%TYPE,
                                       ip_carrier        IN  x_sl_subs_dtl.x_byop_carrier%TYPE,
                                       ip_sim_type       IN  x_sl_subs_dtl.x_byop_sim%TYPE,
                                       op_is_certified   OUT VARCHAR2,
                                       op_model_number   OUT table_part_class.x_model_number%TYPE,
                                       op_err_num        OUT NUMBER,
                                       op_err_string     OUT VARCHAR2);
--
--
--CR47024 SL Unlimited Changes
 FUNCTION is_srvc_plan_allowed (in_plan_partnum_objid  IN table_part_num.objid%TYPE,
                                in_esn                 IN table_part_inst.part_serial_no%TYPE)
 RETURN NUMBER;
--
--
 FUNCTION is_balance_case_created (in_esn IN VARCHAR2)
 RETURN VARCHAR2;
--
--
 FUNCTION is_balance_storage_eligible (in_esn IN VARCHAR2)
 RETURN VARCHAR2;
--
--
 FUNCTION f_get_paidunits_ppe (in_esn IN VARCHAR2)
 RETURN NUMBER;
--
--
 PROCEDURE p_insert_paid_balance (in_caseid         IN  VARCHAR2,
                                  in_voice_units    IN  VARCHAR2,
                                  in_sms_units      IN  VARCHAR2,
                                  in_data_units     IN  VARCHAR2,
                                  in_balance_source IN  VARCHAR2,
                                  op_err_num        OUT NUMBER,
                                  op_err_string     OUT VARCHAR2);
--
--
 PROCEDURE p_retrieve_paid_balance (in_esn                 IN  VARCHAR2,
                                    in_balance_replay_date IN  DATE,
                                    io_caseid              IN  OUT VARCHAR2,
                                    o_voice_units          OUT VARCHAR2,
                                    o_sms_units            OUT VARCHAR2,
                                    o_data_units           OUT VARCHAR2,
                                    o_balance_trans_id     OUT VARCHAR2,
                                    o_replacement_case     OUT VARCHAR2,
                                    o_replace_days         OUT NUMBER,
                                    op_err_num             OUT NUMBER,
                                    op_err_string          OUT VARCHAR2);
--
--
 PROCEDURE p_transfer_paid_balance_case (in_fromesn     IN  VARCHAR2,
                                         in_toesn       IN  VARCHAR2,
                                         op_err_num     OUT NUMBER,
                                         op_err_string  OUT VARCHAR2);
--
--
-- CR48643 adding overloaded p_validate_min
 PROCEDURE p_validate_min_sp (ip_key                 IN  VARCHAR2,
                              ip_value               IN  VARCHAR2,
                              ip_source_system       IN  VARCHAR2,
                              op_actiontype          OUT VARCHAR2,
                              op_enroll_zip          OUT VARCHAR2,
                              op_web_user_id         OUT NUMBER,
                              op_lid                 OUT NUMBER,
                              op_esn                 OUT VARCHAR2,
                              op_contact_objid       OUT NUMBER,
                              op_err_num             OUT NUMBER,
                              op_err_string          OUT VARCHAR2,
                              o_sp_detail_refcursor  OUT SYS_REFCURSOR);
--
--
END safelink_validations_pkg;
/