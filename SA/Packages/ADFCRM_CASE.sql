CREATE OR REPLACE PACKAGE sa."ADFCRM_CASE" is
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_CASE_PKG.sql,v $
--$Revision: 1.33 $
--$Author: syenduri $
--$Date: 2018/05/10 15:49:47 $
--$ $Log: ADFCRM_CASE_PKG.sql,v $
--$ Revision 1.33  2018/05/10 15:49:47  syenduri
--$ Merge REL956 version into REL957
--$
--$ Revision 1.31  2018/04/27 19:58:40  syenduri
--$ CR56717 - Removed IN Param for GENERATE_ORDER_ID
--$
--$ Revision 1.30  2018/04/26 22:06:40  pkapaganty
--$ CR57442 Update Cases Not to Reopen
--$ Added logic to Case reopen to use the flags X_BLOC_REOPEN and X_REOPEN_DAYS_CHECK
--$
--$ Revision 1.29  2018/04/13 21:09:58  syenduri
--$ CR56717 - TAS Overnight Ship Exchange Option
--$
--$ Revision 1.28  2018/02/28 22:43:15  pkapaganty
--$ CR53035 All Brands  TAS   General Information interactions without an Account
--$ Updated create_interaction3 to accept brand.
--$
--$ Revision 1.27  2017/12/06 13:48:40  pkapaganty
--$ CR54891 TAS Case Reopen Restriction Logic
--$     Created a new procedure to check if case can be created based on esn and case type,title details. It will check for existing case on ESN and see if it can be reopened.
--$
--$ Revision 1.26  2017/11/03 18:01:49  nguada
--$ REL932_TAS
--$
--$ Revision 1.25  2017/11/03 17:59:15  nguada
--$ CR54247
--$
--$ Revision 1.24  2017/09/27 16:32:31  mmunoz
--$ CR52928 : New function is_fraud_detected
--$
--$ Revision 1.23  2017/06/26 16:57:38  pkapaganty
--$ CR49310
--$
--$ Revision 1.22  2017/05/18 15:02:03  mmunoz
--$ CR49638 Enforce Carriersimpref Validation, CR49600 Block Sprint SIM Exchange
--$
--$ Revision 1.21  2017/04/05 16:59:45  nguada
--$ CR45121 TAS Technology Exchange UnableUnable case enhancements
--$
--$ Revision 1.20  2016/09/13 13:58:33  mmunoz
--$ CR42725 New procedure upd_case_detail_flag
--$
--$ Revision 1.19  2015/08/12 22:20:52  nguada
--$ overload create_case
--$
--$ Revision 1.18  2015/08/07 20:13:07  nguada
--$ Interaction Improvements
--$
--$ Revision 1.16  2015/04/27 20:37:40  hcampano
--$ Merged TAS_2015_09 + 10 Changes
--$ ==============================================
--$ Target dates not confirmed between the two branches, but, this includes both changes
--$ CR32367 - SIMPLE Mobile and NET10 Upgrade Plans Phase II (MASTER)
--$
--$ Revision 1.15  2015/04/27 14:16:07  mmunoz
--$ New procedure create_case for CR32682
--$
--$ Revision 1.14  2014/12/01 19:12:16  hcampano
--$ TAS_2014_11 - Rewards Points
--$
--$ Revision 1.13  2014/10/17 21:22:39  mmunoz
--$ CR 30728 a?? Added logic to check if warranty exchange case already exists
--$
--$ Revision 1.12  2014/09/22 21:43:25  nguada
--$ TAS_2014_09 changes.
--$
--$ Revision 1.11  2014/08/22 15:22:11  nguada
--$ update repl units function added.
--$
--------------------------------------------------------------------------------------------
   function check_carriersimpref (phone_part_number in varchar2, sim_part_number in varchar2)
   return varchar2; --CR49638 CR49600

   --New function is_fraud_detected CR52928 Block Shipments to Fraud related addresses
   function is_fraud_detected (p_case_objid number)
   return varchar2;

   function getWtyExchangeCase (p_esn varchar2) return varchar2; --CR30728

   function isWtyExchangeEligible (p_esn in varchar2
                                  ,p_case_conf_objid in varchar2
                                  ,p_case_title in varchar2
								  ,p_case_type in varchar2) return varchar2;

  function accept_case (case_objid in varchar2,
                               user_objid in varchar2,
                               wipbin_objid in varchar2) return varchar2;

  function add_case_dtl_records (p_case_id in varchar2) return varchar2;

  function assign_case (p_user_objid in varchar2,
                               p_login_name in varchar2,
                               p_case_objid in varchar2,
                               p_case_id in varchar2) return varchar2;

  function call_1052 (esn in varchar2,
                             error in varchar2 ,
                             user_objid in varchar2) return varchar2;

  function can_accept (case_objid in varchar2,
                              user_objid in varchar2,
                              owner_objid in varchar2,
                              queue_objid in varchar2,
                              condition in varchar2) return varchar2;

  function case_forward (case_objid in varchar2,
                                user_objid in varchar2,
                                queue_objid in varchar2,
                                queue_title in varchar2,
                                reason in varchar2) return varchar2;

  function case_return_to_sender (case_objid in varchar2,
                                         user_objid in varchar2,
                                         reason in varchar2) return varchar2;

  function case_yank (case_objid in varchar2,
                             user_objid in varchar2) return varchar2;

  function close_case (p_case_objid varchar2,
                              p_user_objid varchar2,
                              p_resolution varchar2,
                              p_status varchar2,
                              p_notes varchar2) return varchar2;

  function close_case_in_bulk(ip_user_name varchar2,
                                     ip_reason varchar2,
                                     ip_case_id_str varchar2) return varchar2;

  function close_ind_task(ip_task_objid number,
                                 ip_user varchar2) return varchar2;

  function  create_case (p_case_type varchar2,
                                p_case_title varchar2,
                                p_case_status varchar2,
                                p_case_priority varchar2,
                                p_case_source varchar2,
                                p_case_poc varchar2,
                                p_case_issue varchar2,
                                p_contact_objid varchar2,
                                p_first_name varchar2,
                                p_last_name varchar2,
                                p_user_objid varchar2,
                                p_esn varchar2,
                                p_case_part_req varchar2,
                                p_case_notes varchar2) return varchar2;

  function  create_case (p_case_type varchar2,
                                p_case_title varchar2,
                                p_case_status varchar2,
                                p_case_priority varchar2,
                                p_case_source varchar2,
                                p_case_poc varchar2,
                                p_case_issue varchar2,
                                p_contact_objid varchar2,
                                p_first_name varchar2,
                                p_last_name varchar2,
                                p_user_objid varchar2,
                                p_esn varchar2,
                                p_case_part_req varchar2,
                                p_case_notes varchar2,
                                p_case_details varchar2) return varchar2;

  function create_case_wo_account (p_case_conf_objid varchar2,
                                          p_case_issue varchar2,
                                          p_source varchar2,
                                          p_first_name varchar2,
                                          p_last_name varchar2,
                                          p_phone varchar2,
                                          p_email varchar2,
                                          p_brand varchar2,
                                          p_user_objid varchar2,
                                          p_case_notes varchar2,
                                          p_case_details varchar2) return varchar2;

  function create_interaction(p_c_objid number,
                                     p_reason_objid number,
                                     p_detail_objid number,
                                     p_notes varchar2,
                                     p_rslt number,
                                     p_user varchar2,
                                     p_esn  varchar2) return varchar2;

  function create_interaction2(p_c_objid number,
                                     p_reason varchar2,
                                     p_detail varchar2,
                                     p_notes varchar2,
                                     p_rslt varchar2,
                                     p_user varchar2,
                                     p_esn  varchar2) return varchar2;

  function create_interaction3(p_c_objid number,
                                     p_reason varchar2,
                                     p_detail varchar2,
                                     p_notes varchar2,
                                     p_rslt varchar2,
                                     p_user varchar2,
                                     p_esn  varchar2,
                                     p_channel varchar2,
									 p_brand varchar2) return varchar2;

  function create_sim_case (p_user_objid varchar2,
                                   p_esn varchar2,
                                   p_phone_model varchar2,
                                   p_sim_profile varchar2,
                                   p_contact_objid varchar2,
                                   p_issue varchar2) return varchar2;

  procedure get_repl_part_number (ip_case_conf_objid in varchar2,
                                         ip_case_type       in varchar2,
                                         ip_title           in varchar2,
                                         ip_esn             in varchar2,
                                         ip_sim             in varchar2,
                                         ip_repl_logic      in out varchar2, -- NULL, NAP_DIGITAL,  DEFECTIVE_PHONE, DEFECTIVE_SIM, GOODWILL
                                         ip_zipcode         in out varchar2,
                                         op_part_number out varchar2,
                                         op_sim_profile out varchar2,
                                         op_sim_suffix out varchar2);

  function log_task_note(ip_task_objid number,
                                ip_note_title varchar2,
                                ip_note_detail varchar2,
                                ip_user varchar2) return varchar2;

  function logistics_batch_update (ip_user     varchar2,
                                          ip_rec_type varchar2) return varchar2;

  function part_request_ship (case_objid in varchar2,
                                     user_objid in varchar2) return varchar2;

  function validate_part_request (p_pr_objid in varchar2,
                                         p_part_number in varchar2,
                                         p_serial_number in varchar2,
                                         p_ff_center in varchar2,
                                         p_courier in varchar2,
                                         p_method in varchar2,
                                         p_tracking in varchar2) return varchar2;

  FUNCTION IS_REFURB_ESN (IP_ESN IN VARCHAR2) RETURN NUMBER;

  procedure update_reopen_whcase_prc(ipv_case_id         varchar2,
                                     ipv_user_objid      varchar2,
                                     ipv_new_status      varchar2,
                                     opv_error_no   out  varchar2,
                                     opv_error_str  out  varchar2);
