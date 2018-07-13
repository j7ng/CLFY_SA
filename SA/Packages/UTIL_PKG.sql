CREATE OR REPLACE PACKAGE sa."UTIL_PKG" AS

procedure insert_error_tab_proc ( ip_action         IN   VARCHAR2,
                                  ip_key            IN   VARCHAR2,
                                  ip_program_name   IN   VARCHAR2,
                                  ip_error_text     IN   VARCHAR2 DEFAULT NULL );

PROCEDURE insert_error_tab ( i_action         IN   VARCHAR2,
                             i_key            IN   VARCHAR2,
                             i_program_name   IN   VARCHAR2,
                             i_error_text     IN   VARCHAR2 DEFAULT NULL );

FUNCTION determine_usage_host_id ( i_esn IN VARCHAR2 ) RETURN VARCHAR2;

-- Get the rate plan of an ESN
FUNCTION get_esn_rate_plan ( i_esn IN VARCHAR2 ) RETURN VARCHAR2;

FUNCTION get_expire_dt ( i_esn  IN VARCHAR2 ) RETURN DATE;

-- Used from get_esn_inquiry
FUNCTION get_esn_by_min ( i_min IN VARCHAR2 ) RETURN VARCHAR2;

-- Used from get_esn_inquiry
FUNCTION get_esn_by_msid ( i_msid IN VARCHAR2 ) RETURN VARCHAR2;

-- Get the MIN (part_serial_no) based on the ESN
FUNCTION get_min_by_esn ( i_esn IN VARCHAR2 ) RETURN VARCHAR2;

-- Added function to get the brand objid based on a provided MIN
FUNCTION get_min_bus_org_id ( i_min IN VARCHAR2) RETURN VARCHAR2;

