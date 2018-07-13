CREATE OR REPLACE package sa.ADFCRM_VO
AS
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_VO_PKG.sql,v $
--$Revision: 1.57 $
--$Author: epaiva $
--$Date: 2018/01/03 17:28:25 $
--$ $Log: ADFCRM_VO_PKG.sql,v $
--$ Revision 1.57  2018/01/03 17:28:25  epaiva
--$ CR55070 - getAvailableSpPurchase NET10 Data Add On changes
--$
--$ Revision 1.56  2017/11/27 22:59:24  mmunoz
--$ Merge REL933 and HPP Asurion CR55214
--$
--$ Revision 1.55  2017/11/09 22:41:27  syenduri
--$ CR53530 - Get IG Action Item Status
--$
--$ Revision 1.54  2017/10/06 14:02:17  hcampano
--$ Fixing merge issues between WFM2_TAS and REL904_TAS
--$
--$ Revision 1.53  2017/10/05 16:48:48  hcampano
--$ CR50209 Service Plan Description in TAS
--$
--$ Revision 1.52  2017/10/02 15:36:21  mbyrapaneni
--$ Commented Lifeline Chnages for SIT1 Deployment
--$
--$ Revision 1.51  2017/09/27 15:48:34  hcampano
--$ CR50209 Service Plan Description in TAS
--$
--$ Revision 1.50  2017/07/20 14:47:16  mmunoz
--$  CR49915 Added ll_id in service_profile type
--$
--$ Revision 1.49  2017/07/03 22:06:44  hcampano
--$ CR50209 - CR50209 Service Plan Description in TAS
--$
--$ Revision 1.48  2017/06/30 15:55:55  hcampano
--$ CR50209 - Service Plan Description in TAS - REL864_TAS (added missing)
--$
--$ Revision 1.47  2017/06/30 15:15:33  hcampano
--$ CR50209 - Service Plan Description in TAS - REL864_TAS
--$
--$ Revision 1.46  2017/06/14 21:10:03  epaiva
--$ *** empty log message ***
--$
--$ Revision 1.45  2017/05/08 18:51:28  mmunoz
--$ CR49808 Tracfone Safelink Assist, added special_offer to get_service_profile_rec
--$
--$ Revision 1.44  2017/03/22 20:03:56  epaiva
--$ CR48383 changes to hide plans for  3x Removal TF
--$
--$ Revision 1.44  2017/03/17 10:51:54  epaiva
--$ CR48383: check ESN for triplebenefits before displaying Paygo plans
--$ Revision 1.43  2017/02/22 14:58:35  mmunoz
--$ CR46822  function get_payment_method with new input parameter
--$
--$ Revision 1.42  2016/12/28 15:12:29  mmunoz
--$ CR45711 : Merged with rev 1.41. Added ach_objid in get_purch_history_rec
--$
--$ Revision 1.41  2016/12/18 00:50:39  mmunoz
--$ CR42459: New field for service profile type and new function to return buckets
--$
--$ Revision 1.40  2016/11/23 15:14:32  mmunoz
--$ CR42459 : Removed function  is_past_safelink_enrolled and added columns in types
--$
--$ Revision 1.39  2016/11/04 15:01:45  mmunoz
--$ CR45711 - ACH Purchase : new function get_payment_method
--$
--$ Revision 1.38  2016/08/17 20:18:09  hcampano
--$ CR43134 - CDMA LTE Technology Display in TAS
--$
--$ Revision 1.37  2016/07/21 22:01:10  mmunoz
--$ CR44010: Added program_objid in get_service_profile_rec
--$
--$ Revision 1.36  2016/05/12 22:19:31  mmunoz
--$ CR39428 get_service_profile_rec, added stgPortTicket for idNumber external port-transaction.
--$
--$ Revision 1.35  2016/03/17 20:55:34  mmunoz
--$ CR39391 Added phone_gen in get_service_profile_rec
--$
--$ Revision 1.34  2015/10/07 19:05:48  rkatasani
--$ CR37485 - SafeLink $10 Airtime Card for FL DCF Customers
--$
--$ Revision 1.33  2015/08/27 20:19:36  mmunoz
--$ CR36553  new fields in get_service_profile_rec
--$
--$ Revision 1.32  2015/07/14 14:47:46  hcampano
--$ TAS_2015_14 - Added new pipeline function get_case_info
--$
--$ Revision 1.31  2015/07/08 21:09:00  mmunoz
--$ CR36130 Updated getAvailableSp_rec, adding column x_prog_app_part_number
--$
--$ Revision 1.30  2015/07/07 22:12:29  mmunoz
--$ CR36130 Updated getAvailableSp_rec, adding column x_prog_class
--$
--$ Revision 1.29  2015/07/06 21:12:21  hcampano
--$ TAS_2015_14 - Reworking Service Profile. Externalized has pending redemption function
--$
--$ Revision 1.28  2015/07/06 18:23:16  hcampano
--$ TAS_2015_14 - Reworking Service Profile. Converting all dates to strings.
--$
--$ Revision 1.27  2015/07/06 17:02:22  hcampano
--$ TAS_2015_14 - Reworking Service Profile. Added pending redemption CR35865. Still in progress
--$
--$ Revision 1.26  2015/06/30 21:42:53  hcampano
--$ TAS_2015_14 - Reworking Service Profile. Still in progress
--$
--$ Revision 1.21  2015/05/08 23:38:55  mmunoz
--$ CR32367 overloaded function getAvailableSpCompRepl to add ip_value parameter
--$
--$ Revision 1.20  2015/04/21 19:10:11  mmunoz
--$ CR32367 New function F_GET_REWARD_BENEFITS
--$
--$ Revision 1.19  2015/03/05 21:30:52  hcampano
--$ TAS_2015_06 - Changed Service Profile.
--$
--$ Revision 1.18  2015/03/04 22:08:29  hcampano
--$ TAS_2015_06 - Changed get_service_profile x_dateofbirth type
--$
--$ Revision 1.17  2015/03/04 16:42:18  mmunoz
--$ cr32818  added function get_sl_enrollment_details
--$
--$ Revision 1.16  2015/03/03 23:38:42  hcampano
--$ TAS_2015_06 - Changed Service Profile. externalized and deprecated method getProgramInfo, basicWarrantyVO and searchAccountVO
--$
--$ Revision 1.15  2015/02/26 23:26:50  mmunoz
--$ purch_history added group_id and group_name
--$
--$ Revision 1.14  2015/02/24 22:03:58  hcampano
--$ TAS_2015_06 - Changed Service Profile. externalized and deprecated method getProgramInfo, basicWarrantyVO and searchAccountVO
--$
--$ Revision 1.13  2015/02/10 17:30:44  mmunoz
--$ Added function getAvailableSpPurchaseBypClass
--$
--$ Revision 1.12  2015/01/29 13:38:35  hcampano
--$ TAS_2015_03 - fixing development issues on release day
--$
--$ Revision 1.11  2015/01/14 20:28:34  mmunoz
--$ CR31545 including vo for purchase history
--$
--$ Revision 1.10  2015/01/13 16:25:41  hcampano
--$ TAS_2015_03 - updates to service profile functionality
--$
--$ Revision 1.9  2015/01/13 14:25:35  hcampano
--$ TAS_2015_03 - moved enrollement datils view to pkg.
--$
--$ Revision 1.8  2015/01/05 22:05:20  mmunoz
--$ CR30968  added ADD_ON_CARD_FLAG for BRAND-X
--$
--$ Revision 1.7  2014/12/11 20:07:52  mmunoz
--$ CR30968  added number_of_lines for BRAND-X (TOTAL_WIRELESS)
--$
--$ Revision 1.6  2014/12/11 17:26:52  mmunoz
--$ CR30968  added for BRAND-X (TOTAL_WIRELESS)
--$
--$ Revision 1.5  2014/10/29 16:28:15  mmunoz
--$ CR29866 added function getSafelinkSp
--$
--$ Revision 1.4  2014/09/24 20:52:30  mmunoz
--$ Included sp_description in record type
--$
--$ Revision 1.3  2014/09/15 14:45:01  mmunoz
--$ TAS_2014_09 To Improve performance.
--$
--------------------------------------------------------------------------------------------
/****************************************************************************************
	This package has table functions that are called from adf view object
	to replace large and complex queries.
****************************************************************************************/
  type get_enrollment_details_rec is record
   (objid                    number,
    x_program_name           varchar2(40),
    pgm_enroll2x_pymt_src    number,
    x_program_desc           varchar2(1000),
    x_amount                 number,
    x_enrollment_status      varchar2(30),
    x_enroll_amount          number,
    prog_class               varchar2(10),
    pgm_enroll2pgm_parameter number,
    allowpaynow              varchar2(30),
    allow_de_enroll          varchar2(30),
    allow_re_enroll          varchar2(30),
    reversible_flag          varchar2(30),
    x_prg_script_text        varchar2(4000),  --CR32952
    x_prg_desc_script_text   varchar2(4000),  --CR32952
    make_recurrent_flag      varchar2(30) default 'false', --CR49058
    stop_recurrent_flag      varchar2(30) default 'false', --CR49058
    vas_service_id             number, --CR49058
    is_vas_flag                 varchar2(30) default 'false', --CR49058
    vas_subscription_id      number, --CR49058
    part_number               varchar2(400),  --CR49058
    is_recurring             number,   --CR49058
    request_user_info_flag   varchar2(30) default 'false' --CR49058
    );

  type get_enrollment_details_tab is table of get_enrollment_details_rec;

  type getAvailableSp_rec is record
  (objid                number,
   Mkt_Name             varchar2(400),
   SP_Description       varchar2(400),
   Description          varchar2(400),
   Customer_Price       number,
   Ivr_Plan_Id          number,
   Webcsr_Display_Name  varchar2(400),
   X_SP2PROGRAM_PARAM   number,
   X_Program_Name       varchar2(400),
   spObjid              number,
   Value_name           varchar2(400),
   part_number          varchar2(400),
   x_card_type          varchar2(400),
   units                number,
   ServicePlanType      varchar2(400),
   Service_Plan_Group   varchar2(400),
   sp_biz_line          varchar2(400),
   sp_number_of_lines   varchar2(400),
   sp_add_on_card_flag  varchar2(400),
   quantity             number,
   x_prg_script_text        varchar2(4000), --CR32952
   x_prg_desc_script_text   varchar2(4000),  --CR32952
   x_prog_class         varchar2(10), --CR36130
   x_prog_app_part_number varchar2(100), --CR36130
   org_id varchar2(200) -- CR55070
  );

  type getAvailableSp_tab is table of getAvailableSp_rec;

  --SELECT distinct Objid, Mkt_Name, Description,Customer_Price, Ivr_Plan_Id, Webcsr_Display_Name, X_SP2PROGRAM_PARAM, X_Program_Name,
  --       part_number Property_Value
  --FROM table(sa.ADFCRM_VO.getAvailableSpEnrollment(:esn,:org_id,:p_language))
  --order by customer_price
  function getAvailableSpEnrollment(
    ip_esn in varchar2,
    ip_org_id in varchar2,
    ip_language in varchar2
  )
  RETURN getAvailableSp_tab pipelined;

  --SELECT distinct Objid, Mkt_Name, Description,Customer_Price, Ivr_Plan_Id, Webcsr_Display_Name, X_SP2PROGRAM_PARAM, X_Program_Name,
  --         spobjid, value_name, part_number Property_Value, part_number property_display, x_card_type, units, ServicePlanType
  --FROM table(sa.ADFCRM_VO.getAvailableSpPurchase(:esn,:org_id,:p_language))
  --order by x_card_type desc, customer_price asc
  function getAvailableSpPurchase(
    ip_esn in varchar2,
    ip_org_id in varchar2,
    ip_language in varchar2
  )
  RETURN getAvailableSp_tab pipelined;

  function getAvailableSpPurchaseBypClass(
    ip_part_class in varchar2,
    ip_org_id in varchar2,
    ip_language in varchar2
  )
  RETURN getAvailableSp_tab pipelined;

  --SELECT distinct Objid sp_objid, Description sp_description, part_number workforce_part_number
  --FROM table(sa.ADFCRM_VO.getWorkForcePins(:esn,:org_id,:p_language,:p_type))
  --order by workforce_part_number
  function getWorkForcePins(
    ip_esn in varchar2,
    ip_org_id in varchar2,
    ip_language in varchar2,
	ip_type in varchar2
  )
  RETURN getAvailableSp_tab pipelined;


  ------------------------------------------------------------------------------
  type x_rtr_trans_rec is record
  (objid                number,
   tf_serial_num        varchar2(100),
   tf_red_code          varchar2(30),
   tf_pin_status_code   varchar2(100),
   tf_trans_date        date,
   rtr_trans_type       varchar2(40),
   tf_min               varchar2(30));

  type x_rtr_trans_tab is table of x_rtr_trans_rec;

  function get_rtr_trans_func(
    ip_min in varchar2,
    ip_serial in varchar2,
    ip_red_code in varchar2)

  return x_rtr_trans_tab pipelined;
  ------------------------------------------------------------------------------