--------------------------------------------------------------------------------
-- CR27873 -- START DISPLAY CORRECT EXCHANGE OPTIONS FOR EXCHANGE CASES
--------------------------------------------------------------------------------
  type replacement_part_num_ty is record(inventory_type varchar2(100),
                                         part_number varchar2(100),
                                         technology varchar2(100),
                                         brand varchar2(100),
                                         airbill varchar2(100),
                                         domain varchar2(100));

  type tab_replacement_part_num is table of replacement_part_num_ty;

  replacement_part_num_reslt replacement_part_num_ty;
--------------------------------------------------------------------
  function avail_repl_part_num (ip_case_header_domain varchar2,
                                ip_esn varchar2)
  return tab_replacement_part_num pipelined;
--------------------------------------------------------------------
  function avail_repl_part_num (ip_case_type varchar2,
                                ip_case_title varchar2,
                                ip_esn varchar2)
  return tab_replacement_part_num pipelined;
--------------------------------------------------------------------------------
-- CR27873 -- END DISPLAY CORRECT EXCHANGE OPTIONS FOR EXCHANGE CASES
--------------------------------------------------------------------------------
   procedure updateShippingAddress (
                            p_contact_objid varchar2,
                            p_case_id varchar2,
                            p_add_1 in varchar2,
                            p_add_2 in varchar2,
                            p_city in varchar2,
                            p_st in varchar2,
                            p_zip in varchar2,
                            p_country in varchar2,
                            p_err_code out varchar2,
                            p_err_msg  out varchar2

   );

