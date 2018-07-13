CREATE OR REPLACE PACKAGE sa.billing_pkg
AS
--
PROCEDURE rt_recurring_payment (i_enrollment_hdr      IN    rt_rec_pymnt_enrl_hdr_type,--Enrollment Header
                                i_enrollment_dtl      IN    rt_rec_pymnt_enrl_dtl_tab ,--Enrollment Details
                                o_prg_purch_hdr_objid OUT   NUMBER                    ,
								o_rt_rec_pymnt_dtl    OUT   rt_rec_pymnt_dtl_tab      ,
                                o_errnum              OUT   NUMBER                    ,
                                o_errstr              OUT   VARCHAR2
                                );

--To retrieve the next billing cycle date
FUNCTION get_next_cycle_date(i_prog_param_objid   IN NUMBER,
                             i_current_cycle_date IN DATE)
RETURN DATE;

--To retrieve the merchant id
FUNCTION get_merchant_id(i_bus_org             IN VARCHAR2,
                         i_pgm_enroll_objid    IN NUMBER,
                         i_pgm_parameter_objid IN NUMBER,
                         i_multimerchant_flag  IN BOOLEAN)
RETURN VARCHAR2;

--To retrieve payment type
PROCEDURE get_payment_type(i_pymnt_src_objid   IN  NUMBER   ,
                           o_pymnt_src_rec     OUT x_payment_source%ROWTYPE ,
                           o_errnum            OUT NUMBER   ,
                           o_errstr            OUT VARCHAR2
                           );

-- To retrieve credit card information for CC transactions
PROCEDURE get_credit_card_info(i_credit_card_objid IN   NUMBER                      ,
                               o_credit_card_rec   OUT  table_x_credit_card%ROWTYPE ,
                               o_errnum            OUT  NUMBER                      ,
                               o_errstr            OUT  VARCHAR2
                               );

-- To retrieve bank information for ACH transactions
PROCEDURE get_bank_info(i_bank_account_objid  IN   NUMBER                      ,
                        o_bank_acount_rec     OUT table_x_bank_account%ROWTYPE ,
                        o_errnum              OUT  NUMBER                      ,
                        o_errstr              OUT  VARCHAR2
                        );

-- To retrieve address information
PROCEDURE get_address_info(i_address_objid  IN   NUMBER                      ,
                           o_address_rec    OUT table_address%ROWTYPE        ,
                           o_errnum         OUT  NUMBER                      ,
                           o_errstr         OUT  VARCHAR2
                           );

--To insert record into program purch header table
PROCEDURE insert_prg_purch_hdr(i_objid                 IN     NUMBER   ,
                               i_rqst_source           IN     VARCHAR2 ,
                               i_rqst_type             IN     VARCHAR2 ,
							   i_credit_card_info      IN     table_x_credit_card%ROWTYPE,
							   i_bank_info             IN     table_x_bank_account%ROWTYPE,
                               i_rqst_date             IN     DATE     ,
                               i_ics_applications      IN     VARCHAR2 ,
                               i_merchant_id           IN     VARCHAR2 ,
                               i_merchant_ref_number   IN     VARCHAR2 ,
                               i_offer_num             IN     VARCHAR2 ,
                               i_quantity              IN     NUMBER   ,
                               i_merchant_product_sku  IN     VARCHAR2 ,
                               i_payment_line2program  IN     NUMBER   ,
                               i_product_code          IN     VARCHAR2 ,
                               i_ignore_avs            IN     VARCHAR2 ,
                               i_user_po               IN     VARCHAR2 ,
                               i_avs                   IN     VARCHAR2 ,
                               i_disable_avs           IN     VARCHAR2 ,
                               i_customer_hostname     IN     VARCHAR2 ,
                               i_customer_ipaddress    IN    VARCHAR2  ,
                               i_auth_request_id       IN     VARCHAR2 ,
                               i_auth_code             IN    VARCHAR2  ,
                               i_auth_type             IN     VARCHAR2 ,
                               i_ics_rcode             IN     VARCHAR2 ,
                               i_ics_rflag             IN     VARCHAR2 ,
                               i_ics_rmsg              IN     VARCHAR2 ,
                               i_request_id            IN     VARCHAR2 ,
                               i_auth_avs              IN     VARCHAR2 ,
                               i_auth_response         IN     VARCHAR2 ,
                               i_auth_time             IN     VARCHAR2 ,
                               i_auth_rcode            IN     NUMBER   ,
                               i_auth_rflag            IN     VARCHAR2 ,
                               i_auth_rmsg             IN     VARCHAR2 ,
                               i_bill_request_time     IN     VARCHAR2 ,
                               i_bill_rcode            IN     NUMBER   ,
                               i_bill_rflag            IN     VARCHAR2 ,
                               i_bill_rmsg             IN     VARCHAR2 ,
                               i_bill_trans_ref_no     IN     VARCHAR2 ,
                               i_status                IN     VARCHAR2 ,
                               i_bill_address1         IN     VARCHAR2 ,
                               i_bill_address2         IN     VARCHAR2 ,
                               i_bill_city             IN     VARCHAR2 ,
                               i_bill_state            IN     VARCHAR2 ,
                               i_bill_zip              IN     VARCHAR2 ,
                               i_bill_country          IN     VARCHAR2 ,
                               i_esn                   IN     VARCHAR2 ,
                               i_amount                IN     NUMBER   ,
                               i_tax_amount            IN     NUMBER   ,
                               i_auth_amount           IN     NUMBER   ,
                               i_bill_amount           IN     NUMBER   ,
                               i_user                  IN     VARCHAR2 ,
                               i_credit_code           IN     VARCHAR2 ,
                               i_purch_hdr2user        IN     NUMBER   ,
                               i_purch_hdr2esn         IN     NUMBER   ,
                               i_purch_hdr2rmsg_codes  IN     NUMBER   ,
                               i_purch_hdr2cr_purch    IN     NUMBER   ,
                               i_prog_hdr2x_pymt_src   IN     NUMBER   ,
                               i_prog_hdr2web_user     IN     NUMBER   ,
                               i_prog_hdr2prog_batch   IN     NUMBER   ,
                               i_payment_type          IN     VARCHAR2 ,
                               i_e911_tax_amount       IN     NUMBER   ,
                               i_usf_tax_amount        IN     NUMBER   ,
                               i_rcrf_tax_amount       IN     NUMBER   ,
                               i_process_date          IN     DATE     ,
                               i_discount_amount       IN     NUMBER   ,
                               i_priority              IN     NUMBER   ,
                               o_errnum                OUT    NUMBER   ,
                               o_errstr                OUT    VARCHAR2
                               );