-- Added function to get the brand objid based on a provided ESN
FUNCTION get_bus_org_id ( i_esn IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_bus_org_objid ( i_esn IN VARCHAR2) RETURN NUMBER;

-- Added function to get the web user objid based on a provided ESN
FUNCTION get_web_user_objid ( i_esn IN VARCHAR2) RETURN NUMBER;

FUNCTION get_bus_org_rec ( i_esn VARCHAR2) RETURN table_bus_org%ROWTYPE;
--
FUNCTION get_parent_name ( i_line_part_inst_objid IN NUMBER ) RETURN VARCHAR2;

FUNCTION get_parent_name ( i_esn IN VARCHAR2 ) RETURN VARCHAR2;

-- Added wrapper function to get the service plan id based on a provided ESN and PIN
FUNCTION get_service_plan_id ( i_esn  IN VARCHAR2,
                               i_pin  IN VARCHAR2 ) RETURN NUMBER;

-- Added wrapper function to get the service plan id based on a provided ESN
FUNCTION get_service_plan_id ( i_esn IN VARCHAR2) RETURN NUMBER;

FUNCTION get_ota_current_conv_rate ( i_part_inst_objid IN NUMBER ) RETURN VARCHAR2;

-- Get the service plan feature for an ESN's service plan and a feature value
FUNCTION get_sp_feature_value ( i_esn         IN VARCHAR2,
                                i_value_name  IN VARCHAR ) RETURN VARCHAR2;

FUNCTION get_ota_features ( i_part_inst_objid IN NUMBER ) RETURN table_x_ota_features%ROWTYPE;

FUNCTION get_sp_feature_value ( i_service_plan_plan_objid IN NUMBER,
                                i_value_name              IN VARCHAR ) RETURN VARCHAR2 ;

FUNCTION get_short_parent_name ( i_line_part_inst_objid IN NUMBER ) RETURN VARCHAR2;

FUNCTION get_short_parent_name ( i_parent_name IN VARCHAR2 ) RETURN VARCHAR2;

function get_propagate_flag( ip_esn in varchar2,
                             ip_rate_plan in varchar2) return number;

--
FUNCTION get_last_base_red_date ( ip_esn        IN  VARCHAR2,
                                  op_msg        OUT VARCHAR2,
                                  i_exclude_esn IN  VARCHAR2 DEFAULT NULL) RETURN DATE;

FUNCTION get_last_base_red_date ( i_esn         IN VARCHAR2,
                                  i_exclude_esn IN VARCHAR2 DEFAULT NULL ) RETURN DATE;

FUNCTION get_queued_days ( i_esn IN VARCHAR2 ) RETURN NUMBER;

-- Function to determine the ESN based on the MIN or MSID or SUBSCRIBER_ID
FUNCTION get_esn ( i_min           IN VARCHAR2 ,
                   i_msid          IN VARCHAR2 ,
                   i_subscriber_id IN VARCHAR2 ,
                   i_wf_mac_id     IN VARCHAR2 ) RETURN VARCHAR2;
-- CR31456
FUNCTION fn_get_prev_carrier (i_serial_no IN VARCHAR2) RETURN VARCHAR2;

-- CR31456
PROCEDURE p_get_carrier_frm_nap_digital(i_zip             IN    VARCHAR2,
                                        i_esn             IN    VARCHAR2,
                                        i_sim             IN    VARCHAR2,
                                        i_source          IN    VARCHAR2,
                                        o_carr_mkt_objid  OUT   VARCHAR2,  --Added for CR42933 - ST Refresh
                                        o_carr_parent_id  OUT   VARCHAR2,   --Added for CR42933 - ST Refresh
                                        i_carrier         OUT   VARCHAR2,
                                        i_error_no        OUT   NUMBER,
                                        i_error_str       OUT   VARCHAR2);
-- CR31456
FUNCTION fn_is_number (i_string IN VARCHAR2)
RETURN NUMBER;
-- CR31456
PROCEDURE p_convert_esn(i_serial_no     IN    VARCHAR2, -- ESN
                        i_carrier       IN    VARCHAR2,
                        i_err_no        OUT   NUMBER,
                        i_err_str       OUT   VARCHAR2,
                        i_esn           OUT   VARCHAR2,
                        i_esn_hex       OUT   VARCHAR2
                       );
--CR43088 WARP 2.0
PROCEDURE p_insert_queued_cbo_service(ip_cbo_task_name       IN  VARCHAR2,
                                      ip_status              IN  VARCHAR2,
                                      ip_creation_date       IN  DATE,
                                      ip_delay_in_seconds    IN  NUMBER,
                                      ip_request             IN  CLOB,
                                      ip_soa_service_url     IN  VARCHAR2,
                                      ip_esn                 IN  VARCHAR2  DEFAULT NULL,
                                      ip_upgrade_to_esn      IN  VARCHAR2  DEFAULT NULL,
                                      ip_source_system       IN  VARCHAR2  DEFAULT NULL,
                                      op_error_code          OUT VARCHAR2,
                                      op_error_msg           OUT VARCHAR2);
--CR43088 WARP 2.0
--
--CR42674
PROCEDURE insert_rtc_log (
      ip_action         IN   VARCHAR2,
      ip_key            IN   VARCHAR2,
      ip_program_name   IN   VARCHAR2,
      ip_process_text   IN   VARCHAR2 DEFAULT NULL
   );


-- CR52737_Track_Name_and_Address_History_Part_2  Tim  10/2/2017
PROCEDURE write_log (ip_call_id           sa.adfcrm_activity_log.call_id%type,
                     ip_esn               sa.adfcrm_activity_log.esn%type,
                     ip_cust_id           sa.adfcrm_activity_log.cust_id%type,
                     ip_smp               sa.adfcrm_activity_log.smp%type,
                     ip_agent             sa.adfcrm_activity_log.agent%type,
                     ip_flow_name         sa.adfcrm_activity_log.flow_name%type,
                     ip_flow_description  sa.adfcrm_activity_log.flow_description%type,
                     ip_status            sa.adfcrm_activity_log.status%type,
                     ip_permission_name   sa.adfcrm_activity_log.permission_name%type,
                     ip_reason            sa.adfcrm_activity_log.reason%type,
                     ip_ani               VARCHAR2,
                     ip_source_system     VARCHAR2
                       );

FUNCTION get_cos_by_red_date (i_cos      IN VARCHAR2,
                              i_red_date IN DATE ) RETURN VARCHAR2;

--Get Volte Flag.
FUNCTION get_volte_flag (i_part_num IN table_part_num.part_number%TYPE ) RETURN VARCHAR2;

FUNCTION net10_data_promo (i_esn      IN VARCHAR2,
                           i_min      IN VARCHAR2,
                           i_sp_objid IN NUMBER,
						   i_ct_objid IN NUMBER DEFAULT NULL) RETURN VARCHAR2;


END;
/