--********************************************************************************************************************
  type getFamilySp_rec is record
  (web_user_objid       number,
   objid                number,
   Description          varchar2(400),
   display_name         varchar2(400),
   part_number          varchar2(400),
   Customer_Price       number,
   ph_count             number,
   billing_recurring_id number,
   part_number_grp      varchar2(4000),
   customer_price_grp   number,
   x_prg_script_text        varchar2(4000),  --CR32952
   x_prg_desc_script_text   varchar2(4000)  --CR32952
  );

  type getfamilysp_tab is table of getfamilysp_rec;
  ------------------------------------------------------------------------------
--********************************************************************************************************************
  type get_account_info_rec is record
  (web_user_login_name table_web_user.login_name%type,
   web_user_objid table_web_user.objid%type,
   acc_cust_id table_contact.x_cust_id%type,
   acc_contact_objid table_contact.objid%type,
   x_pin table_x_contact_add_info.x_pin%type,
   x_dateofbirth table_contact.x_dateofbirth%type,
   x_secret_questn table_web_user.x_secret_questn%type,
   x_secret_ans table_web_user.x_secret_ans%type,
   contact_objid table_contact.objid%type,
   bus_org_objid table_web_user.web_user2bus_org%type
   );

  type get_account_info_tab is table of get_account_info_rec;
  ------------------------------------------------------------------------------