--To insert record into program purch detail table
PROCEDURE insert_prg_purch_dtl(i_objid                        IN   NUMBER   ,
                               i_esn                          IN   VARCHAR2 ,
                               i_amount                       IN   NUMBER   ,
                               i_charge_desc                  IN   VARCHAR2 ,
                               i_cycle_start_date             IN   DATE     ,
                               i_cycle_end_date               IN   DATE     ,
                               i_pgm_purch_dtl2pgm_enrolled   IN   NUMBER   ,
                               i_pgm_purch_dtl2prog_hdr       IN   NUMBER   ,
                               i_pgm_purch_dtl2penal_pend     IN   NUMBER   ,
                               i_tax_amount                   IN   NUMBER   ,
                               i_e911_tax_amount              IN   NUMBER   ,
                               i_usf_tax_amount               IN   NUMBER   ,
                               i_rcrf_tax_amount              IN   NUMBER   ,
                               i_priority                     IN   NUMBER   ,
                               o_errnum                       OUT  NUMBER   ,
                               o_errstr                       OUT  VARCHAR2
                               );

--To insert record into cc_prg_trans table for credit card transaction
PROCEDURE insert_cc_prg_trans(i_objid                     IN   NUMBER   ,
                              i_ignore_bad_cv             IN   VARCHAR2 ,
                              i_ignore_avs                IN   VARCHAR2 ,
                              i_avs                       IN   VARCHAR2 ,
                              i_disable_avs               IN   VARCHAR2 ,
                              i_auth_avs                  IN   VARCHAR2 ,
                              i_auth_cv_result            IN   VARCHAR2 ,
                              i_score_factors             IN   VARCHAR2 ,
                              i_score_host_severity       IN   VARCHAR2 ,
                              i_score_rcode               IN   NUMBER   ,
                              i_score_rflag               IN   VARCHAR2 ,
                              i_score_rmsg                IN   VARCHAR2 ,
                              i_score_result              IN   VARCHAR2 ,
                              i_score_time_local          IN   VARCHAR2 ,
                              i_customer_cc_number        IN   VARCHAR2 ,
                              i_customer_cc_expmo         IN   VARCHAR2 ,
                              i_customer_cc_expyr         IN   VARCHAR2 ,
                              i_customer_cvv_num          IN   VARCHAR2 ,
                              i_cc_lastfour               IN   VARCHAR2 ,
                              i_cc_trans2x_credit_card    IN   NUMBER   ,
                              i_cc_trans2x_purch_hdr      IN   NUMBER   ,
                              o_errnum                    OUT  NUMBER   ,
                              o_errstr                    OUT  VARCHAR2
                              );

