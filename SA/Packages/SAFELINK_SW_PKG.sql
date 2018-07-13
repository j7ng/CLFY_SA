CREATE OR REPLACE PACKAGE sa.safelink_sw_pkg AS
 PROCEDURE sp_retrieve_service_plan_id_sl (
 ip_program_name    IN  x_program_parameters.x_program_name%TYPE,
 ip_program_objid   IN  x_program_parameters.objid%TYPE,
 ip_esn             IN  x_program_enrolled.x_esn%TYPE,
 ip_biz_line        IN  table_bus_org.org_id%TYPE,
 op_program_name    OUT x_program_parameters.x_program_name%TYPE,
 op_program_objid   OUT x_program_parameters.objid%TYPE,
 op_service_plan_id OUT x_service_plan.objid%TYPE,
 op_error_code     OUT NUMBER,
 op_error_message  OUT VARCHAR2
);
PROCEDURE get_carrier_id_sl_dis
(
ip_carrier_objid IN table_x_carrier.objid%TYPE,
ip_esn           IN VARCHAR2,
op_carrier_objid OUT NUMBER,
op_error_code    OUT  NUMBER,
op_error_msg     OUT  VARCHAR2
);
--CR41784 changes
PROCEDURE sp_retrieve_service_plan_id_sl ( --overloaded procedure to return service plan id based on ESN
 ip_esn              IN  x_program_enrolled.x_esn%TYPE,
 op_service_plan_id  OUT x_service_plan.objid%TYPE,
 op_rp_change_flag   OUT VARCHAR2, -- values 'Y','N'
 op_error_code       OUT NUMBER,
 op_error_message    OUT VARCHAR2
);--CR41784 changes
PROCEDURE create_call_trans_carrier_id
(
 ip_esn                IN       VARCHAR2,
 ip_action_type        IN       VARCHAR2,
 ip_sourcesystem       IN       VARCHAR2,
 ip_brand_name         IN       VARCHAR2,
 ip_reason             IN       VARCHAR2,
 ip_result             IN       VARCHAR2,
 ip_ota_req_type       IN       VARCHAR2,
 ip_ota_type           IN       VARCHAR2,
 ip_total_units        IN       NUMBER,
 ip_orig_login_objid   IN       NUMBER,
 ip_action_text        IN       VARCHAR2,
 ip_calltrans2carrier  IN       NUMBER,
 op_calltranobj        OUT      NUMBER,
 op_err_code           OUT      VARCHAR2,
 op_err_msg            OUT      VARCHAR2
);
PROCEDURE sp_is_safelink
(
ip_esn           IN  VARCHAR2,
out_flag         OUT VARCHAR2,
out_units        OUT NUMBER,
op_error_code    OUT INTEGER,
op_error_message OUT VARCHAR2
);
PROCEDURE get_carrier_id_sl_rp_change
(
ip_carrier_objid IN table_x_carrier.objid%TYPE,
ip_esn           IN VARCHAR2,
ip_reason        IN VARCHAR2, --values 'DEENROLL','REENROLL'
op_carrier_objid OUT NUMBER,
op_error_code    OUT  NUMBER,
op_error_msg     OUT  VARCHAR2
);
--CR41784 changes
PROCEDURE process_sl_reenrollment
(
ip_esn                     IN  VARCHAR2,
ip_lid                     IN  VARCHAR2,
op_err_code                OUT VARCHAR2,
op_err_msg                 OUT VARCHAR2
);
--CR41784 changes
END safelink_sw_pkg;
/