--------------
-- TAS_2014_07
--------------
function update_replacement_units (p_case_id varchar2) return varchar2;

--------------
-- TAS_2014_09
--------------
function get_orgid_from_case (p_case_id varchar2) return varchar2;

function get_esn_from_case (p_case_id varchar2) return varchar2;


--------------
--TAS_2014_11
--------------
function compensate_reward_points (ip_esn  varchar2,
                                   ip_action varchar2,
                                   ip_points varchar2,
                                   ip_service_plan_objid varchar2,
                                   ip_reason varchar2,
                                   ip_notes varchar2,
                                   ip_contact_objid varchar2,
                                   ip_user_objid varchar2) return varchar2;

-----------------------------------------------------------------------------------------------------------------------------
--New procedure create_case for CR32682
-----------------------------------------------------------------------------------------------------------------------------
  procedure create_case (p_case_type in varchar2,
                                p_case_title in varchar2,
                                p_case_status in varchar2,
                                p_case_priority in varchar2,
                                p_case_source in varchar2,
                                p_case_poc in varchar2,
                                p_case_issue in varchar2,
                                p_contact_objid in varchar2,
                                p_first_name in varchar2,
                                p_last_name in varchar2,
                                p_user_objid in varchar2,
                                p_esn in varchar2,
                                p_case_part_req in varchar2,
                                p_case_notes in varchar2,
                                p_phone in varchar2,
                                p_email in varchar2,
                                p_addr in varchar2,
                                p_city in varchar2,
                                p_country in varchar2,
                                p_st in varchar2,
                                p_zip in varchar2,
                                op_id_number out varchar2,
                                op_error_num out varchar2,
                                op_error_msg out varchar2);

