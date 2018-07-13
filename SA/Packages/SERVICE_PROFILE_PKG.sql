CREATE OR REPLACE PACKAGE sa.service_profile_pkg AS

 --------------------------------------------------------------------------------------------
 --$RCSfile: SERVICE_PROFILE_PKG.sql,v $
 --$Revision: 1.29 $
 --$Author: skota $
 --$Date: 2017/10/10 16:04:39 $
 --$ $Log: SERVICE_PROFILE_PKG.sql,v $
 --$ Revision 1.29  2017/10/10 16:04:39  skota
 --$ Make changes for the PAGEPLUS addons
 --$
 --$ Revision 1.28  2017/09/19 17:57:14  skota
 --$ Modified the throttle subscriber to log the last redemption date
 --$
 --$ Revision 1.27  2017/04/05 18:14:57  sgangineni
 --$ CR47564 - WFM code merge with Rel_854 changes
 --$
 --$ Revision 1.26  2017/03/15 16:24:09  nsurapaneni
 --$ Signature changes to update_program_parameter procedure.
 --$
 --$ Revision 1.24  2017/02/01 19:59:34  sgangineni
 --$ CR47564 - New procedure update_program_parameter
 --$
  --$ Revision 1.23  2016/10/26 14:45:29  mshah
  --$ CR45325 - Move logging for 3C inquires to OTAPRD
  --$
  --$ Revision 1.22  2016/09/16 22:57:44  vlaad
  --$ Added new procedure for Page Plus
  --$
  --$ Revision 1.21  2016/07/29 18:00:22  vlaad
  --$ Updated signature of insert_pageplus_spr procedure
  --$
  --$ Revision 1.19  2016/06/23 16:15:43  vyegnamurthy
  --$ CR36349
  --$
  --$ Revision 1.18  2016/05/30 10:28:15  sethiraj
  --$ CR37756 - Merged with production copy 05-26-2016
  --$
  --$ Revision 1.16  2016/05/06 21:13:35  jpena
  --$ add low priority updates
  --$
  --$ Revision 1.10  2015/07/28 15:31:52  jpena
  --$ Changes for TMO Flex 80% (CR35365)
  --$
  --$ Revision 1.8  2015/06/03 16:05:10  jpena
  --$ Add mask value input to get_esn_inquiry
  --$
  --$ Revision 1.7  2015/05/26 19:58:16  jpena
  --$ Changes for Super Carrier Release 2
  --$
 --$
 --------------------------------------------------------------------------------------------

-- Create pcrf transaction record
PROCEDURE add_pcrf_transaction ( i_esn                 IN  VARCHAR2 , -- either esn or min is required
                                 i_min                 IN  VARCHAR2 , -- either esn or min is required
                                 i_order_type          IN  VARCHAR2 ,
                                 i_zipcode             IN  VARCHAR2 ,
                                 i_sourcesystem        IN  VARCHAR2 ,
                                 i_pcrf_status_code    IN  VARCHAR2 DEFAULT 'Q',
                                 o_pcrf_transaction_id OUT NUMBER   ,
                                 o_err_code            OUT NUMBER   ,
                                 o_err_msg             OUT VARCHAR2 );

-- Overloaded procedure to add the SPR row based on ESN or MIN with all the proper validations.
PROCEDURE add_subscriber ( i_esn        IN  VARCHAR2,
                           o_err_code   OUT NUMBER,
                           o_err_msg    OUT VARCHAR2);

PROCEDURE add_subscriber_detail ( i_subscriber_spr_objid   IN  NUMBER   ,
                                  i_add_on_offer_id        IN  VARCHAR2   ,
                                  i_add_on_ttl             IN  DATE     ,
                                  i_add_on_redemption_date IN  DATE     ,
                                  i_expired_usage_date     IN  DATE     ,
                                  o_err_code               OUT NUMBER   ,
                                  o_err_msg                OUT VARCHAR2 );

