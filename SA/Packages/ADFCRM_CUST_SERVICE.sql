CREATE OR REPLACE PACKAGE sa."ADFCRM_CUST_SERVICE" is
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_CUST_SERVICE_PKG.sql,v $
--$Revision: 1.34 $
--$Author: mmunoz $
--$Date: 2018/01/09 14:23:16 $
--$ $Log: ADFCRM_CUST_SERVICE_PKG.sql,v $
--$ Revision 1.34  2018/01/09 14:23:16  mmunoz
--$ CR53924 TAS Identity Challenge Page Clean up, merged with prod. 1.31
--$
--$ Revision 1.31  2017/12/07 17:10:52  epaiva
--$ CR54687 Workforce pins status changes for paygo and non paygo plans
--$
--$ Revision 1.30  2017/10/10 14:14:35  syenduri
--$ Merge REL902 changes into REL904
--$
--$ Revision 1.29  2017/10/05 15:03:41  syenduri
--$ CR52306 - Customer Purchase confirmation for TAS Transactions
--$
--$ Revision 1.28  2017/09/29 20:27:38  syenduri
--$ CR52306 Customer Purchase confirmation for TAS Transactions
--$
--$ Revision 1.27  2017/09/13 23:34:00  syenduri
--$ CR50956 - Workforce Pin Changes
--$
--$ Revision 1.25  2017/07/26 18:11:47  mmunoz
--$ CR49354 Function IS_SUREPAY_TECH_CASE overloaded, new parameter ip_transfer_min
--$
--$ Revision 1.24  2016/05/23 18:14:16  nguada
--$ CR42611
--$
--$ Revision 1.23  2015/01/29 21:04:25  hcampano
--$ TAS_2015_05 - CR30854 - Hotspot Z289L TAS Upgrades
--$
--$ Revision 1.22  2014/11/21 15:08:28  nguada
--$ is_sp_enrollment_compatible modified to use canenroll from billing.
--$
--$ Revision 1.21  2014/10/23 22:13:24  hcampano
--$ TAS_2014_09B
--$
--$ Revision 1.20  2014/10/23 20:19:43  hcampano
--$ TAS_2014_9B
--$
--$ Revision 1.19  2014/10/22 20:55:47  hcampano
--$ TAS_2014_10A
--$
--$ Revision 1.18  2014/10/15 22:15:37  nguada
--$   procedure comp_threshold added.
--$
--$ Revision 1.17  2014/09/18 14:04:20  hcampano
--$ TAS_2014_08B - Handset release 9/25
--$
--$ Revision 1.16  2014/09/16 18:14:45  nguada
--$ cross carrier sim change keep min
--$
--$ Revision 1.15  2014/09/06 00:36:01  mmunoz
--$ added procedure cross_carrier_sim_change
--$
--$ Revision 1.14  2014/07/31 13:32:18  hcampano
--$ TAS_2014_06 - Changes to PromoPinTool
--$
--$ Revision 1.13  2014/07/24 13:14:59  hcampano
--$ TAS_2014_06 - PinPromoTool
--$
--$ Revision 1.12  2014/07/22 13:28:53  nguada
--$ Hide Balance added.
--$
--$ Revision 1.11  2014/07/16 17:01:45  hcampano
--$ 7/2014 TAS release (TAS_2014_06) validate_promo_tool. CR29272
--$
--$ Revision 1.10  2014/06/30 14:20:36  mmunoz
--$ Added function UPD_PORT_IN_FLAG
--$
--$ Revision 1.9  2014/06/17 15:32:03  nguada
--$ new function added block_promo_esn_upgrade
--$
--$ Revision 1.8  2014/05/21 18:19:15  hcampano
--$ added sp_enrollment_compatible func
--$
--$ Revision 1.7  2014/05/09 16:51:04  mmunoz
--$ Added function hide_sim
--$
--$ Revision 1.6  2014/05/06 20:09:01  mmunoz
--$ TAS_2014_03
--$
--$ Revision 1.5  2014/05/05 15:08:21  mmunoz
--$ New functions is_manual_code_required and min_by_esn
--$
--$ Revision 1.4  2014/03/14 17:37:01  mmunoz
--$ CR26941
--$
--$ Revision 1.3  2014/02/18 20:00:02  hcampano
--$ Adding workforce ild pin function
--$
--$ Revision 1.2  2013/12/16 15:32:20  nguada
--$ CR26679
--$
--$ Revision 1.1  2013/12/06 19:46:30  mmunoz
--$ CR26679  TAS Various Enhancments
--$
--------------------------------------------------------------------------------------------

  function end_promo (p_promo_objid number) return varchar2;

  function esn_by_min(p_min in varchar2) return varchar2;

  function min_by_esn(p_esn in varchar2) return varchar2;

  function esn_by_sim (sim in varchar2) return varchar2;

  function esn_type(p_esn in varchar2) return varchar2;

  function hide_min(p_esn in varchar2) return varchar2;

  function allow_access_to_hot_spot(ip_esn in varchar2) return varchar2;

  function hide_balance(p_esn in varchar2) return varchar2;

  function hide_sim(p_esn in varchar2) return varchar2;

  function flash_alerts (p_action varchar2,
                                p_flash_objid number,
                                p_alert_text varchar2,
                                p_start_date varchar2,
                                p_end_date varchar2,
                                p_active number, -- 1 active, 0 inactive
                                p_title varchar2,
                                p_hot number, -- 1 yes, 0 no
                                p_u_objid number,
                                p_c_objid number,
                                p_x_web_text_en varchar2,
                                p_x_web_text_es varchar2) return varchar2;

  function get_byop_reg_pn (p_org_id in varchar2) return varchar2;

  function get_msl (ip_esn varchar2) return varchar2;

  function has_ota_cdma_pending (ip_esn varchar2) return varchar2;

  function is_phone_safelink (ip_esn varchar2) return number;

  function is_sp_compatible (sp_objid varchar2, part_class varchar2) return number;

  function is_sp_enrollment_compatible (ip_esn varchar2, ip_new_esn varchar2) return number;

  function is_surepay_tech_case(ip_str_old_esn varchar2,
                                       ip_str_new_esn varchar2,
                                       ip_str_new_sim varchar2,
                                       ip_str_zip varchar2,
                                       ip_language varchar2) return varchar2;
