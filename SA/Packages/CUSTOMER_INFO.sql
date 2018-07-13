CREATE OR REPLACE PACKAGE sa."CUSTOMER_INFO"
AS
 FUNCTION convert_pin_to_smp ( i_red_card_code IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC;
 FUNCTION convert_smp_to_pin ( i_smp IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC;
 FUNCTION get_leasing_flag ( i_bus_org_objid  IN NUMBER) RETURN VARCHAR2 DETERMINISTIC;
 FUNCTION get_bus_org_id ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC;
 FUNCTION get_bus_org_objid ( i_esn IN VARCHAR2 ) RETURN NUMBER DETERMINISTIC;
 FUNCTION get_bus_org_objid (i_bus_org_id VARCHAR2) RETURN NUMBER DETERMINISTIC;

FUNCTION get_min ( i_esn IN VARCHAR2 ) RETURN VARCHAR2  DETERMINISTIC;
FUNCTION get_esn ( i_min IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC;
FUNCTION get_brm_applicable_flag  ( i_bus_org_objid           IN NUMBER ,
                                    i_program_parameter_objid IN NUMBER ) RETURN VARCHAR2 DETERMINISTIC;

FUNCTION get_brm_applicable_flag ( i_bus_org_id              IN VARCHAR2 ,
                                   i_program_parameter_objid IN NUMBER   ) RETURN VARCHAR2 DETERMINISTIC;
FUNCTION get_brm_applicable_flag  ( i_busorg_objid IN NUMBER ) RETURN VARCHAR2 DETERMINISTIC;
FUNCTION get_brm_applicable_flag  ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC;
FUNCTION get_brm_notification_flag  ( i_bus_org_objid IN NUMBER ) RETURN VARCHAR2 DETERMINISTIC;
FUNCTION get_brm_notification_flag  ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC;

FUNCTION get_expiration_date ( i_esn IN VARCHAR2 ) RETURN DATE DETERMINISTIC;
FUNCTION get_last_redemption_date ( i_esn         IN VARCHAR2 ,
                                    i_exclude_esn IN VARCHAR2 DEFAULT NULL ) RETURN DATE DETERMINISTIC;
FUNCTION get_contact_info ( i_esn IN VARCHAR2, i_value IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC;
FUNCTION get_contact_add_info ( i_esn IN VARCHAR2, i_value IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC;

FUNCTION get_part_class_attributes ( i_esn IN VARCHAR2, i_value IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC;

FUNCTION get_ota_conversion_rate ( i_esn_part_inst_objid IN NUMBER ) RETURN VARCHAR2 DETERMINISTIC;
FUNCTION get_propagate_flag ( i_rate_plan IN VARCHAR2 ) RETURN NUMBER  DETERMINISTIC;
FUNCTION get_rate_plan ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC;
FUNCTION get_shared_group_flag ( i_bus_org_id IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;
FUNCTION get_shared_group_flag ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC;
FUNCTION get_short_parent_name ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC;
FUNCTION get_short_parent_name ( i_parent_name IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC;
FUNCTION get_service_plan_name ( i_esn IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC;
FUNCTION get_service_plan_objid ( i_esn IN VARCHAR2 ) RETURN NUMBER DETERMINISTIC;
FUNCTION get_sub_brand (i_min IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;
FUNCTION get_web_user_id (i_hash_webuserid IN VARCHAR2 ) RETURN NUMBER DETERMINISTIC;
FUNCTION get_web_user_attributes (i_esn IN VARCHAR2, i_value IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC;
FUNCTION retrieve_login (i_login_name IN VARCHAR2, i_bus_org_id IN VARCHAR2,i_value      IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC;
FUNCTION get_esn_part_inst_objid (i_esn IN VARCHAR2) RETURN NUMBER DETERMINISTIC;
FUNCTION get_service_plan_attributes  (i_esn IN VARCHAR2, i_value IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC;
FUNCTION get_esn_queued_cards (i_esn IN VARCHAR2) RETURN customer_queued_card_tab DETERMINISTIC;
FUNCTION get_esn_pin_redeem_days (i_esn IN VARCHAR2, i_pin IN VARCHAR2) RETURN NUMBER DETERMINISTIC;
FUNCTION get_service_plan_days ( i_esn IN VARCHAR2,
                                 i_pin IN VARCHAR2,
                                 i_service_plan_objid NUMBER DEFAULT NULL) RETURN VARCHAR2 DETERMINISTIC;
FUNCTION get_service_plan_days_name ( i_esn IN VARCHAR2,
                                      i_pin IN VARCHAR2,
                                      i_service_plan_objid NUMBER DEFAULT NULL) RETURN VARCHAR2 DETERMINISTIC;

FUNCTION get_transaction_status ( i_esn IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;

FUNCTION get_carrier_name ( i_sim_serial IN VARCHAR2 DEFAULT NULL,
                            i_esn        IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 DETERMINISTIC;

FUNCTION get_sim_status ( i_sim_serial IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC;

FUNCTION get_sim_legacy_flag(i_sim IN VARCHAR2)  RETURN VARCHAR2  DETERMINISTIC;

FUNCTION get_service_forecast_due_date (i_esn IN VARCHAR2)  RETURN DATE DETERMINISTIC;
--CR49696 start
FUNCTION is_valid_zip_code (i_zip_code IN VARCHAR2)  RETURN VARCHAR2 DETERMINISTIC;
--CR49696 end
FUNCTION get_last_addon_redemption_date ( i_esn         IN VARCHAR2 ) RETURN DATE DETERMINISTIC;

--CR49721
FUNCTION get_esn_queue_card_days ( i_esn  IN VARCHAR2 ) RETURN NUMBER DETERMINISTIC;

--CR51037 - WFM -  Start
FUNCTION get_service_plan_group(i_plan_part_number IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;
--
FUNCTION get_esn_pin_redeem_details(i_esn IN VARCHAR2 DEFAULT NULL,
                                    i_min IN VARCHAR2 DEFAULT NULL)
RETURN redeem_pin_details_tab DETERMINISTIC;
--CR51037 - WFM -  End
FUNCTION get_sub_brand_by_esn (i_esn IN VARCHAR2) RETURN VARCHAR2 DETERMINISTIC;
FUNCTION get_next_charge_date (i_esn IN VARCHAR2) RETURN DATE;
--SM MLD changes Starts
FUNCTION get_shared_group_flag ( i_brand                IN VARCHAR2             ,
                                 i_esn                  IN VARCHAR2 DEFAULT NULL,
                                 i_min                  IN VARCHAR2 DEFAULT NULL,
                                 i_pin                  IN VARCHAR2 DEFAULT NULL,
                                 i_sim                  IN VARCHAR2 DEFAULT NULL,
                                 i_sp_objid             IN NUMBER   DEFAULT NULL,
                                 i_plan_part_number     IN VARCHAR2 DEFAULT NULL
                               ) RETURN VARCHAR2 DETERMINISTIC;
FUNCTION get_part_class ( i_part_num IN VARCHAR2 ) RETURN VARCHAR2;
--SM MLD changes Ends
-- CR54110 (defect# 31410)
FUNCTION get_program_enrollment ( i_esn IN VARCHAR2 ) RETURN program_enrolled_type;
-- function to return the sourcesystem of program enrollment for a given ESN
-- CR54110 (defect# 31410)
FUNCTION is_warp_sourcesystem ( i_esn IN VARCHAR2 ) RETURN VARCHAR2;
FUNCTION ISAUTOREFILL(i_esn IN VARCHAR2)  RETURN NUMBER;
FUNCTION get_pin_redeem_days (i_pin  IN VARCHAR2)  RETURN NUMBER;
END CUSTOMER_INFO;
/