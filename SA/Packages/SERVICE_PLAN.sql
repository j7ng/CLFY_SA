CREATE OR REPLACE PACKAGE sa."SERVICE_PLAN" AS
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: SERVICE_PLAN_PKG.sql,v $
  --$Revision: 1.43 $
  --$Author: skambhammettu $
  --$Date: 2018/01/30 21:57:32 $
  --$ $Log: SERVICE_PLAN_PKG.sql,v $
  --$ Revision 1.43  2018/01/30 21:57:32  skambhammettu
  --$ New function get_vas_group_name
  --$
  --$ Revision 1.38  2017/12/11 19:04:56  sraman
  --$ Merged with prod code deployed today (Net10 WCS)
  --$
  --$ Revision 1.37  2017/11/10 17:10:24  skambhammettu
  --$ Added new input parameters in get_sp_retention_action_script
  --$
  --$ Revision 1.35  2017/10/16 23:28:51  sgangineni
  --$ CR54147 - Declared the function sp_get_pin_service_plan_id in package spec
  --$
  --$ Revision 1.33  2017/08/21 22:34:24  sraman
  --$ Overloaded the SP_GET_PARTNUM_SERVICE_PLAN
  --$
  --$ Revision 1.32  2017/08/08 21:47:06  vlaad
  --$ Added comments
  --$
  --$ Revision 1.26  2017/04/18 16:17:05  smeganathan
  --$ Merged with WFM production release
  --$
  --$ Revision 1.25  2017/03/24 19:14:39  smeganathan
  --$ CR48846 added new procedures sp_get_partnum_service_plan, get_conversion_details, get_service_plan_info
  --$
  --$ Revision 1.24  2017/03/07 21:45:34  sgangineni
  --$ CR47564 - WFM Changes - Added new procedure GET_PART_CLASS_NAME to get the part class for the given service plan id
  --$
  --$ Revision 1.23  2016/10/27 21:50:22  rpednekar
  --$ CR43577 - New procedure get_carrier_feature
  --$
  --$ Revision 1.19  2015/09/02 22:36:43  smeganathan
  --$ Changes for 35913 Change in requirement for retention action script
  --$
  --$ Revision 1.19  2015/09/02 15:57:00  sethiraj
  --$ CR35913: Changes to Get_Sp_Retention_Action_Script to add out parameter out_ret_warning_flag.
  --$
  --$ Revision 1.18  2015/08/26 20:32:37  smeganathan
  --$ Changes for 35913 My accounts - changed the comments
  --$
  --$ Revision 1.17  2015/08/11 19:20:31  smeganathan
  --$ Changes for 35913 My accounts
  --$
  --$ Revision 1.16  2015/07/29 20:36:59  aganesan
  --$ CR35913 - My account changes.
  --$
  --$ Revision 1.16  2015/07/10 10:00:00  sethiraj
  --$ CR35913: New PROCEDURE Get_Sp_Retention_Action_Script
  --$
  --$ Revision 1.15  2013/07/31 13:57:18  akuthadi
  --$ 1. New FUNCTION get_service_plan_by_esn
  --$ 2. New PROCEDURE get_sp_retention_action
  --$
  --$ Revision 1.14  2011/12/09 21:21:14  mmunoz
  --$ Added output parameter: part_number in procedure GET_SERVICE_PLAN_PRC
  --$
  --$ Revision 1.13  2011/11/21 21:59:08  mmunoz
  --$ Added email like output parameter in procedure GET_SERVICE_PLAN_PRC
  --$
  --$ Revision 1.12  2011/10/27 15:46:35  mmunoz
  --$ Merge changes related with CR16317 with the last code release.
  --$
  --$ Revision 1.11  2011/10/20 17:10:51  kacosta
  --$ CR16987 Add Rate Plan to Port In Cases
  --$
  --$ Revision 1.10  2011/10/17 18:55:13  kacosta
  --$ CR16987 Add Rate Plan to Port In Cases
  --$
  --$ Revision 1.5  2011/08/11 19:29:55  mmunoz
  --$ CR16988 SOA 2011 Added procedures sp_get_pin_service_plan
  --$
  --$ Revision 1.4  2011/07/14 18:50:24  kacosta
  --$ 16920 T-Mo Port Admin Tool Null Exception error
  --$ Removed SP_GET_ESN_RATE_PLAN procedure by mistake.  Added procedure back
  --$
  --$ Revision 1.3  2011/06/30 14:28:11  kacosta
  --$ CR16470 - Create get_rate_plan Function
  --$ Added functions to retreive the switch base rate
  --$
  --$ Revision 1.2  2011/06/07 14:41:23  kacosta
  --$ CR16470 - Create get_rate_plan Function
  --$
  --$
  --$ CR16988 SOA 2011 Added procedures sp_get_pin_service_plan  mmunoz
  ---------------------------------------------------------------------------------------------
  --
  -- Global Package Variables
  --
  l_b_debug BOOLEAN := FALSE;
  --
  -- Public Functions
  --
  --********************************************************************************
  -- Function will retrieve the rate plan for an ESN irrespective of status of ESN/MIN
  -- Written for CR16987
  --********************************************************************************
  --
  FUNCTION f_get_esn_rate_plan_all_status(p_esn IN table_part_inst.part_serial_no%TYPE) RETURN table_x_carrier_features.x_rate_plan%TYPE;
  --
  --********************************************************************************
  -- Function will retrieve the rate plan for an ESN
  --********************************************************************************
  --
  FUNCTION f_get_esn_rate_plan(p_esn IN table_part_inst.part_serial_no%TYPE) RETURN table_x_carrier_features.x_rate_plan%TYPE;
  --
  --********************************************************************************
  -- Function will retrieve the switch base rate for an ESN
  -- Created for CR16470
  --********************************************************************************
  --
  FUNCTION f_get_esn_switch_base_rate(p_esn IN table_part_inst.part_serial_no%TYPE) RETURN table_x_carrier_features.x_switch_base_rate%TYPE;
  --
  --********************************************************************************
  -- Function will retrieve the rate plan for a site part
  -- Created for CR16470
  --********************************************************************************
  --
  FUNCTION f_get_site_part_rate_plan(p_site_part_objid IN table_site_part.objid%TYPE) RETURN table_x_carrier_features.x_rate_plan%TYPE;
  --
  --********************************************************************************
  -- Function will retrieve the rate plan for a site part
  -- Created for CR16470
  --********************************************************************************
  --
  FUNCTION f_get_site_part_switch_base_rt(p_site_part_objid IN table_site_part.objid%TYPE) RETURN table_x_carrier_features.x_switch_base_rate%TYPE; --
  --
  -- Public Procedures
  --
  --********************************************************************************
  -- Wrapper procedure will retrieve the rate plan for an ESN
  --********************************************************************************
  --
  PROCEDURE sp_get_esn_rate_plan
  (
    p_esn           IN table_part_inst.part_serial_no%TYPE
   ,p_rate_plan     OUT table_x_carrier_features.x_rate_plan%TYPE
   ,p_error_code    OUT INTEGER
   ,p_error_message OUT VARCHAR2
  );
  --
  --********************************************************************************
  -- Wrapper procedure will retrieve the rate plan for an ESN
  --********************************************************************************
  --
  PROCEDURE sp_get_esn_rate_plan_allstatus
  (
    p_esn           IN table_part_inst.part_serial_no%TYPE
   ,p_rate_plan     OUT table_x_carrier_features.x_rate_plan%TYPE
   ,p_error_code    OUT INTEGER
   ,p_error_message OUT VARCHAR2
  );
  --
  --********************************************************************************
  -- Wrapper procedure will retrieve the service plan for a PIN
  -- CR16988 SOA 2011
  -- Author: RMercado
  --********************************************************************************
  --
  PROCEDURE sp_get_pin_service_plan
  (
    ip_pin        IN table_part_inst.x_red_code%TYPE
   ,op_result_set OUT SYS_REFCURSOR
   ,op_err_num    OUT INTEGER
   ,op_err_string OUT VARCHAR2
  );
  --
  /* GET_SERVICE_PLAN_PRC will retrieve information about service plan, redemption cards and credit card related an ESN   */