--********************************************************************************************************************
  type get_service_profile_rec is record
   (part_serial_no            varchar2(30),
    x_hex_serial_no           varchar2(30),
    part_number               varchar2(30),
    description               varchar2(300), -- VARCHAR2(255 BYTE)
    technology                varchar2(30),
    technology_alt            varchar2(30), -- THIS IS TO DEFINE WHAT IS LTE, SINCE THE PHONE GEN IS NOT THE ONLY PARAM THAT DICTATES THIS
    brand                     varchar2(30),
    sequence                  number,
    dealer_id                 varchar2(80), --VARCHAR2(80 BYTE)
    dealer_name               varchar2(300), -- VARCHAR2(80 BYTE)
    phone_status              varchar2(30), -- VARCHAR2(20 BYTE)
    sim                       varchar2(30),
    sim_status                varchar2(30), -- VARCHAR2(20 BYTE)
    site_part_objid           number,
    install_date              varchar2(100), --date, -- CONVERTED TO VARCHAR2, ORGINALLY DATE FORMAT. ISSUES W/ADF NOT FORMATTING DATE. -- FIELD IS DISPLAY ONLY
    service_end_dt            varchar2(100), --date, -- CONVERTED TO VARCHAR2, ORGINALLY DATE FORMAT. ISSUES W/ADF NOT FORMATTING DATE. -- FIELD IS DISPLAY ONLY
    x_expire_dt               varchar2(100), --date, -- CONVERTED TO VARCHAR2, ORGINALLY DATE FORMAT. ISSUES W/ADF NOT FORMATTING DATE. -- FIELD IS DISPLAY ONLY
    part_status               varchar2(40), -- VARCHAR2(40 BYTE)
    x_min                     varchar2(30),
    min_status                varchar2(30), -- VARCHAR2(20 BYTE)
    carrier                   varchar2(100), -- VARCHAR2(30 BYTE) + number
    carrier_id                number,
    carrier_objid             number, --CR42459 Sl Unl.
    warr_end_date             varchar2(100), --date, -- CONVERTED TO VARCHAR2, ORGINALLY DATE FORMAT. ISSUES W/ADF NOT FORMATTING DATE. -- FIELD IS DISPLAY ONLY
    projected_end_date        varchar2(100), --date, -- CONVERTED TO VARCHAR2, ORGINALLY DATE FORMAT. ISSUES W/ADF NOT FORMATTING DATE. -- FIELD IS DISPLAY ONLY
    contact_objid             number,
    customer_id               varchar2(80), -- VARCHAR2(80 BYTE)
    first_name                varchar2(30), -- VARCHAR2(30 BYTE)
    last_name                 varchar2(30), -- VARCHAR2(30 BYTE)
    phone                     varchar2(30), -- VARCHAR2(20 BYTE)
    e_mail                    varchar2(80), -- VARCHAR2(80 BYTE)
    x_part_inst_status        varchar2(30), -- VARCHAR2(20 BYTE)
    class_name                varchar2(30),
    web_user_login_name       varchar2(50), -- VARCHAR2(50 BYTE)
    web_user_objid            number,
    x_zipcode                 varchar2(30),
    esn_objid                 number,
    x_msid                    varchar2(30), -- VARCHAR2(30 BYTE)
    cards_in_queue            number,
    warranty_exchanges        number,
    smartphone                varchar2(30),
    x_dll                     number,
    reserved_min              varchar2(30),
    hide_balance              varchar2(30),
    hide_sim                  varchar2(30),
    hide_min                  varchar2(30),
    ota_pending               varchar2(30),
    device_type               varchar2(30),
    groupid                   number,
    group_nick_name           varchar2(50),
    group_status              varchar2(30),
    group_total_devices       number,
    basic_warranty            varchar2(100),
    extended_warranty         varchar2(40),
    is_wty_recurrent_flag     varchar2(30), --CR49058
    wty_enroll_status         varchar2(30), --CR49058
    wty_next_charge_date      varchar2(100), --date --CR49058
    acc_cust_id               varchar2(80),  -- table_contact.x_cust_id varchar2(80)
    acc_contact_objid         varchar2(100), -- table_contact.objid number converting to varchar2
    x_pin                     varchar2(10),  -- table_x_contact_add_info.x_pin varchar2(6)
    x_dateofbirth             varchar2(100), --date, -- CONVERTED TO VARCHAR2, ORGINALLY DATE FORMAT. ISSUES W/ADF NOT FORMATTING DATE. -- FIELD IS DISPLAY ONLY -- table_contact.x_dateofbirth date
    x_secret_questn           varchar2(200), -- table_web_user.x_secret_questn varchar2(200)
    x_secret_ans              varchar2(200), -- table_web_user.x_secret_ans varchar2(200)
    bus_org_objid             varchar2(100), -- table_bus_org.objid number converting to varchar2
    x_policy_description      varchar2(40),  -- w3ci.table_x_throttling_policy.x_policy_description varchar2(40 byte)
    service_plan_objid        varchar2(100), -- x_service_plan.objid is the source however wrapper method outputs as varchar2
    service_type              varchar2(100), -- x_service_plan.webcsr_display_name varchar2(50) is the source however wrapper method outputs as varchar2
    program_type              varchar2(100), -- x_program_parameters.x_program_name varchar2(40) is the source however wrapper method outputs as varchar2
    program_objid             number, -- x_program_parameters.objid
    next_charge_date          varchar2(100), --date, -- CONVERTED TO VARCHAR2, ORGINALLY DATE FORMAT. ISSUES W/ADF NOT FORMATTING DATE. -- FIELD IS DISPLAY ONLY --varchar2(100), -- original was varchar, changed to date - x_program_enrolled.x_next_charge_date date
    program_units             number,        --varchar2(100), -- original was varchar, changed to number - validate this value remove when complete
    program_days              number,        --varchar2(100), -- original was varchar, changed to number - validate this value remove when complete
    rate_plan                 varchar2(100),  -- table_x_carrier_features.x_rate_plan%type varchar2(60)
    x_prg_script_text        varchar2(4000),  --CR32952
    x_prg_desc_script_text   varchar2(4000),  --CR32952
    adf_next_charge_date     varchar2(100), --date, -- CONVERTED TO VARCHAR2, ORGINALLY DATE FORMAT. ISSUES W/ADF NOT FORMATTING DATE. -- FIELD IS DISPLAY ONLY -- REPLACES THE NEXT CHARGE DATE WE DISPLAY IN TAS #{(pageFlowScope.CardsInQueue eq "0")? pageFlowScope.NextChargeDate : pageFlowScope.ProjectedEndDate}
    adf_next_refill_date     varchar2(100), --date, -- CONVERTED TO VARCHAR2, ORGINALLY DATE FORMAT. ISSUES W/ADF NOT FORMATTING DATE. -- FIELD IS DISPLAY ONLY -- REPLACES THE NEXT REFILL DATE WE DISPLAY IN TAS #{(pageFlowScope.sl_enrollment_status eq  'ENROLLED')? pageFlowScope.sl_next_delivery_date: pageFlowScope.XExpireDt}
    sl_enrollment_status     varchar2(4000),  -- SAFELINK NEW STUFF
    sl_program_name          varchar2(4000),  -- SAFELINK NEW STUFF
    sl_current_enrolled      varchar2(4000),  -- SAFELINK NEW STUFF
    sl_deenroll_reason       varchar2(4000),  -- SAFELINK NEW STUFF
    sl_lifeline_status       varchar2(4000),  -- SAFELINK NEW STUFF
    sl_verify_dd             varchar2(4000),  -- SAFELINK NEW STUFF
    sl_verify_latestd        varchar2(4000),  -- SAFELINK NEW STUFF
    sl_new_plan_effect       varchar2(4000),  -- SAFELINK NEW STUFF
    sl_next_delivery_date    varchar2(4000),  -- SAFELINK NEW STUFF
    lid                      varchar2(4000),  -- SAFELINK NEW STUFF
    ll_id                      varchar2(4000),  -- Lifeline for Other Brands / NO Safelink
    redemption_pending       varchar2(5),
    minutes_type varchar2(20),   --CR36553 Minutes Type : Regular Minutes / Double Minutes / Triple Minutes
    lease_status_flag varchar2(10),  --CR36553 Leased to Better Finance : Yes / No
    lease_status_name varchar2(30), --CR36553 Lease status Name : Review / Approved ..etc
    port_in_progress varchar2(10), --CR36553
    phone_gen varchar2(30),  -- Added by kvara to get Phone Gen - Part Class Parameter.
    stgPortTicket varchar2(255), --CR39428 idNumber for external port transaction.
    service_order_stage varchar2(255),  --CR42459 Tracfone Safelink Unlimited
    special_offer varchar2(255),  --To identify customers with special offer like Tracfone Safelink Assist (CR49808)
    sp_carry_over               varchar2(100), -- CR50209
    sp_script_id                varchar2(30), -- CR50209
    sp_script_text              varchar2(4000), -- CR50209
    sp_addl_script_text         varchar2(4000), -- CR50209
    sp_cos_value                varchar2(30), -- CR50209
    sp_threshold_value          varchar2(30), -- CR50209
    subscriber_cos_value        varchar2(30), -- CR50209
    subscriber_threshold_value  varchar2(30),  -- CR50209
    action_item_status				  varchar2(100)  -- CR53530
    );

  type get_service_profile_tab is table of get_service_profile_rec;
  ------------------------------------------------------------------------------
