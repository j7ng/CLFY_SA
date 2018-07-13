CREATE OR REPLACE PACKAGE sa.rtr_pkg AS
--
  PROCEDURE update_response_code (p_trans_id       IN  NUMBER,
                                  p_response_code  IN  VARCHAR2,
                                  p_error_code     OUT NUMBER,
                                  p_error_message  OUT VARCHAR2);
--
  PROCEDURE validate_red_card (p_x_red_code     IN  VARCHAR2,
                               p_error_code     OUT NUMBER,
                               p_error_message  OUT VARCHAR2);
--
  PROCEDURE validate_dealer (p_partner_id      IN  VARCHAR2,
                             p_sercurity_code  IN  VARCHAR2,
                             p_error_code      OUT NUMBER,
                             p_error_message   OUT VARCHAR2);
--
  PROCEDURE sub_info (p_min              IN  VARCHAR2,
                      p_part_status      OUT VARCHAR2,
                      p_plan_name        OUT VARCHAR2,
                      p_part_number      OUT VARCHAR2,
                      p_description      OUT VARCHAR2,
                      p_customer_price   OUT VARCHAR2,
                      p_future_date      OUT DATE,
                      p_brand            OUT VARCHAR2,
                      p_error_code       OUT NUMBER,
                      p_error_message    OUT VARCHAR2);
--
  PROCEDURE sub_info2 (p_min               IN  VARCHAR2,
                       p_card_part_number  IN  VARCHAR2,
                       p_part_status       OUT VARCHAR2,
                       p_plan_name         OUT VARCHAR2,
                       p_part_number       OUT VARCHAR2,
                       p_description       OUT VARCHAR2,
                       p_customer_price    OUT VARCHAR2,
                       p_future_date       OUT DATE,
                       p_brand             OUT VARCHAR2,
                       p_error_code        OUT NUMBER,
                       p_error_message     OUT VARCHAR2);
--
  PROCEDURE sub_info3 (p_min               IN  VARCHAR2,
                       p_esn               IN  VARCHAR2,
                       p_zip               IN  VARCHAR2,
                       p_card_part_number  IN  VARCHAR2,
                       p_part_status       OUT VARCHAR2,
                       p_plan_name         OUT VARCHAR2,
                       p_part_number       OUT VARCHAR2,
                       p_description       OUT VARCHAR2,
                       p_customer_price    OUT VARCHAR2,
                       p_future_date       OUT DATE,
                       p_brand             OUT VARCHAR2,
                       p_error_code        OUT NUMBER,
                       p_error_message     OUT VARCHAR2);
--
  PROCEDURE up_plan (p_min                     IN  VARCHAR2,
                     p_sourcesystem            IN  VARCHAR2,
                     p_rtr_vendor_name         IN  VARCHAR2,
                     p_rtr_merch_store_num     IN  VARCHAR2,
                     p_rtr_remote_trans_id     IN  VARCHAR2,
                     p_consumer                IN  VARCHAR2 DEFAULT NULL,--CR42260
                     p_trans_id                OUT NUMBER,
                     p_error_code              OUT NUMBER,
                     p_error_message           OUT VARCHAR2);
--
  PROCEDURE up_plan2 (p_min                    IN VARCHAR2,
                      p_sourcesystem           IN VARCHAR2,
                      p_rtr_vendor_name        IN VARCHAR2,
                      p_rtr_merch_store_num    IN VARCHAR2,
                      p_rtr_remote_trans_id    IN VARCHAR2,
                      p_card_part_number       IN VARCHAR2,
                      p_rtr_merch_reg_num      IN VARCHAR2,
                      p_rtr_merch_store_name   IN VARCHAR2,
                      p_dummy1                 IN VARCHAR2,
                      p_consumer               IN VARCHAR2 DEFAULT NULL,--CR42260
                      p_trans_id               OUT NUMBER,
                      p_new_card_action        OUT VARCHAR2, --CR47757
                      p_error_code             OUT NUMBER,
                      p_error_message          OUT VARCHAR2);