PROCEDURE GET_SERVICE_PLAN_PRC
  (
   ip_esn                    in varchar2
  ,op_ServicePlanID          out number
  ,op_ServicePlanName        out varchar2
  ,op_ServicePlanUnlimited   out number   --1 if true and 0 if false
  ,op_Autorefill             out number   --1 if true and 0 if false
  ,op_Service_End_Dt         out date
  ,op_Forecast_date          out date
  ,op_CreditCardReg          out number   --1 if true and 0 if false
  ,op_RedempCardQueue        out number
  ,op_CreditCardSch          out number   --1 if true and 0 if false
  ,op_StatusId               out varchar2
  ,op_StatusDesc             out varchar2
  ,op_email                  out varchar2
  ,op_part_num				 out varchar2
  ,op_err_num                out number
  ,op_err_string             out varchar2
  );

  --
  FUNCTION get_service_plan_by_esn(in_esn IN table_part_inst.part_serial_no%TYPE) RETURN x_service_plan%ROWTYPE;
  --
  PROCEDURE get_sp_retention_action(in_esn               IN     table_part_inst.part_serial_no%TYPE,
                                    in_flow_name         IN     VARCHAR2,
                                    io_dest_plan_act_tbl IN OUT retention_action_typ_tbl,
                                    out_err_num          out    INTEGER,
                                    out_err_string       out    VARCHAR2);
  --
  PROCEDURE get_sp_retention_action_script(in_esn        IN  table_part_inst.part_serial_no%TYPE,
                                    in_flow_name         IN  VARCHAR2,
                                    p_brand_name 		     IN  VARCHAR2 ,
                                    in_language           IN VARCHAR2 DEFAULT 'ENGLISH',
                                    in_source_system      IN VARCHAR2 DEFAULT 'APP',
                                    io_dest_plan_act_tbl IN OUT retention_action_typ_tbl,
                                    ret_script_text 	   OUT table_x_scripts.x_script_text%TYPE,
                                    out_ret_warning_flag OUT VARCHAR2,
                                    out_err_num          OUT INTEGER,
                                    out_err_string       OUT VARCHAR2);
  --
  PROCEDURE get_carrier_features (ip_esn				VARCHAR2
				,ip_service_plan_id			VARCHAR2
				,ip_carrier_objid			VARCHAR2
				,op_switch_base_rate		OUT	VARCHAR2
				,op_error_code			OUT	VARCHAR2
				,op_error_msg			OUT	VARCHAR2
				);
  --