--********************************************************************************************************************
  --select distinct web_user_objid wu_objid,serv_plan_objid objid, description, display_name, part_number,
  --                customer_price, ph_count, billing_recurring_id, part_number_grp, customer_price_grp
  --from table(sa.ADFCRM_VO.getFamilyPlan(:web_user_id,:org_id,:p_language))
  function getFamilyPlan(
    ip_web_user_id in varchar2,
    ip_org_id in varchar2,
    ip_language in varchar2
  )
  RETURN getFamilySp_tab pipelined;

--********************************************************************************************************************
  --SELECT distinct Objid, Mkt_Name, Description,Customer_Price, Ivr_Plan_Id, Webcsr_Display_Name, X_SP2PROGRAM_PARAM, X_Program_Name,
  --         spobjid, value_name, part_number Property_Value, part_number property_display
  --from table(sa.ADFCRM_VO.getAvailableSpCompRepl(:esn,:org_id,:p_language))
  function getAvailableSpCompRepl(
    ip_esn in varchar2,
    ip_org_id in varchar2,
    ip_language in varchar2
  )
  RETURN getAvailableSp_tab pipelined;
--********************************************************************************************************************
  function getAvailableSpCompRepl(
    ip_esn in varchar2,
    ip_org_id in varchar2,
    ip_language in varchar2,
    ip_value in varchar2 -- CR32367
  )
  RETURN getAvailableSp_tab pipelined;
