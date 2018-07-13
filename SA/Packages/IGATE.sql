CREATE OR REPLACE PACKAGE sa."IGATE" AS
----------------------------------------------------------------------------------------------------
   PROCEDURE sp_close_case (
      p_case_id                 VARCHAR2,
      p_user_login_name         VARCHAR2,
      p_source                  VARCHAR2,
      p_resolution_code         VARCHAR2,
      p_status            OUT   VARCHAR2,
      p_msg OUT VARCHAR2 );
----------------------------------------------------------------------------------------------------
   FUNCTION get_hex(
       p_esn IN VARCHAR2)
       RETURN VARCHAR2;

    PRAGMA RESTRICT_REFERENCES( get_hex, WNDS);
----------------------------------------------------------------------------------------------------
   PROCEDURE sp_get_hex (
      p_esn       IN       VARCHAR2,
      p_hex_esn  OUT       VARCHAR2 );
---------------------------------------------------------------------------------------------------
    FUNCTION f_get_hex_esn(
      p_esn VARCHAR2 )
    RETURN VARCHAR2;
----------------------------------------------------------------------------------------------------
   PROCEDURE sp_insert_ig_transaction (
      p_task_objid          IN       NUMBER,
      p_order_type_objid    IN       NUMBER,
      p_status             OUT       NUMBER,
      p_application_system  IN       VARCHAR2  DEFAULT 'IG',
      in_service_days       IN       ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
      in_voice_units        IN       ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
      in_text_units         IN       ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
      in_data_units         IN       ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
      in_free_service_days  IN       ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL, --added for Safelink TMO Upgrades
      in_free_voice_units   IN       ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
      in_free_text_units    IN       ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
      in_free_data_units    IN       ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL );
----------------------------------------------------------------------------------------------------
   FUNCTION f_check_blackout (
      p_task_objid         IN   NUMBER,
      p_order_type_objid   IN   NUMBER )
      RETURN NUMBER;
----------------------------------------------------------------------------------------------------
   PROCEDURE sp_check_blackout (
      p_task_objid         IN       NUMBER,
      p_order_type_objid   IN       NUMBER,
      p_black_out_code    OUT       NUMBER );
----------------------------------------------------------------------------------------------------
   PROCEDURE sp_get_ordertype (
      p_min                IN       VARCHAR2,
      p_order_type         IN       VARCHAR2,
      p_carrier_objid      IN       NUMBER,
      p_technology         IN       VARCHAR2,
      p_order_type_objid  OUT       NUMBER,
      p_bypass_order_type  IN       NUMBER DEFAULT NULL --CR52744
      );
----------------------------------------------------------------------------------------------------
   PROCEDURE sp_dispatch_queue (
      p_task_objid   IN       NUMBER,
      p_queue_name   IN       VARCHAR2,
      p_dummy_out   OUT       NUMBER );
----------------------------------------------------------------------------------------------------
   PROCEDURE sp_dispatch_case (
      p_case_objid   IN       NUMBER,
      p_queue_name   IN       VARCHAR2,
      p_dummy_out   OUT       NUMBER );
----------------------------------------------------------------------------------------------------
   PROCEDURE sp_determine_trans_method (
      p_action_item_objid   IN       NUMBER,
      p_order_type          IN       VARCHAR2,
      p_trans_method        IN       VARCHAR2,
      p_destination_queue  OUT       NUMBER,
      p_application_system  IN       VARCHAR2  DEFAULT 'IG',
      in_service_days       IN       ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
      in_voice_units        IN       ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
      in_text_units         IN       ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
      in_data_units         IN       ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
      in_free_service_days  IN       ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL, -- --added for Safelink TMO Upgrades
      in_free_voice_units   IN       ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
      in_free_text_units    IN       ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
      in_free_data_units    IN       ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL );
----------------------------------------------------------------------------------------------------
   PROCEDURE sp_dispatch_task (
      p_task_objid   IN       NUMBER,
      p_queue_name   IN       VARCHAR2,
      p_dummy_out   OUT       NUMBER );
----------------------------------------------------------------------------------------------------
   PROCEDURE sp_close_action_item (
      p_task_objid   IN       NUMBER,
      p_status       IN       NUMBER,
      p_dummy_out   OUT       NUMBER );
