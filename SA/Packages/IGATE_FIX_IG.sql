CREATE OR REPLACE PACKAGE sa.igate_fix_ig AS
----------------------------------------------------------------------------------------------------
   PROCEDURE sp_close_case (
      p_case_id                 VARCHAR2,
      p_user_login_name         VARCHAR2,
      p_source                  VARCHAR2,
      p_resolution_code         VARCHAR2,
      p_status            OUT   VARCHAR2,
      p_msg               OUT   VARCHAR2
   );
----------------------------------------------------------------------------------------------------
   FUNCTION get_hex (p_esn IN VARCHAR2)
      RETURN VARCHAR2;

   PRAGMA restrict_references( get_hex, wnds);
----------------------------------------------------------------------------------------------------
                                              PROCEDURE sp_get_hex (
      p_esn       IN       VARCHAR2,
      p_hex_esn   OUT      VARCHAR2
   );
---------------------------------------------------------------------------------------------------
    FUNCTION f_get_hex_esn(
      p_esn                  VARCHAR2
    )
    RETURN VARCHAR2;
----------------------------------------------------------------------------------------------------
     PROCEDURE sp_insert_ig_transaction (
      p_task_objid         IN       NUMBER,
      p_order_type_objid   IN       NUMBER,
      p_status             OUT      NUMBER,
      p_application_system IN       VARCHAR2  DEFAULT 'IG'
   );
----------------------------------------------------------------------------------------------------
   FUNCTION f_check_blackout (
      p_task_objid         IN   NUMBER,
      p_order_type_objid   IN   NUMBER
   )
      RETURN NUMBER;
----------------------------------------------------------------------------------------------------
   PROCEDURE sp_check_blackout (
      p_task_objid         IN       NUMBER,
      p_order_type_objid   IN       NUMBER,
      p_black_out_code     OUT      NUMBER
   );
----------------------------------------------------------------------------------------------------
     PROCEDURE sp_get_ordertype (
      p_min                IN       VARCHAR2,
      p_order_type         IN       VARCHAR2,
      p_carrier_objid      IN       NUMBER,
      p_technology         IN       VARCHAR2,
      p_order_type_objid   OUT      NUMBER
   );
----------------------------------------------------------------------------------------------------
     PROCEDURE sp_dispatch_queue (
      p_task_objid   IN       NUMBER,
      p_queue_name   IN       VARCHAR2,
      p_dummy_out    OUT      NUMBER
   );
----------------------------------------------------------------------------------------------------
     PROCEDURE sp_dispatch_case (
      p_case_objid   IN       NUMBER,
      p_queue_name   IN       VARCHAR2,
      p_dummy_out    OUT      NUMBER
   );
----------------------------------------------------------------------------------------------------
     PROCEDURE sp_determine_trans_method (
      p_action_item_objid   IN       NUMBER,
      p_order_type          IN       VARCHAR2,
      p_trans_method        IN       VARCHAR2,
      p_destination_queue   OUT      NUMBER,
      p_application_system  IN       VARCHAR2  DEFAULT 'IG'
   );
----------------------------------------------------------------------------------------------------
     PROCEDURE sp_dispatch_task (
      p_task_objid   IN       NUMBER,
      p_queue_name   IN       VARCHAR2,
      p_dummy_out    OUT      NUMBER
   );
----------------------------------------------------------------------------------------------------
     PROCEDURE sp_close_action_item (
      p_task_objid   IN       NUMBER,
      p_status       IN       NUMBER,
      p_dummy_out    OUT      NUMBER
   );
----------------------------------------------------------------------------------------------------
     PROCEDURE sp_create_case (
      p_call_trans_objid   IN       NUMBER,
      p_task_objid         IN       NUMBER,
      p_queue_name         IN       VARCHAR2,
      p_type               IN       VARCHAR2,
      p_title              IN       VARCHAR2,
      p_case_objid         OUT      NUMBER
   );
----------------------------------------------------------------------------------------------------
   FUNCTION f_create_case (
      p_call_trans_objid   IN   NUMBER,
      p_task_objid         IN   NUMBER,
      p_queue_name         IN   VARCHAR2,
      p_type               IN   VARCHAR2,
      p_title              IN   VARCHAR2
   )
      RETURN NUMBER;
----------------------------------------------------------------------------------------------------
                    PROCEDURE sp_create_action_item (
      p_contact_objid       IN       NUMBER,
      p_call_trans_objid    IN       NUMBER,
      p_order_type          IN       VARCHAR2,
      p_bypass_order_type   IN       NUMBER,
      p_case_code           IN       NUMBER,
      p_status_code         OUT      NUMBER,
      p_action_item_objid   OUT      NUMBER
   );

----------------------------------------------------------------------------------------------------
   PROCEDURE reopen_case_proc (
      p_case_objid           IN  NUMBER,
      p_queue_name           IN  VARCHAR2,
      p_notes                IN  VARCHAR2,
      p_user_login_name      IN  VARCHAR2,
      p_error_message        OUT VARCHAR2
   );
----------------------------------------------------------------------------------------------------
   PROCEDURE call_sp_determine_trans_method (
      p_action_item_objid   IN       NUMBER,
      p_order_type          IN       VARCHAR2,
      p_trans_method        IN       VARCHAR2,
      p_application_system  IN       VARCHAR2  DEFAULT 'IG',
      p_destination_queue   OUT      NUMBER
   );
----------------------------------------------------------------------------------------------------
--- CR15035 -- NET10 Activation Engine

  FUNCTION sf_get_carr_feat ( p_order_type          IN      VARCHAR2,
                              p_st_esn_flag         IN      VARCHAR2,
                              p_site_part_objid     IN      NUMBER,
                              p_esn                 IN      VARCHAR2,
                              p_carrier_objid       IN      NUMBER,
                              p_carr_feature_objid  IN      NUMBER,
                              p_data_capable        IN      VARCHAR2,
                              p_template            IN      VARCHAR2,
                              p_service_plan_id     IN      NUMBER DEFAULT NULL -- SPRINT
                            )
  RETURN NUMBER;
----------------------------------------------------------------------------------------------------

END igate_fix_ig;
/