--********************************************************************************************************************
  --SELECT distinct Objid, Mkt_Name, Description,Customer_Price, Ivr_Plan_Id, Webcsr_Display_Name, X_SP2PROGRAM_PARAM, X_Program_Name,
  --         spobjid, value_name, part_number Property_Value, part_number property_display
  --from table(sa.ADFCRM_VO.getAvailableSpAWOP(:esn,:org_id,:p_language))
  function getAvailableSpAWOP(
    ip_esn in varchar2,
    ip_org_id in varchar2,
    ip_language in varchar2
  )
  RETURN getAvailableSp_tab pipelined;

--********************************************************************************************************************
  --SELECT *
  --FROM table(sa.ADFCRM_VO.getSafelinkSp(ip_esn,ip_org_id,p_language))
  --order by customer_price
  function getSafelinkSp (
    ip_esn in varchar2,
    ip_org_id in varchar2,
    ip_language in varchar2
  )
  RETURN getAvailableSp_tab pipelined;

--********************************************************************************************************************
  --SELECT *
  --FROM table(sa.ADFCRM_VO.get_enrollment_details(ip_esn,p_language))
  --
  function get_enrollment_details (
    ip_esn in varchar2,
    ip_language in varchar2 -- EN ES
  )
  return get_enrollment_details_tab pipelined;