--To insert record into ach_prg_trans table for ACH transaction
PROCEDURE insert_ach_prg_trans(i_objid                    IN    NUMBER   ,
                               i_bank_num                 IN    VARCHAR2 ,
                               i_ecp_account_no           IN    VARCHAR2 ,
                               i_ecp_account_type         IN    VARCHAR2 ,
                               i_ecp_rdfi                 IN    VARCHAR2 ,
                               i_ecp_settlement_method    IN    VARCHAR2 ,
                               i_ecp_payment_mode         IN    VARCHAR2 ,
                               i_ecp_debit_request_id     IN    VARCHAR2 ,
                               i_ecp_verfication_level    IN    VARCHAR2 ,
                               i_ecp_ref_number           IN    VARCHAR2 ,
                               i_ecp_debit_ref_number     IN    VARCHAR2 ,
                               i_ecp_debit_avs            IN    VARCHAR2 ,
                               i_ecp_debit_avs_raw        IN    VARCHAR2 ,
                               i_ecp_rcode                IN    VARCHAR2 ,
                               i_ecp_trans_id             IN    VARCHAR2 ,
                               i_ecp_ref_no               IN    VARCHAR2 ,
                               i_ecp_result_code          IN    VARCHAR2 ,
                               i_ecp_rflag                IN    VARCHAR2 ,
                               i_ecp_rmsg                 IN    VARCHAR2 ,
                               i_ecp_credit_ref_number    IN    VARCHAR2 ,
                               i_ecp_credit_trans_id      IN    VARCHAR2 ,
                               i_decline_avs_flags        IN    VARCHAR2 ,
                               i_ach_trans2x_purch_hdr    IN    NUMBER   ,
                               i_ach_trans2x_bank_account IN    NUMBER   ,
                               i_ach_trans2pgm_enrolled   IN    NUMBER   ,
                               o_errnum                   OUT   NUMBER   ,
                               o_errstr                   OUT   VARCHAR2
                              );

--To insert error logging into x_program_error_log table
PROCEDURE insert_program_error_tab(i_source         IN   VARCHAR2 ,
                                   i_key            IN   VARCHAR2 ,
                                   i_err_num        IN   NUMBER   ,
                                   i_err_msg        IN   VARCHAR2 DEFAULT NULL,
                                   i_desc           IN   VARCHAR2 ,
                                   i_severity       IN   VARCHAR2
                                   ) ;
--
PROCEDURE rt_rec_payment_recon (i_bill_acct_num          IN  VARCHAR2                     ,
                                i_bill_num               IN  VARCHAR2                     ,
                                i_webuser_objid          IN  NUMBER                       ,
                                i_src_system             IN  VARCHAR2                     ,
                                i_pymt_src_objid         IN  NUMBER                       ,
								i_prg_purch_hdr_objid    IN  NUMBER                       ,
								i_rt_rec_pymnt_dtl       IN  rt_rec_pymnt_dtl_type        ,
								i_rt_rec_pymnt_auth_dtl  IN  rt_rec_pymnt_auth_dtl_type   ,
								i_rt_rec_pymnt_bill_dtl	 IN  rt_rec_pymnt_bill_dtl_type   ,
								i_rt_rec_pymnt_ics_dtl	 IN  rt_rec_pymnt_ics_dtl_type    ,
								i_rt_rec_pymnt_resp_dtl  IN  rt_rec_pymnt_resp_dtl_type   ,
								i_rt_rec_pymnt_score_dtl IN  rt_rec_pymnt_score_dtl_type  ,
                                o_errnum                 OUT NUMBER                       ,
                                o_errstr                 OUT VARCHAR2
                                );

PROCEDURE payment_pre_fulfillment (i_esn                   IN  VARCHAR2 ,
                                   i_prog_purch_hdr_objid  IN  NUMBER   ,
                                   i_app_plan_part_num     IN  VARCHAR2 ,
   								   i_source_system         IN  VARCHAR2 ,
								   o_soft_pin              OUT VARCHAR2 ,
								   o_smp_number            OUT VARCHAR2 ,
								   o_esn_status            OUT VARCHAR2 ,
								   o_service_end_date      OUT VARCHAR2 ,
								   o_forecast_date         OUT VARCHAR2 ,
								   o_zipcode               OUT VARCHAR2 ,
								   o_errnum                OUT NUMBER   ,
								   o_errstr                OUT VARCHAR2
                                   );

PROCEDURE  payment_post_fulfillment(i_esn                  IN   VARCHAR2 ,
									i_prog_purch_hdr_objid IN   NUMBER   ,
									i_smp_number           IN   VARCHAR2 ,
									i_call_trans_objid     IN   NUMBER   ,
									i_prog_enrolled_objid  IN   NUMBER   ,
	                                i_fullfillment_type    IN   VARCHAR2 ,
									o_prg_gencode_objid    OUT  NUMBER   ,
									o_errnum               OUT  NUMBER   ,
									o_errstr               OUT  VARCHAR2
								    );