----------------------------------------------------------------------------------------------------
   PROCEDURE sp_create_case (
      p_call_trans_objid   IN       NUMBER,
      p_task_objid         IN       NUMBER,
      p_queue_name         IN       VARCHAR2,
      p_type               IN       VARCHAR2,
      p_title              IN       VARCHAR2,
      p_case_objid        OUT       NUMBER );
----------------------------------------------------------------------------------------------------
   FUNCTION f_create_case (
      p_call_trans_objid   IN   NUMBER,
      p_task_objid         IN   NUMBER,
      p_queue_name         IN   VARCHAR2,
      p_type               IN   VARCHAR2,
      p_title              IN   VARCHAR2 )
      RETURN NUMBER;
----------------------------------------------------------------------------------------------------
   PROCEDURE sp_create_action_item (
      p_contact_objid       IN       NUMBER,
      p_call_trans_objid    IN       NUMBER,
      p_order_type          IN       VARCHAR2,
      p_bypass_order_type   IN       NUMBER,
      p_case_code           IN       NUMBER,
      p_status_code        OUT       NUMBER,
      p_action_item_objid  OUT       NUMBER );

----------------------------------------------------------------------------------------------------
   PROCEDURE reopen_case_proc (
      p_case_objid           IN  NUMBER,
      p_queue_name           IN  VARCHAR2,
      p_notes                IN  VARCHAR2,
      p_user_login_name      IN  VARCHAR2,
      p_error_message       OUT  VARCHAR2 );
----------------------------------------------------------------------------------------------------
   PROCEDURE call_sp_determine_trans_method (
      p_action_item_objid   IN       NUMBER,
      p_order_type          IN       VARCHAR2,
      p_trans_method        IN       VARCHAR2,
      p_application_system  IN       VARCHAR2  DEFAULT 'IG',
      p_destination_queue  OUT       NUMBER );
----------------------------------------------------------------------------------------------------
--- CR15035 -- NET10 Activation Engine

   FUNCTION sf_get_carr_feat(
      p_order_type         IN VARCHAR2,
      p_st_esn_flag        IN VARCHAR2,
      p_site_part_objid    IN NUMBER,
      p_esn                IN VARCHAR2,
      p_carrier_objid      IN NUMBER,
      p_carr_feature_objid IN NUMBER,
      p_data_capable       IN VARCHAR2,
      p_template           IN VARCHAR2,
      p_service_plan_id    IN NUMBER DEFAULT NULL) -- SPRINT
      RETURN NUMBER;

----------------------------------------------------------------------------------------------------
--CR46807

   FUNCTION sf_get_carr_feat(
     p_order_type         IN VARCHAR2 ,
     p_st_esn_flag        IN VARCHAR2 ,
     p_site_part_objid    IN NUMBER ,
     p_esn                IN VARCHAR2 ,
     p_carrier_objid      IN NUMBER ,
     p_carr_feature_objid IN NUMBER ,
     p_data_capable       IN VARCHAR2 ,
     p_template           IN VARCHAR2 ,
     p_service_plan_id    IN NUMBER DEFAULT NULL
 --  ,p_action_item_id    in varchar2
     ,p_task_objid	IN VARCHAR2)--CR46807
     RETURN NUMBER;

--CR46807
----------------------------------------------------------------------------------------------------
   PROCEDURE sp_set_action_item_ig_trans(
      in_contact_objid         IN NUMBER,
      in_call_trans_objid      IN NUMBER,
      in_order_type            IN VARCHAR2,
      in_bypass_order_type     IN NUMBER,
      in_case_code             IN NUMBER,
      in_trans_method          IN VARCHAR2,
      in_application_system    IN VARCHAR2 DEFAULT 'IG',
      in_service_days          IN ig_transaction_buckets.bucket_balance%TYPE,
      in_voice_units           IN ig_transaction_buckets.bucket_balance%TYPE,
      in_text_units            IN ig_transaction_buckets.bucket_balance%TYPE,
      in_data_units            IN ig_transaction_buckets.bucket_balance%TYPE,
      out_ai_status_code      OUT NUMBER,
      out_destination_queue   OUT NUMBER,
      out_ig_tran_status      OUT NUMBER,
      out_action_item_objid   OUT NUMBER,
      out_action_item_id      OUT ig_transaction.action_item_id%TYPE,
      out_errorcode           OUT VARCHAR2,
      out_errormsg            OUT VARCHAR2);