--********************************************************************************************************************
  --SELECT *
  --FROM table(sa.ADFCRM_VO.get_sl_enrollment_details(ip_esn,ip_lid,p_language))
  --
  function get_sl_enrollment_details (
    ip_esn in varchar2,
    ip_lid in varchar2,
    ip_language in varchar2 -- EN ES
  )
  return get_enrollment_details_tab pipelined;

--********************************************************************************************************************

  function has_pending_redemption (ip_esn varchar2)
  return varchar2;

--********************************************************************************************************************
  --SELECT *
  --FROM table(sa.ADFCRM_VO.get_service_profile(ip_esn))
  --
  function get_service_profile (ip_part_serial_no in varchar2, ip_language in varchar2)
  return get_service_profile_tab pipelined;

--********************************************************************************************************************
  --SELECT *
  --FROM table(sa.ADFCRM_VO.get_account_info(ip_contact_objid))
  --
  function get_account_info(ip_contact_objid in varchar2)
  return get_account_info_tab pipelined;

--********************************************************************************************************************
  type get_purch_history_rec is record
   (esn                 varchar2(400),
    cc_lastfour         varchar2(10),
    acct_lastfour       varchar2(10),
    cc_objid            number,
    ach_objid           number,  --CR45711
    cc_type             varchar2(400),
    aba_transit         varchar2(400),
    transaction_id      varchar2(400),
    price               number,
    discounts           number,
    sales_tax           number,
    e911_tax            number,
    usf_tax             number,
    rcrf_tax            number,
    amount              number,
    transaction_date    date,
    status              varchar2(400),
    promo_sponsor       varchar2(400),
    details             varchar2(4000),
    payment_type        varchar2(400),
    s_login_name        varchar2(400),
    channel             varchar2(400),
    vendor              varchar2(400),
    product             varchar2(400),
    group_id            varchar2(400),
    group_name          varchar2(400)
    );

  type get_purch_history_tab is table of get_purch_history_rec;