-- Created to expire a subscriber based on ESN with all the proper validations.
PROCEDURE delete_subscriber ( i_esn              IN  VARCHAR2,
                              i_part_inst_status IN  VARCHAR2,
                              o_err_code         OUT NUMBER,
                              o_err_msg          OUT VARCHAR2) ;

-- Created to expire a subscriber based on MIN with all the proper validations.
PROCEDURE delete_subscriber ( i_min              IN  VARCHAR2,
                              i_part_inst_status IN  VARCHAR2,
                              i_src_program_name IN  VARCHAR2 DEFAULT NULL,
                              i_sourcesystem     IN  VARCHAR2 DEFAULT NULL,
                              o_err_code         OUT NUMBER,
                              o_err_msg          OUT VARCHAR2);

-- Added to expire an add on offer in subscriber detail
--PROCEDURE expire_add_on ( i_esn                 IN  VARCHAR2 ,
--                          i_add_on_offer_id     IN  NUMBER   ,
--                          i_add_on_ttl          IN  DATE     ,
--                          o_err_code            OUT NUMBER   ,
--                          o_err_msg             OUT VARCHAR2 );

PROCEDURE update_pcrf ( i_pcrf_transaction_id IN  NUMBER ,
                        i_data_usage          IN  NUMBER ,
                        i_pcrf_status_code    IN  VARCHAR2 ,
                        i_status_message      IN  VARCHAR2 ,
                        o_err_code            OUT NUMBER   ,
                        o_err_msg             OUT VARCHAR2 );

PROCEDURE update_pcrf_low_prty ( i_pcrf_transaction_id IN  NUMBER ,
                                 i_data_usage          IN  NUMBER ,
                                 i_pcrf_status_code    IN  VARCHAR2 ,
                                 i_status_message      IN  VARCHAR2 ,
                                 o_err_code            OUT NUMBER   ,
                                 o_err_msg             OUT VARCHAR2 );

PROCEDURE update_pcrf_offer ( i_pcrf_transaction_id IN  NUMBER ,
                              i_offer_id            IN  VARCHAR2,
                              i_redemption_date     IN  DATE,   -- YYYY-MM-DD HH24:MI:SS
                              i_data_usage          IN  NUMBER ,
                              o_err_code            OUT NUMBER   ,
                              o_err_msg             OUT VARCHAR2 );

PROCEDURE update_pcrf_offer_low_prty ( i_pcrf_transaction_id IN  NUMBER ,
                                       i_offer_id            IN  VARCHAR2,
                                       i_redemption_date     IN  DATE,   -- YYYY-MM-DD HH24:MI:SS
                                       i_data_usage          IN  NUMBER ,
                                       o_err_code            OUT NUMBER   ,
                                       o_err_msg             OUT VARCHAR2 );