--CR47564 WFM Changes start
  PROCEDURE GET_PART_CLASS_NAME ( i_service_plan_id   IN  NUMBER,
                                  o_part_class_name   OUT VARCHAR2,
                                  o_err_code          OUT VARCHAR2,
                                  o_err_msg           OUT VARCHAR2);
  --CR47564 WFM Change end
  -- CR48846 changes starts..
  -- Procedure to get service plan details based on the part number
  PROCEDURE sp_get_partnum_service_plan(ip_part_number  IN  table_part_num.part_number%TYPE ,
                                        op_result_set   OUT SYS_REFCURSOR ,
                                        op_err_num      OUT INTEGER ,
                                        op_err_string   OUT VARCHAR2 );

  PROCEDURE sp_get_partnum_service_plan(ip_part_number  IN  table_part_num.part_number%TYPE ,
                                        ip_esn          IN  VARCHAR2 ,
                                        op_sp_objid     OUT NUMBER ,
                                        op_err_num      OUT INTEGER ,
                                        op_err_string   OUT VARCHAR2 );

  --
  --  Procedure to get conversion details based on the card part num and ESN
  PROCEDURE get_conversion_details  ( i_esn               IN    VARCHAR2  ,
                                      i_card_part_num     IN    VARCHAR2  ,
                                      o_annual_plan       OUT   NUMBER    ,
                                      o_voice_units       OUT   NUMBER    ,
                                      o_redeem_days       OUT   NUMBER    ,
                                      o_errorcode         OUT   VARCHAR2  ,
                                      o_errormessage      OUT   VARCHAR2  ,
                                      o_voice_conversion  OUT   NUMBER    ,
                                      o_redeem_text       OUT   NUMBER    ,
                                      o_redeem_data       OUT   NUMBER    ,
                                      o_service_plan_id   OUT   NUMBER ); --CR48846
  --
  -- Procedure to get service plan info details
  PROCEDURE  get_service_plan_info  ( i_brand             IN    VARCHAR2,
                                      i_esn               IN    VARCHAR2,
                                      i_card_part_num     IN    VARCHAR2,
                                      i_source_system     IN    VARCHAR2,
                                      i_channel           IN    VARCHAR2,
                                      i_language          IN    VARCHAR2,
                                      i_call_trans_objid  IN    NUMBER, --CR48846
                                      o_plan_info_rc      OUT   SYS_REFCURSOR,
                                      o_error_code        OUT   VARCHAR2,
                                      o_error_msg         OUT   VARCHAR2);
  --CR48846
  PROCEDURE  get_activation_promo_info  ( i_esn               IN  VARCHAR2,
                                          i_call_trans_objid  IN  NUMBER,
                                          o_promo_info_tab    OUT promo_info_tab,
                                          o_error_code        OUT VARCHAR2,
                                          o_error_msg         OUT VARCHAR2 );
  -- CR48846 changes ends.

  --CR54147 changes start
  FUNCTION sp_get_pin_service_plan_id( in_pin IN table_part_inst.x_red_code%TYPE )
   RETURN x_service_plan.objid%TYPE;
  --CR54147 changes end

 -- CR48260 changes starts
  PROCEDURE  get_billing_part_num ( io_part_num_list    IN OUT  part_num_mapping_tab,
                                    o_error_code        OUT     VARCHAR2,
                                    o_error_message     OUT     VARCHAR2);

  PROCEDURE  get_app_part_num    (  io_part_num_list    IN OUT part_num_mapping_tab,
                                    o_error_code        OUT    VARCHAR2,
                                    o_error_message     OUT    VARCHAR2) ;
 -- CR48260 changes end
FUNCTION get_vas_group_name (
        i_vas_service_id   IN vas_programs_view.vas_service_id%TYPE,
        i_vas_bus_org      IN vas_programs_view.vas_bus_org%TYPE
    ) RETURN vas_programs_view.vas_group_name%TYPE;

END service_plan;
/