--OVERLOADED FOR CR49354
  function is_surepay_tech_case(ip_str_old_esn varchar2,
                                       ip_str_new_esn varchar2,
                                       ip_str_new_sim varchar2,
                                       ip_str_zip varchar2,
                                       ip_language varchar2,
                                       ip_transfer_min varchar2  --YES=>same number, NO=> new number
                                       ) return varchar2;

  procedure lte_sim_marriage_tool (p_esn varchar2,
                                          p_x_iccid varchar2,
                                          op_out_msg out varchar2,
                                          op_error_code out number);

  function manual_unit_bal_cap (ip_esn varchar2,
                                       ip_user_ttl varchar2) return varchar2;

  function new_due_date (ip_call_trans_objid number) return varchar2;

  function reset_sim(ip_iccid varchar2) return varchar2;

  function resetmin (p_reset_min    in varchar2,
                            p_reset_reason in varchar2,
                            p_login_name in varchar2,
                            p_expire_sim in varchar2) return varchar2;

  function serv_plan_site_part (ip_esn           varchar2,
                                       ip_program_objid varchar2) return varchar2;

  function upd_ota_pending (p_esn varchar2) return varchar2;

  function upd_promo (p_promo_objid number,
                             p_new_end_date varchar2) return varchar2;

  function upgrade_is_pin_required (ip_old_esn varchar2, ip_new_esn varchar2) return number;

  procedure workforce_pin (ip_esn          varchar2,
                                  ip_pin_part_num varchar2,
                                  ip_login_name   varchar2,
                                  ip_reason       varchar2,
                                  ip_notes        varchar2,
                                  ip_contact_objid varchar2,
                                  ip_orgid		varchar2,              --added for CR54687
                                  ip_service_plan_objid		varchar2,         --added for CR54687
                                  ip_service_type	varchar2,                 --added for CR54687
                                  op_pin out varchar2,
                                  op_case_id out varchar2,
                                  op_error_num out varchar2,
                                  op_error_msg out varchar2);

  --Overload for Optional PIN Invalidation
  procedure workforce_pin (ip_esn          varchar2,
                                  ip_pin_part_num varchar2,
                                  ip_login_name   varchar2,
                                  ip_reason       varchar2,
                                  ip_notes        varchar2,
                                  ip_contact_objid varchar2,
                                  ip_invalid_pin varchar2,
								  ip_old_esn		varchar2,
								  ip_current_esn	varchar2,
								  ip_pin_or_marc_id	varchar2,
								  ip_ticket_num		varchar2,
								  ip_issue			varchar2,
								  ip_action_taken	varchar2,
                                  ip_orgid		varchar2,   --added for CR54687
                                  ip_service_plan_objid		varchar2,    --added for CR54687
                                  ip_service_type	varchar2,                      --added for CR54687
                                  op_pin out varchar2,
                                  op_case_id out varchar2,
                                  op_error_num out varchar2,
                                  op_error_msg out varchar2);

  function workforce_ild_pin (ip_esn varchar2, ip_login_name varchar2) return varchar2;

  function family_plan_make_primary(ip_esn varchar2,
                                    ip_bp_objid varchar2)
  return varchar2;

    --CR22313 Handset Protection begins
  function is_restricted_handset_varchar2 (
    PP_OBJID  IN NUMBER,
    pc_objid  in number
  ) return varchar2;

  function is_restricted_state_varchar2 (
    pp_objid    in number,
    ip_zipcode  in varchar2
  ) return varchar2;

  function is_valid_status_varchar2 (
    pp_objid  in number,
    ip_status in varchar2
  ) return varchar2;
  --CR22313 Handset Protection end

  function is_manual_code_required(
  /*************** ************************************************
   ** Return 1 if esn requires manual programming                **
   ** return 0 when no need manual programming                   **
   ****************************************************************/
    ip_esn in varchar2
  ) return varchar2;

  /********************************************************
  ******  block_promo_esn_upgrade *************************
  ******  Promo ESNs are not candidate for upgrade ********
  ******  CR29387 *****************************************/
  function block_promo_esn_upgrade (ip_esn in varchar2)
  return varchar2;

  function upd_port_in_flag (p_esn varchar2) return varchar2;

  procedure validate_promo(ip_red_card varchar2,
                           ip_promo_code varchar2,
                           ip_esn varchar2,
                           ip_cust_id varchar2,
                           ip_contact_objid varchar2,
                           ip_user_objid varchar2,
                           ip_red_method varchar2,  -- THIS IS REQUIRED VALUES ARE 'IVR','WEB',' OTA HANDSET'
                           op_err_msg out varchar2,
                           op_err_num out varchar2);

  -- OVERLOADED NEW -- REMOVE THE ORIGINAL (ABOVE)
  procedure validate_promo(ip_red_card varchar2,
                           ip_promo_code varchar2,
                           ip_esn varchar2,
                           ip_cust_id varchar2,
                           ip_contact_objid varchar2,
                           ip_user_objid varchar2,
                           ip_red_method varchar2,  -- THIS IS REQUIRED VALUES ARE 'IVR','WEB',' OTA HANDSET'
                           op_pin out varchar2, -- NEW SIGNATURE (PIN FROM WORKFORCE)
                           op_err_msg out varchar2,
                           op_err_num out varchar2);


  procedure cross_carrier_sim_change (ip_esn varchar2,
                           ip_new_sim varchar2,
                           ip_new_carrier_id varchar2,
                           ip_zip_code  varchar2,
                           ip_contact_objid varchar2,
                           ip_user_objid varchar2,
                           ip_source_system varchar2,
                           op_case_id out varchar2,
                           op_err_msg out varchar2,
                           op_err_num out varchar2);

  procedure create_site_part_call_trans (ip_site_part_objid varchar2,
                                         ip_warr_date date,
                                         ip_new_sim varchar2,
                                         ip_carrier_objid varchar2,
                                         ip_user_objid varchar2,
                                         ip_source varchar2,
                                         ip_serv_plan_id varchar2,
                                         op_call_trans_objid out varchar2 );


  procedure comp_threshold (ip_esn in varchar2,
                            ip_user_objid in varchar2,
                            op_days  out number,
                            op_voice out number,
                            op_sms out number,
                            op_data out number);

  PROCEDURE SIM_MARRiAGE(P_ESN        IN VARCHAR2,
                         P_X_ICCID    IN VARCHAR2,
                         p_error_msg  OUT varchar2,
                         P_ERROR_CODE out NUMBER);

  function has_keypad(ip_esn varchar2)
  return varchar2;

	---CR52302 TAS phone status information for ESN,MIN and SIM
	type phone_status_rec
	IS
	  record
	  (
		esn_status VARCHAR2(30),
		sim_status   VARCHAR2(30),
		min_status   VARCHAR2(30));

	type phone_status_rec_tab
	IS
	  TABLE OF phone_status_rec;

	FUNCTION get_phone_status_info(
		ip_esn IN VARCHAR2,
		ip_sim IN VARCHAR2,
		ip_min IN VARCHAR2)
	  RETURN phone_status_rec_tab pipelined;

	---CR52306
	type contact_consent_rec
	IS
		record
		(
		sms_consent   NUMBER,
		email_consent NUMBER);

	type contact_consent_rec_tab
	IS
		TABLE OF contact_consent_rec;

	FUNCTION get_contact_consent_info(
		ip_min     IN VARCHAR2,
		ip_channel IN VARCHAR2)
		RETURN contact_consent_rec_tab pipelined;
		--
	type send_trans_rec
	IS
		record
		(
		sms_trans_summary   VARCHAR2(30),
		email_trans_summary VARCHAR2(30),
		sms_template        VARCHAR2(400),
		min_to_sms					VARCHAR2(40));

	type send_trans_rec_tab
	IS
		TABLE OF send_trans_rec;

	FUNCTION can_auto_send_trans_summary(
		ip_esn_sim_min    IN VARCHAR2,
		ip_type						IN VARCHAR2, -- LINE (MIN), SIM_CARD, HANDSET(ESN)
		ip_org_id IN VARCHAR2)
	RETURN send_trans_rec_tab pipelined;

	--CR53924 TAS Identity Challenge Page Clean up
	type challenge_rec
	IS
	  record
	  (
		priority  number,
		challenge VARCHAR2(4000),
		response  VARCHAR2(4000));

	type challenge_tab
	IS
	  TABLE OF challenge_rec;

	FUNCTION get_challenge(
		p_web_user_objid IN VARCHAR2,
		p_contact_objid IN VARCHAR2)
	  RETURN challenge_tab pipelined;

end adfcrm_cust_service;
/