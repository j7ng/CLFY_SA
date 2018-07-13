CREATE OR REPLACE PACKAGE sa.port_out_pkg AS
--
--
PROCEDURE cancel_request (i_min                    IN  VARCHAR2,
                          i_request_no             IN  VARCHAR2,
                          i_error_code             IN  VARCHAR2,
                          i_error_message          IN  VARCHAR2,
                          i_request_xml            IN  XMLTYPE,
                          o_response               OUT VARCHAR2);
--
--
--CR47275
PROCEDURE create_close_port_out_case (ip_esn                   IN  VARCHAR2 ,
                                      ip_create_task_flag      IN  VARCHAR2 ,
                                      ip_create_case_flag      IN  VARCHAR2 ,
                                      ip_close_case_flag       IN  VARCHAR2 ,
                                      ip_new_service_provider  IN  VARCHAR2 DEFAULT NULL,
                                      op_error_code            OUT VARCHAR2 ,
                                      op_error_msg             OUT VARCHAR2);
--CR47275
--
--
PROCEDURE create_request (i_min                    IN  VARCHAR2,
                          i_case_id_number         IN  VARCHAR2,
                          o_response               OUT VARCHAR2);
--
--
PROCEDURE create_request (i_min                    IN  VARCHAR2,
                          i_request_no             IN  VARCHAR2,
                          i_short_parent_name      IN  VARCHAR2,
                          i_desired_due_date       IN  DATE,
                          i_nnsp                   IN  VARCHAR2,
                          i_directional_indicator  IN  VARCHAR2,
                          i_osp_account_no         IN  VARCHAR2,
                          i_request_xml            IN  XMLTYPE,
                          o_response               OUT VARCHAR2);
--
--
--CR51293
PROCEDURE create_request (i_min                    IN  VARCHAR2,
                          i_request_no             IN  VARCHAR2,
                          i_short_parent_name      IN  VARCHAR2  DEFAULT NULL,  -- CR56056
                          i_desired_due_date       IN  DATE      DEFAULT NULL,  -- CR56056
                          i_nnsp                   IN  VARCHAR2  DEFAULT NULL,  -- CR56056
                          i_directional_indicator  IN  VARCHAR2  DEFAULT NULL,  -- CR56056
                          i_osp_account_no         IN  VARCHAR2,
                          i_request_xml            IN  XMLTYPE,
                          i_portout_carrier        IN  VARCHAR2,
                          o_response               OUT VARCHAR2,
                          o_case_id_number         IN  OUT VARCHAR2,
                          o_sms_send_flag          OUT VARCHAR2,
                          i_x_client_id            IN  VARCHAR2  DEFAULT NULL,  -- CR51128
                          i_carrier                IN  VARCHAR2  DEFAULT NULL,  -- CR56462 Starts
                          i_current_esn            IN  VARCHAR2  DEFAULT NULL,
                          i_account_no             IN  VARCHAR2  DEFAULT NULL,
                          i_password_pin           IN  VARCHAR2  DEFAULT NULL,
                          i_v_key                  IN  VARCHAR2  DEFAULT NULL,
                          i_full_name              IN  VARCHAR2  DEFAULT NULL,
                          i_billing_address        IN  VARCHAR2  DEFAULT NULL,
                          i_last_4_ssn             IN  VARCHAR2  DEFAULT NULL,
                          i_is_account_alpha       IN  VARCHAR2  DEFAULT NULL,
                          i_is_pin_alpha           IN  VARCHAR2  DEFAULT NULL,
                          i_zip                    IN  VARCHAR2  DEFAULT NULL,  -- CR56462 ends
                          o_response_message       OUT VARCHAR2);
--
--
PROCEDURE create_winback_case (i_min                    IN  VARCHAR2,
                               i_request_no             IN  VARCHAR2,
                               i_short_parent_name      IN  VARCHAR2, -- VZW
                               i_desired_due_date       IN  DATE,
                               i_nnsp                   IN  VARCHAR2,
                               i_directional_indicator  IN  VARCHAR2,
                               i_osp_account_no         IN  VARCHAR2,
                               i_portout_carrier        IN  VARCHAR2,
                               i_request_xml            IN  XMLTYPE,
                               o_case_id_number         IN  OUT VARCHAR2,
                               o_sms_send_flag          OUT VARCHAR2,
                               o_proceed_flag           OUT VARCHAR2,
                               o_errcode                OUT NUMBER,
                               o_errmsg                 OUT VARCHAR2);
--
--
PROCEDURE ins_upd_port_out_request (i_min                       IN    VARCHAR2                         ,
                                    i_esn                       IN    VARCHAR2             DEFAULT NULL,
                                    i_request_no                IN    VARCHAR2             DEFAULT NULL,
                                    i_short_parent_name         IN    VARCHAR2             DEFAULT NULL,
                                    i_desired_due_date          IN    DATE                 DEFAULT NULL,
                                    i_nnsp                      IN    VARCHAR2             DEFAULT NULL,
                                    i_directional_indicator     IN    VARCHAR2             DEFAULT NULL,
                                    i_osp_account_no            IN    VARCHAR2             DEFAULT NULL,
                                    i_winback_case_objid        IN    NUMBER               DEFAULT NULL,
                                    i_winback_case_id_number    IN    VARCHAR2             DEFAULT NULL,
                                    i_winback_offer_status      IN    VARCHAR2             DEFAULT NULL,
                                    i_port_out_status           IN    VARCHAR2             DEFAULT NULL,
                                    i_Status_Message            IN    VARCHAR2             DEFAULT NULL,
                                    i_portout_carrier           IN    VARCHAR2             DEFAULT NULL,
                                    i_SP_Objid                  IN    NUMBER               DEFAULT NULL,
                                    i_promo_type                IN    VARCHAR2             DEFAULT NULL,
                                    i_request_xml               IN    XMLTYPE,
                                    o_response                  OUT   VARCHAR2);
--
--
PROCEDURE process_winback_cases (o_errcode OUT NUMBER,
                                 o_errmsg  OUT VARCHAR2);
--
--
PROCEDURE winback_offer_accepted (i_min                    IN  VARCHAR2,
                                  i_case_id_number         IN  VARCHAR2,
                                  o_work_force_pin_pn      OUT VARCHAR2,
                                  o_response               OUT VARCHAR2);
--
--
--CR51293
PROCEDURE get_winback_attributes (i_esn                    IN  VARCHAR2,
                                  i_sp_objid               IN  NUMBER,
                                  o_cos                    OUT VARCHAR2,
                                  o_work_force_pin_pn      OUT VARCHAR2,
                                  o_threshold              OUT NUMBER,
                                  o_addn_threshold         OUT NUMBER,
                                  o_errcode                OUT NUMBER,
                                  o_errmsg                 OUT VARCHAR2);
--
--
PROCEDURE set_portout_winback_promo (i_esn           IN  VARCHAR2,
                                     i_ig_order_type IN  VARCHAR2 DEFAULT NULL,
                                     o_errcode       OUT NUMBER,
                                     o_errmsg        OUT VARCHAR2 );
--
--
END port_out_pkg;
/