-------------------------------------------------------------------------------------------------------------
   --  CR47564 changes
   --  Overloaded wrapper procedure which accepts discount code list additionally
   PROCEDURE sp_set_action_item_ig_trans
     (
       in_contact_objid       IN  NUMBER,
       in_call_trans_objid    IN  NUMBER,
       in_order_type          IN  VARCHAR2,
       in_bypass_order_type   IN  NUMBER,
       in_case_code           IN  NUMBER,
       in_trans_method        IN  VARCHAR2,
       in_application_system  IN  VARCHAR2 DEFAULT 'IG',
       in_service_days        IN  ig_transaction_buckets.bucket_balance%TYPE,
       in_voice_units         IN  ig_transaction_buckets.bucket_balance%TYPE,
       in_text_units          IN  ig_transaction_buckets.bucket_balance%TYPE,
       in_data_units          IN  ig_transaction_buckets.bucket_balance%TYPE,
       in_discount_code_list  IN  discount_code_tab,
       out_ai_status_code    OUT  NUMBER,
       out_destination_queue OUT  NUMBER,
       out_ig_tran_status    OUT  NUMBER,
       out_action_item_objid OUT  NUMBER,
       out_action_item_id    OUT  ig_transaction.action_item_id%TYPE,
       out_errorcode         OUT  VARCHAR2,
       out_errormsg          OUT  VARCHAR2
     );