--To insert record into recurring payment staging table
PROCEDURE sp_insert_payment_staging_tbl(i_prog_enrolled_objid    IN  NUMBER                 ,
										i_prog_purch_hdr_objid   IN  NUMBER                 ,
										i_program_gencode_objid  IN  NUMBER                 ,
										i_x_cc_red_inv_objid     IN NUMBER                  ,
										i_rqst_source            IN  VARCHAR2               ,
										i_rqst_type              IN  VARCHAR2               ,
										i_rqst_date              IN  DATE				    ,
										i_flow_id                IN  VARCHAR2               ,
										i_flow                   IN  VARCHAR2               ,
										i_milestone              IN  VARCHAR2               ,
										i_flow_status            IN  VARCHAR2               ,
										i_milestone_status       IN  VARCHAR2               ,
										i_err_code               IN  VARCHAR2               ,
										i_err_msg                IN  VARCHAR2               ,
										o_rec_purch_stage_objid  OUT NUMBER                 ,
										o_errnum                 OUT NUMBER                 ,
										o_errstr                 OUT VARCHAR2
										);

PROCEDURE get_x_cert_info(i_x_bank_cc_account     IN  NUMBER  ,
               		      i_bank_cc_acount_objid  IN NUMBER   ,
						  i_pymnt_x_status        IN VARCHAR2 ,
						  i_bank_cc_acct2address  IN NUMBER   ,
						  i_address_objid         IN NUMBER   ,
						  i_address_country_objid IN NUMBER   ,
                          i_bank_cc2cert          IN NUMBER   ,
						  o_x_cert                OUT VARCHAR2,
						  o_x_key_algo            OUT VARCHAR2,
						  o_x_cc_algo             OUT VARCHAR2,
						  o_country_name          OUT VARCHAR2,
						  o_errnum                OUT NUMBER  ,
						  o_errstr                OUT VARCHAR2
                          );

PROCEDURE sp_update_payment_staging_tbl(i_prog_purch_hdr_objid   IN  NUMBER   ,
										i_flow                   IN  VARCHAR2 ,
										i_milestone              IN  VARCHAR2 ,
										i_flow_status            IN  VARCHAR2 ,
										i_milestone_status       IN  VARCHAR2 ,
										i_errnum                 IN  VARCHAR2 ,
										i_errstr                 IN  VARCHAR2 ,
										o_errnum                 OUT NUMBER   ,
										o_errstr                 OUT VARCHAR2
										);

--To insert into x_program_trans table for successful transaction
PROCEDURE insert_program_trans(i_enrollment_status      IN  VARCHAR2,
							   i_enroll_status_reason   IN  VARCHAR2,
							   i_float_given            IN  NUMBER  ,
							   i_cooling_given          IN  NUMBER  ,
							   i_grace_period_given     IN  NUMBER  ,
							   i_trans_date             IN  DATE    ,
							   i_action_text            IN  VARCHAR2,
							   i_action_type            IN  VARCHAR2,
							   i_reason                 IN  VARCHAR2,
							   i_sourcesystem           IN  VARCHAR2,
							   i_esn                    IN  VARCHAR2,
							   i_exp_date               IN  DATE    ,
							   i_cooling_exp_date       IN  DATE    ,
							   i_update_status          IN  VARCHAR2,
							   i_update_user            IN  VARCHAR2,
							   i_pgm_tran2pgm_enrolled  IN  NUMBER  ,
							   i_pgm_trans2web_user     IN  NUMBER  ,
							   i_pgm_trans2site_part    IN  NUMBER  ,
							   o_errnum                 OUT NUMBER  ,
							   o_errstr                 OUT VARCHAR2
							   );

--To insert into x_billing_log table for successful transaction
PROCEDURE insert_billing_log(i_log_category         IN  VARCHAR2,
							 i_log_title            IN  VARCHAR2,
							 i_log_date             IN  DATE    ,
							 i_details              IN  VARCHAR2,
							 i_additional_details   IN  VARCHAR2,
							 i_program_name         IN  VARCHAR2,
							 i_nickname             IN  VARCHAR2,
							 i_esn                  IN  VARCHAR2,
							 i_originator           IN  VARCHAR2,
							 i_contact_first_name   IN  VARCHAR2,
							 i_contact_last_name    IN  VARCHAR2,
							 i_agent_name           IN  VARCHAR2,
							 i_sourcesystem         IN  VARCHAR2,
							 i_billing_log2web_user IN  NUMBER  ,
							 o_errnum               OUT NUMBER  ,
							 o_errstr               OUT VARCHAR2
							 );
END billing_pkg;
/