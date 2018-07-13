CREATE OR REPLACE PACKAGE sa.data_club_pkg AS
--------------------------------------------------------------------------------------------
--$RCSfile: data_club_pkg.sql,v $
--$Revision: 1.16 $
--$Author: rvegi $
--$Date: 2018/04/20 13:24:32 $
--$ $Log: data_club_pkg.sql,v $
--$ Revision 1.16  2018/04/20 13:24:32  rvegi
--$ CR57400
--$
--$ Revision 1.15  2018/04/20 13:19:57  rvegi
--$ CR57400
--$
--$ Revision 1.14  2018/01/23 16:04:24  oimana
--$ CR52532 - Package Specs
--$
--$ Revision 1.13  2016/12/28 20:23:58  akhan
--$ bug fixes
--$
--------------------------------------------------------------------------------------------
--
--
PROCEDURE get_base_pin (i_esn                  IN  VARCHAR2,  -- ESN
                        i_service_plan_group   IN  VARCHAR2,  -- Pass "BASE" for Base plan, "DATA_ONLY" for data plan
                        o_pin                  OUT VARCHAR2,  -- This is PIN
                        o_pin_plan_id          OUT NUMBER  ,  -- Service plan for the PIN
                        o_err_code             OUT NUMBER  ,  -- If o_pin is null, check this for details of error
                        o_err_msg              OUT VARCHAR2); -- If o_pin is null, check this for details of error
--
--
PROCEDURE get_base_pin (i_esn                IN  VARCHAR2,
                        o_pin                OUT VARCHAR2,
                        o_part_inst_status   OUT VARCHAR2,
                        o_err_code           OUT NUMBER  ,   -- If o_pin is null, check this for details of error
                        o_err_msg            OUT VARCHAR2);  -- If o_pin is null, check this for details of error
--
--
PROCEDURE create_group (i_esn                 IN  VARCHAR2,  -- ESN
                        i_pin                 IN  VARCHAR2,  -- This is PIN
                        i_web_user_objid      IN  NUMBER  ,  -- required for creating group
                        o_service_plan_group  OUT VARCHAR2,  -- "BASE" for Base plan, "DATA_ONLY" for data plan
                        o_account_group_id    OUT NUMBER  ,  -- GROUP ID
                        o_err_code            OUT NUMBER  ,  -- Standard error parameters, if o_account_group_id is null, check this for details of error
                        o_err_msg             OUT VARCHAR2); -- Standard error parameters, if o_account_group_id is null, check this for details of error
--
--
PROCEDURE check_autorefill_eligibility (i_esn              IN  VARCHAR2,
                                        o_eligible_flag    OUT VARCHAR2,
                                        o_err_code         OUT NUMBER  ,
                                        o_err_msg          OUT VARCHAR2,
                                        o_pgm_enrl_objid   OUT NUMBER);
--
--
PROCEDURE increment_autorefill_counter (i_esn       IN  VARCHAR2,
                                        o_err_code  OUT NUMBER  ,
                                        o_err_msg   OUT VARCHAR2);
--
--
PROCEDURE handle_throttling_event (i_esn               IN  VARCHAR2,
                                   i_throttle_params   IN  VARCHAR2,
                                   o_throttle_flag     OUT VARCHAR2);
--
--
PROCEDURE get_payment_source_information (i_bal_tran_objid      IN  NUMBER,
                                          o_x_merchant_id       OUT VARCHAR2,
                                          o_x_merchant_ref_id   OUT VARCHAR2,
                                          o_billing_zipcode     OUT VARCHAR2,
                                          o_cc_objid            OUT NUMBER,
                                          o_amount              OUT NUMBER,
                                          o_error_msg           OUT VARCHAR2);
--
--
PROCEDURE insert_x_program_gencode (i_esn                      IN  VARCHAR2,
                                    i_insert_date              IN  DATE    ,
                                    i_post_date                IN  DATE    ,
                                    i_status                   IN  VARCHAR2,
                                    i_error_num                IN  VARCHAR2,
                                    i_error_string             IN  VARCHAR2,
                                    i_gencode2prog_purch_hdr   IN  NUMBER  ,
                                    i_gencode2call_trans       IN  NUMBER  ,
                                    i_x_ota_trans_id           IN  NUMBER  ,
                                    i_x_sweep_and_add_flag     IN  NUMBER  ,
                                    i_x_priority               IN  NUMBER  ,
                                    i_sw_flag                  IN  VARCHAR2,
                                    i_smp                      IN  VARCHAR2,
                                    o_x_pgm_gencode_objid      OUT NUMBER  ,
                                    o_err_code                 OUT NUMBER  ,
                                    o_err_msg                  OUT VARCHAR2);
--
--
PROCEDURE update_x_program_gencode (i_x_pgm_gencode_objid  IN  NUMBER,
                                    i_smp                  IN  NUMBER,
                                    i_gencode2call_trans   IN  NUMBER,
                                    o_err_code             OUT NUMBER,
                                    o_err_msg              OUT VARCHAR2);
--
--
FUNCTION get_batch_mode_config_flag (i_webuser_objid   IN NUMBER,
                                     i_request_type    IN VARCHAR2)
RETURN VARCHAR2;
--
--
PROCEDURE update_billing_cycle (i_esn               IN  VARCHAR2,
                                i_pgm_parameter_id  IN  NUMBER,
                                o_err_code          OUT NUMBER,
                                o_err_msg           OUT VARCHAR2);
--
--
PROCEDURE upd_lowbalance_dataclub_pr (i_esn IN VARCHAR2);
--
--
PROCEDURE batch_addon_recon (i_prog_purch_hdr_id       IN NUMBER,
                             i_prog_purch_hdr_status   IN VARCHAR2,
                             i_esn                     IN VARCHAR2 DEFAULT NULL);
--
--
PROCEDURE update_auto_refill_counter (i_esn IN VARCHAR2);
--
--
PROCEDURE update_throttling_transaction (i_esn               IN VARCHAR2,
                                         i_bal_trans_objid   IN NUMBER);

FUNCTION  b2b_payment_required_counter (i_esn          IN VARCHAR2) -- CR57400 Added new Function
RETURN NUMBER;
--
--
END data_club_pkg;
/