FUNCTION get_subscriber_uid ( i_esn IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE get_pcrf_data_usage ( i_pcrf_transaction_id    IN NUMBER  , -- ADD 4 outputs
                                o_data_usage             OUT NUMBER ,
                                o_total_addon_data_usage OUT NUMBER ,
                                o_total_data_usage       OUT NUMBER ,
                                o_hi_speed_data_usage    OUT NUMBER );

-- Added new logic to replace the old W3CI.C3I_INQUIRY_PKG.GET_3CI_ESN_INQUIRY2
PROCEDURE get_esn_inquiry ( i_esn                       IN     VARCHAR2,
                            i_alt_min                   IN     VARCHAR2,
                            i_alt_msid                  IN     VARCHAR2,
                            i_alt_subscriber_uid        IN     VARCHAR2,
                            i_alt_wf_mac_id             IN     VARCHAR2,
                            o_subscriber                OUT    subscriber_type,
                            o_err_code                  OUT    NUMBER  ,
                            o_err_msg                   OUT    VARCHAR2,
                            o_mask_value                IN     VARCHAR2 DEFAULT NULL);

PROCEDURE throttle_subscriber ( i_source                 IN  VARCHAR2, -- PCRF or SYNIVERSE
                                i_min                    IN  VARCHAR2,
                                i_parent_name            IN  VARCHAR2,
                                i_usage_tier_id          IN  NUMBER,
                                i_cos                    IN  VARCHAR2 DEFAULT NULL,
                                i_policy_name            IN  VARCHAR2,
                                i_entitlement            IN  VARCHAR2 DEFAULT 'DEFAULT',
                                i_threshold_reached_time IN  DATE DEFAULT SYSDATE,
                                o_err_code               OUT NUMBER,
                                o_err_msg                OUT VARCHAR2,
                                i_last_redemption_date   IN  DATE DEFAULT NULL);

-- CR37756 PMistry 03/03/2016 Added new procedure for Simple Mobile.
PROCEDURE get_pcrf_data_balance ( i_pcrf_transaction_id    IN NUMBER ,
                                  o_addon_balance          OUT NUMBER ,
                                  o_hi_speed_total_balance OUT NUMBER ,
                                  o_hi_speed_balance       OUT NUMBER ,
                                  o_err_code               OUT NUMBER  ,
                                  o_err_msg                OUT VARCHAR2);
--CR36349  Page plus CR
PROCEDURE INSERT_PAGEPLUS_SPR (   i_pcrf_min                  IN VARCHAR2,
                                  i_pcrf_mdn                  IN VARCHAR2,
                                  i_pcrf_esn                  IN VARCHAR2,
                                  i_pcrf_base_ttl             IN DATE,
                                  i_pp_event_timestamp        IN DATE,
                                  i_future_ttl                IN DATE,
                                  i_brand                     IN VARCHAR2,
                                  i_phone_manufacturer        IN VARCHAR2,
                                  i_phone_model               IN VARCHAR2,
                                  i_content_delivery_format   IN VARCHAR2,
                                  i_denomination              IN VARCHAR2,
                                  i_conversion_factor         IN VARCHAR2,
                                  i_rate_plan                 IN VARCHAR2,
                                  i_service_plan_type         IN VARCHAR2,
                                  i_service_plan_id           IN NUMBER,
                                  i_queued_days               IN NUMBER,
                                  i_language                  IN VARCHAR2,
                                  i_part_inst_status          IN VARCHAR2,
                                  i_subscriber_spr_objid      IN NUMBER,
                                  i_wf_mac_id                 IN VARCHAR2,
                                  i_subscriber_status         IN VARCHAR2,
                                  i_zipcode                   IN VARCHAR2,
                                  i_status                    IN VARCHAR2,
                                  i_technology                IN VARCHAR2,
                                  i_part_class_name           IN VARCHAR2,
                                  i_device_type               IN VARCHAR2,
                                  i_iccid                     IN VARCHAR2,
                                  i_imsi                      IN VARCHAR2,
                                  i_action                    IN VARCHAR2,
                                  o_error_num                 OUT NUMBER,
                                  o_error_text                OUT VARCHAR2,
                                  i_addon_value               in  number  default null
                                  );

procedure process_pageplus_renewal;

--New procedure get_subscriber_info added for CR45325
PROCEDURE get_subscriber_info ( i_esn                 IN     VARCHAR2,
                                i_alt_min             IN     VARCHAR2,
                                i_alt_msid            IN     VARCHAR2,
                                i_alt_subscriber_uid  IN     VARCHAR2,
                                i_alt_wf_mac_id       IN     VARCHAR2,
                                o_subscriber          OUT    subscriber_type,
                                o_err_code            OUT    NUMBER  ,
                                o_err_msg             OUT    VARCHAR2,
                                o_mask_value          IN     VARCHAR2 DEFAULT NULL);

--CR47564 Start
--New procedure to update program parameter id in x_subscription_spr
PROCEDURE update_program_parameter (i_min                IN    VARCHAR2,
                                    i_part_class_name    IN    VARCHAR2,
                                    i_action             IN    VARCHAR2,
                                    o_err_code           OUT   NUMBER,
                                    o_err_msg            OUT   VARCHAR2);
--CR47564 end


END service_profile_pkg;
/