--********************************************************************************************************************
/*  SELECT  esn x_esn,
    cc_lastfour,
    acct_lastfour,
    cc_objid,
    cc_type x_cc_type,
    aba_transit x_aba_transit,
    transaction_id,
    price,
    discounts,
    sales_tax,
    e911_tax,
    usf_tax,
    rcrf_tax,
    amount,
    transaction_date transactiondate,
    status,
    promo_sponsor  x_promo_sponsor,
    details,
    payment_type,
    s_login_name,
    channel,
    vendor,
    product
    FROM table(sa.ADFCRM_VO.get_purch_history_by_esn(ip_esn))
  -- uc040
  */
  function get_purch_history_by_esn (ip_esn in varchar2)
  return get_purch_history_tab pipelined;

--********************************************************************************************************************
  --SELECT *
  --FROM table(sa.ADFCRM_VO.get_purch_history_by_acct(ip_contact_objid))
  -- uc060
  function get_purch_history_by_acct (ip_contact_objid in varchar2)
  return get_purch_history_tab pipelined;

--********************************************************************************************************************
  type get_esn_contact_flashes_rec is record
   (part_serial_no table_part_inst.part_serial_no%type,
    title          table_alert.title%type,
    alert_text     clob,
    hot            table_alert.hot%type,
    objid          table_alert.objid%type,
    flash_src      varchar2(50)
    );

  type get_esn_contact_flashes_tab is table of get_esn_contact_flashes_rec;
--********************************************************************************************************************
  --SELECT *
  --FROM table(sa.ADFCRM_VO.get_esn_contact_flashes(ip_esn))
  -- uc060
  function get_esn_contact_flashes (ip_esn in varchar2)
  return get_esn_contact_flashes_tab pipelined;
--********************************************************************************************************************
  --SELECT *
  --FROM table(sa.ADFCRM_VO.F_GET_REWARD_BENEFITS(
--             IN_KEY => 'ESN' --'ESN', 'MIN', 'SID', 'ACCOUNT'
--            ,IN_VALUE => '100000000013491913'
--            ,IN_PROGRAM_NAME => 'UPGRADE_PLANS'
--            ,IN_BENEFIT_TYPE => 'UPGRADE_BENEFITS'));
/** commented until merge TAS_2015_10
  function F_GET_REWARD_BENEFITS (
             IN_KEY                     IN VARCHAR2
            ,IN_VALUE                   IN VARCHAR2
            ,IN_PROGRAM_NAME            IN VARCHAR2
            ,IN_BENEFIT_TYPE            IN VARCHAR2 )
  return REWARD_BENEFITS_TAB pipelined;
commented until merge TAS_2015_10**/
--********************************************************************************************************************
  --CR32952 new types get_program_rec,get_program_tab  and function getEligibleWtyPrograms
