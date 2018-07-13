CREATE OR REPLACE PACKAGE sa.bogo_pkg AS
  --
  PROCEDURE get_bogo_pin_number (i_esn_number        IN  table_part_inst.part_serial_no%TYPE,
                                 i_brand             IN  table_bus_org.org_id%TYPE DEFAULT 'WFM',
                                 o_bogo_pin_number   OUT table_part_inst.x_red_code%TYPE,
                                 o_bogo_part_number  OUT table_part_num.part_number%TYPE,
                                 o_bogo_part_class   OUT table_part_class.name%TYPE,
                                 out_err_num         OUT NUMBER,
                                 out_err_message     OUT VARCHAR2);
  --
  PROCEDURE part_number_sp_id (i_pin_part_number  IN  table_part_num.part_number%TYPE,
                               i_brand            IN  table_bus_org.org_id%TYPE DEFAULT 'WFM',
                               out_sp_id          OUT x_service_plan.objid%TYPE,
                               out_err_num        OUT NUMBER,
                               out_err_message    OUT VARCHAR2);
  --
  PROCEDURE create_bogo_from_ui (i_brand                 IN  x_bogo_configuration.brand%TYPE,
                                 i_bogo_part_number      IN  x_bogo_configuration.bogo_part_number%TYPE,
                                 i_card_pin_part_class   IN  x_bogo_configuration.card_pin_part_class%TYPE,
                                 i_esn_part_class        IN  x_bogo_configuration.esn_part_class%TYPE,
                                 i_esn_part_number       IN  x_bogo_configuration.esn_part_number%TYPE,
                                 i_esn_dealer_id         IN  x_bogo_configuration.esn_dealer_id%TYPE,
                                 i_eligible_service_plan IN  VARCHAR2,
                                 i_channel               IN  x_bogo_configuration.channel%TYPE,
                                 i_action_type           IN  x_bogo_configuration.action_type%TYPE,
                                 i_tsp_id                IN  VARCHAR2 DEFAULT NULL,
                                 i_msg_script_id         IN  x_bogo_configuration.msg_script_id%TYPE,
                                 i_bogo_start_date       IN  x_bogo_configuration.bogo_start_date%TYPE,
                                 i_bogo_end_date         IN  x_bogo_configuration.bogo_end_date%TYPE,
                                 i_bogo_status           IN  x_bogo_configuration.bogo_status%TYPE,
                                 i_user_name             IN  VARCHAR2,
                                 o_bogo_flag             OUT VARCHAR2,
                                 o_response              OUT VARCHAR2);
  --
  PROCEDURE update_bogo_from_ui (i_appl_execution_id     IN  x_bogo_configuration.appl_execution_id%TYPE,
                                 i_bogo_status           IN  x_bogo_configuration.bogo_status%TYPE,
                                 i_bogo_end_date         IN  x_bogo_configuration.bogo_end_date%TYPE,
                                 i_user_name             IN  VARCHAR2,
                                 o_bogo_flag             OUT VARCHAR2,
                                 o_response              OUT VARCHAR2);
  --
  PROCEDURE sp_validate_and_apply_bogo (i_transaction_id  IN  ig_transaction.transaction_id%TYPE,
                                        o_response        OUT VARCHAR2);
  --
  PROCEDURE sp_bogo_eligibility (i_esn                IN  table_part_inst.part_serial_no%TYPE,
                                 i_channel            IN  table_x_call_trans.x_sourcesystem%TYPE,
                                 i_action             IN  x_ig_order_type.x_actual_order_type%TYPE,
                                 i_red_card_pin       IN  table_x_red_card.x_red_code%TYPE DEFAULT NULL,
                                 i_service_plan_objid IN  x_service_plan.objid%TYPE DEFAULT NULL,
                                 o_bogo_eligible      OUT VARCHAR2,
                                 o_response           OUT VARCHAR2);
  --
  PROCEDURE sp_apply_bogo (i_esn                IN  table_part_inst.part_serial_no%TYPE,
                           i_channel            IN  table_x_call_trans.x_sourcesystem%TYPE,
                           i_action             IN  x_ig_order_type.x_actual_order_type%TYPE,
                           i_red_card_pin       IN  table_x_red_card.x_red_code%TYPE DEFAULT NULL,
                           i_service_plan_objid IN  x_service_plan.objid%TYPE DEFAULT NULL,
                           i_call_trans_objid   IN  table_x_call_trans.objid%TYPE DEFAULT NULL,
                           o_bogo_applied       OUT VARCHAR2,
                           o_response           OUT VARCHAR2);
  --
  PROCEDURE sp_redeem_free_pin_no (i_esn                IN  table_part_inst.part_serial_no%TYPE,
                                   i_channel            IN  table_x_call_trans.x_sourcesystem%TYPE,
                                   i_action             IN  x_ig_order_type.x_actual_order_type%TYPE,
                                   i_red_card_pin       IN  table_x_red_card.x_red_code%TYPE DEFAULT NULL,
                                   i_service_plan_objid IN  x_service_plan.objid%TYPE DEFAULT NULL,
                                   i_call_trans_objid   IN  table_x_call_trans.objid%TYPE DEFAULT NULL,
                                   i_tsp_id             IN  x_bogo_configuration.tsp_id%TYPE DEFAULT NULL,
                                   o_bogo_applied       OUT VARCHAR2,
                                   o_free_pin_number    OUT VARCHAR2,
                                   o_response           OUT VARCHAR2);
  --
  PROCEDURE wfm_promo_code_pin (i_min                 IN  table_site_part.x_min%TYPE,
                                i_promo_code          IN  x_wfm_min_promo_code.promo_code%TYPE,
                                i_channel             IN  table_x_call_trans.x_sourcesystem%TYPE,
                                i_brand               IN  table_bus_org.org_id%TYPE DEFAULT 'WFM',
                                o_promo_applied       OUT VARCHAR2,
                                o_promo_response      OUT VARCHAR2,
                                o_promo_pin_number    OUT VARCHAR2);
  --
  PROCEDURE upd_wfm_promo_code (i_promo_code       IN  x_wfm_min_promo_code.promo_code%TYPE,
                                i_min              IN  x_wfm_min_promo_code.promo_min%TYPE DEFAULT NULL,
                                i_pin              IN  x_wfm_min_promo_code.promo_pin%TYPE DEFAULT NULL,
                                i_promo_status     IN  x_wfm_min_promo_code.promo_status%TYPE,
                                o_update_applied   OUT VARCHAR2,
                                o_update_response  OUT VARCHAR2);
  --
END bogo_pkg;
/