--
  PROCEDURE up_plan3 (p_min                     IN  VARCHAR2,
                      p_esn                     IN  VARCHAR2,
                      p_zip                     IN  VARCHAR2,
                      p_sourcesystem            IN  VARCHAR2,
                      p_rtr_merchant_id         IN  VARCHAR2,
                      p_rtr_merchant_location   IN  VARCHAR2,
                      p_rtr_remote_trans_id     IN  VARCHAR2,
                      p_card_part_number        IN  VARCHAR2,
                      p_rtr_reg_no              IN  VARCHAR2,
                      p_rtr_merchant_store_name IN  VARCHAR2,
                      p_rtr_merchant_store_num  IN  VARCHAR2,
                      p_consumer                IN  VARCHAR2 DEFAULT NULL,--CR42260
                      p_trans_id                OUT NUMBER,
                      p_new_card_action         OUT VARCHAR2, --CR47757
                      p_red_code                OUT VARCHAR2,
                      p_error_code              OUT NUMBER,
                      p_error_message           OUT VARCHAR2);

  PROCEDURE up_plan_cancel (p_rtr_vendor_name              IN  VARCHAR2,
                            p_add_rtr_remote_trans_id      IN  VARCHAR2,
                            p_cancel_rtr_remote_trans_id   IN  VARCHAR2,
                            p_trans_id                     OUT NUMBER,
                            p_error_code                   OUT NUMBER,
                            p_error_message                OUT VARCHAR2);
--
  PROCEDURE up_plan_cancel2 (p_rtr_vendor_name             IN  VARCHAR2,
                             p_rtr_merch_store_num         IN  VARCHAR2,
                             p_rtr_merch_reg_num           IN  VARCHAR2,
                             p_rtr_merch_store_name        IN  VARCHAR2,
                             p_add_rtr_remote_trans_id     IN  VARCHAR2,
                             p_cancel_rtr_remote_trans_id  IN  VARCHAR2,
                             p_trans_id                    OUT NUMBER,
                             p_error_code                  OUT NUMBER,
                             p_error_message               OUT VARCHAR2);
--
  PROCEDURE up_plan_status (p_rtr_vendor_name       IN  VARCHAR2,
                            p_rtr_remote_trans_id   IN  VARCHAR2,
                            p_trans_id              OUT NUMBER,
                            p_error_code            OUT NUMBER,
                            p_error_message         OUT VARCHAR2);
--
  PROCEDURE act_extra_info (p_trans_id             IN  NUMBER,
                            p_esn                  OUT VARCHAR2,
                            p_zip                  OUT VARCHAR2,
                            p_pin                  OUT VARCHAR2,
                            p_iccid                OUT VARCHAR2,
                            p_error_code           OUT NUMBER,
                            p_error_message        OUT VARCHAR2);
--
  PROCEDURE tf_redem_info (p_trans_id             IN  NUMBER,
                           p_esn                  OUT VARCHAR2,
                           p_zip                  OUT VARCHAR2,
                           p_pin                  OUT VARCHAR2,
                           p_iccid                OUT VARCHAR2,
                           p_ppe_flag             OUT NUMBER,
                           p_switch_base          OUT NUMBER,
                           p_contact_objid        OUT NUMBER,
                           p_technology           OUT VARCHAR2,
                           p_carrier_objid        OUT NUMBER,
                           p_error_code           OUT NUMBER,
                           p_error_message        OUT VARCHAR2);
--
  PROCEDURE cancel_reactivation (p_rtr_vendor_name            IN  VARCHAR2,
                                 p_add_rtr_remote_trans_id    IN  VARCHAR2,
                                 p_cancel_rtr_remote_trans_id IN  VARCHAR2,
                                 p_error_code                 OUT NUMBER,
                                 p_error_message              OUT VARCHAR2);
--
  PROCEDURE cancel_reactivation (p_rtr_vendor_name            IN  VARCHAR2,
                                 p_add_rtr_remote_trans_id    IN  VARCHAR2,
                                 p_cancel_rtr_remote_trans_id IN  VARCHAR2,
                                 p_error_code                 OUT NUMBER,
                                 p_error_message              OUT VARCHAR2,
                                 p_trans_id                   OUT VARCHAR2);
--
  PROCEDURE p_get_source_dest_sp_group (p_esn           IN  VARCHAR2,
                                        p_partnumber    IN  VARCHAR2,
                                        op_src_sp_grp   OUT VARCHAR2,
                                        op_dest_sp_grp  OUT VARCHAR2,
                                        op_err_num      OUT NUMBER,
                                        op_err_msg      OUT VARCHAR2);
--
  FUNCTION is_safelink (p_esn IN VARCHAR2,
                        p_min IN VARCHAR2)
  RETURN VARCHAR2;
--
  PROCEDURE get_add_res_cnt (p_esn     IN  VARCHAR2,
                             p_red_cnt OUT NUMBER,
                             p_res_cnt OUT NUMBER);
--
END rtr_pkg;
/