-----------------------------------------------------------------
--CR42725 New procedure upd_case_detail_flag
procedure upd_case_detail_flag(ip_id_number varchar2, ip_user_objid varchar2);

FUNCTION isESNSubsidyEligible(p_esn             IN VARCHAR2) return varchar2;

PROCEDURE fetchExistingCaseObjId(
    p_case_conf_id IN VARCHAR2,
    p_case_type  IN VARCHAR2,
    p_case_title IN VARCHAR2,
    p_esn        IN VARCHAR2,
    op_case_obj_id OUT VARCHAR2,
	op_case_id_num OUT VARCHAR2,
    op_error_num OUT VARCHAR2,
    op_error_msg OUT VARCHAR2);

PROCEDURE can_create_case(
    p_case_objid IN VARCHAR2,
    p_case_type  IN VARCHAR2,
    p_case_title IN VARCHAR2,
    p_esn        IN VARCHAR2,
    op_can_create_case OUT VARCHAR2,
    op_case_id OUT VARCHAR2,
    op_error_num OUT VARCHAR2,
    op_error_msg OUT VARCHAR2);

-------------------------------------------------------------------------------------
-- CR56717 - TAS Overnight Ship Exchange Option
-------------------------------------------------------------------------------------
FUNCTION delivery_date_calculation(
    ip_business_days IN INTEGER,
    ip_date_format   IN VARCHAR2)
  RETURN VARCHAR2;
-------------------------------------------------------------------------------------
type exchange_shipping_options_rec
IS
  record
  (
    shipping_category VARCHAR2(20),
    shipping_option   VARCHAR2(1000));
type exch_shipping_options_tab
IS
  TABLE OF exchange_shipping_options_rec;
  FUNCTION exchange_shipping_options(
      ip_domain_type          IN VARCHAR2,
      ip_is_address_po_box    IN VARCHAR2,
      ip_delivery_date_format IN VARCHAR2)
    RETURN exch_shipping_options_tab pipelined;
-------------------------------------------------------------------------------------
FUNCTION generate_order_id
  RETURN VARCHAR2;
-------------------------------------------------------------------------------------

FUNCTION clean_text_to_compare(
    p_text VARCHAR2)
  RETURN VARCHAR2;


end adfcrm_case;
/