--********************************************************************************************************************
  type get_program_rec is record
   (objid                    number,
    x_program_name           varchar2(40),
    x_program_desc           varchar2(1000),
    x_retail_price           number,
    x_prg_script_text        varchar2(4000),
    x_prg_desc_script_text   varchar2(4000)
    );

  type get_program_tab is table of get_program_rec;

  function getEligibleWtyPrograms (
    ip_esn in varchar2,
    ip_language in varchar2 -- EN ES
  )
  return get_program_tab pipelined;

  ------------------------------------------------------------------------------
  type get_case_info_rec is record
   (objid number,
    title_label varchar2(300),
    id_number varchar2(255),
    service_plan_id varchar2(200),
    service_plan varchar2(200),
    minutes number,
    data_units number,
    sms_units number,
    days number
    );

  type get_case_info_tab is table of get_case_info_rec;

  function get_case_info (ip_case_id in varchar2)
  return get_case_info_tab pipelined;
  ------------------------------------------------------------------------------
    type get_payment_method_rec is record
    (   pymt_src_objid number,
        pymt_src_name varchar2(255),
        pymt_src_type varchar2(255),
        pymt_src_status varchar2(255),
        pymt_src_email varchar2(255),
        pymt_src_default varchar2(255),
        pymt_method_objid number,
        pymt_method_secure_num varchar2(255),
        pymt_method_number varchar2(255),
        pymt_method_type varchar2(255),
        pymt_method_status varchar2(255),
        max_purch_amt number,
        expmo varchar2(255),
        expyr varchar2(255),
        exp_date varchar2(255),
        first_name varchar2(255),
        last_name varchar2(255),
        phone varchar2(255),
        email varchar2(255),
        address_objid number,
        address varchar2(255),
        address2 varchar2(255),
        zipcode varchar2(255),
        city varchar2(255),
        state varchar2(255),
        country varchar2(255),
        change_date date,
        original_insert_date date,
        is_new_pymt varchar2(50)
    );

    type get_payment_method_tab is table of get_payment_method_rec;

    function get_payment_method (
    ip_web_user_objid in varchar2,
    ip_contact_objid in varchar2,
    ip_transaction_type in varchar2 default 'PURCHASE'  --PURCHASE, ENROLLMENT
    )
    return get_payment_method_tab pipelined;

    function get_payment_method (
    --CR46822 TAS Credit Card Modifications
        ip_web_user_objid in varchar2,
        ip_contact_objid in varchar2,
        ip_transaction_type in varchar2 default 'PURCHASE',  --PURCHASE, ENROLLMENT,
        ip_cc_objid in varchar2
    )
    return get_payment_method_tab pipelined;

  --CR42459
  type get_buckets_rec is record
   (objid number,
    description varchar2(100),
    org_id  varchar2(100),
    service_plan_group  varchar2(100),
    action  varchar2(100),
    metering varchar2(100),
    voice varchar2(100),
    sms  varchar2(100),
    data varchar2(100),
    serv_plan varchar2(100),
    days varchar2(4000)
    );

  type get_buckets_tab is table of get_buckets_rec;

    function get_buckets (
        ip_esn in varchar2,
        ip_org_id in varchar2,
        ip_service_plan_id in varchar2 default '-1',
        ip_action in varchar2 default 'COMPENSATION',
        ip_type in varchar2 default '3', --1 Reference ESN, 2 Reference Pin, 3 Open Access
        ip_language in varchar2 default 'en'
    )
    return get_buckets_tab pipelined;
  --CR48383 to find whether ESN is blocked for triple benefits
    function get_EsnTripleBenefit (
    ip_esn in varchar2
    )
    return varchar2;


	  ---CR48491 TAS Throttling info
  type get_throttle_rec is record
  (x_throttle_desc        varchar2(1000),
   x_throttle_date        date,
   x_redemption_date      date,
   x_agent_msg   varchar2(1000));

  type get_throttle_rec_tab is table of get_throttle_rec;

  function get_throttle_func(
    ip_esn in varchar2,
    ip_lang in varchar2)
  return get_throttle_rec_tab pipelined;

  --CR50209
  procedure get_sp_info(
                        ip_part_class varchar2,
                        ip_min varchar2,
                        ip_spobjid varchar2,
                        ip_bus_org_objid varchar2,
                        op_sp_carry_over out varchar2,
                        op_script_id out varchar2,
                        op_sp_script_text out varchar2, -- MAIN SCRIPT TO SHOW
                        op_sp_addl_script_text out varchar2, -- IF THE SP'S COS DOES NOT MATCH THE MIN'S COS - SCRIPT TO SHOW
                        op_sp_cos_value out varchar2, -- SP COS
                        op_sp_threshold_value out varchar2, -- SP THRESHOLD VALUE
                        op_subscriber_cos_value out varchar2, -- MIN COS
                        op_subscriber_threshold_value out varchar2 -- MIN'S THRESHOLD VALUE
                        );


END ADFCRM_VO;
/