-------------------------------------------------------------------------------------------------------------
   PROCEDURE setup_ig_transaction(
       in_contact_objid        IN   NUMBER,
       in_call_trans_objid     IN   NUMBER,
       in_order_type           IN   VARCHAR2,
       in_bypass_order_type    IN   NUMBER,
       in_case_code            IN   NUMBER,
       in_trans_method         IN   VARCHAR2,
       in_application_system   IN   VARCHAR2 DEFAULT 'IG',
       in_service_days         IN   ig_transaction_buckets.bucket_balance%TYPE,
       in_voice_units          IN   ig_transaction_buckets.bucket_balance%TYPE,
       in_text_units           IN   ig_transaction_buckets.bucket_balance%TYPE,
       in_data_units           IN   ig_transaction_buckets.bucket_balance%TYPE,
       in_free_service_days    IN   ig_transaction_buckets.bucket_balance%TYPE,
       in_free_voice_units     IN   ig_transaction_buckets.bucket_balance%TYPE,
       in_free_text_units      IN   ig_transaction_buckets.bucket_balance%TYPE,
       in_free_data_units      IN   ig_transaction_buckets.bucket_balance%TYPE,
       out_ai_status_code     OUT   NUMBER,
       out_destination_queue  OUT   NUMBER,
       out_ig_tran_status     OUT   NUMBER,
       out_action_item_objid  OUT   NUMBER,
       out_action_item_id     OUT   ig_transaction.action_item_id%TYPE,
       out_errorcode          OUT   VARCHAR2,
       out_errormsg           OUT   VARCHAR2 ) ;
   -------------------------------------------------------------------------------------------------------------
   -- Function added for CR45249
   FUNCTION get_ig_transaction_features(
      i_transaction_id         IN NUMBER ,
      i_carrier_features_objid IN NUMBER )
      RETURN ig_transaction_features_tab DETERMINISTIC;
   -------------------------------------------------------------------------------------------------------------
   -- Procedure added for CR45249
   PROCEDURE insert_ig_transaction_features(
      i_transaction_id         IN   NUMBER,
      i_carrier_features_objid IN   NUMBER,
      i_skip_insert_flag       IN   VARCHAR2, -- CR49087
      o_response              OUT   VARCHAR2 );
   -------------------------------------------------------------------------------------------------------------
   -- Procedure added for CR45249
   PROCEDURE insert_ig_trans_carr_response(
      i_transaction_id          IN  NUMBER,
      i_xml_response            IN  XMLTYPE,
      i_ig_transaction_status   IN  VARCHAR2 DEFAULT NULL,
      o_response               OUT  VARCHAR2 );
   -- Function added for CR45249
   FUNCTION get_msid_value(
      i_order_type IN VARCHAR2,
      i_esn        IN VARCHAR2,
      i_min        IN VARCHAR2 )
      RETURN VARCHAR2;
   -- CR44729 Procedure added for GO SMART WALLET bucket creation
   --
   PROCEDURE create_ig_transaction_buckets  ( i_esn                    IN  VARCHAR2,
                                              i_ig_transaction_id      IN  NUMBER  ,
                                              I_call_trans_objid       IN  NUMBER  ,
                                              i_site_part_objid        IN  NUMBER  ,
                                              i_rate_plan              IN  VARCHAR2,
                                              i_order_type             IN  VARCHAR2,
                                              i_bucket_expiration_date IN  DATE    ,
                                              i_bucket_value           IN  NUMBER   DEFAULT NULL,
                                              i_non_ppe                IN  NUMBER   DEFAULT NULL,
                                              i_parent_name            IN  VARCHAR2 DEFAULT NULL);

   PROCEDURE sp_awop_ig_transaction_buckets   ( i_esn                    IN  VARCHAR2 ,
                                                i_ig_transaction_id      IN  NUMBER   ,
                                                i_call_trans_objid       IN  NUMBER   ,
                                                i_site_part_objid        IN  NUMBER   ,
                                                i_ig_rate_plan           IN  VARCHAR2 ,
                                                i_order_type             IN  VARCHAR2 ,
                                                i_bucket_expiration_date IN  DATE     ,
                                                i_non_ppe                IN  NUMBER   ,
                                                i_bucket_value           IN  NUMBER   ,
                                                i_parent_name            IN  VARCHAR2  );

   PROCEDURE insert_ig_transaction_buckets ( i_ig_transaction_id      IN  NUMBER  ,
                                             i_bucket_id              IN  VARCHAR2,
                                             i_bucket_value           IN  VARCHAR2,
                                             i_bucket_balance         IN  VARCHAR2,
                                             i_bucket_expiration_date IN  DATE    ,
                                             i_benefit_type           IN  VARCHAR2 );

   PROCEDURE get_data_saver_information ( i_esn                       IN  VARCHAR2 ,
                                          i_carrier_features_objid    IN  NUMBER   ,
                                          o_data_saver_flag          OUT  VARCHAR2,
                                          o_data_saver_code          OUT  VARCHAR2 );

   --CR48373
   PROCEDURE create_sui_buckets ( i_esn                IN   VARCHAR2,
                                  i_transaction_id     IN   NUMBER,
                                  o_error_code        OUT  VARCHAR2,
                                  o_error_message     OUT  VARCHAR2);

   --CR50029
   --New procedure to retieve additional attributes from IG for SUI specific CBO call
   PROCEDURE get_ig_attributes_sui(i_esn              IN  VARCHAR2 ,
                                   i_ord_type         IN  VARCHAR2 ,
                                   o_ig_rec          OUT  sys_refcursor,
                                   o_error_code      OUT  VARCHAR2,
                                   o_error_message   OUT  VARCHAR2 );

   --52986
   -- Function to get the data_units conversion Y/N flag from table x_rate_plan
   FUNCTION get_calculate_data_units_flag(i_rate_plan IN VARCHAR2) RETURN BOOLEAN DETERMINISTIC;

   --CR52803 New function added to get safelink batch flag
   FUNCTION get_safelink_batch_flag(i_order_type IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;

   --CR50242
   PROCEDURE sp_get_ig_values(
      p_esn                 IN  VARCHAR2 ,
      p_order_type          IN  VARCHAR2 ,
      p_application_system  IN  VARCHAR2 DEFAULT 'IG',
      o_ig_rec             OUT  SYS_REFCURSOR,
      p_status             OUT  VARCHAR2,
      p_ret_msg            OUT  VARCHAR2);

   --CR52905 - Function to check if bucket is active bucket in ig_buckets.
   FUNCTION get_ig_buckets_active_flag ( in_rate_plan  IN VARCHAR2,
                                         in_bucket_id  IN VARCHAR2 ) RETURN VARCHAR2;

   --CR52905 - Function to check if buckets should be created for the IG order type
   FUNCTION get_create_buckets_flag ( in_order_type IN VARCHAR2 ) RETURN VARCHAR2;

   --CR52120 changes start
   FUNCTION  get_ig_features ( i_profile_id IN  NUMBER ) RETURN  ig_transaction_features_tab;
   --CR52120 changes end

END igate;
/