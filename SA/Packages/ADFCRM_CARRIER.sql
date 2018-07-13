CREATE OR REPLACE PACKAGE sa."ADFCRM_CARRIER" is
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_CARRIER_PKG.sql,v $
--$Revision: 1.8 $
--$Author: syenduri $
--$Date: 2017/11/15 23:19:25 $
--$ $Log: ADFCRM_CARRIER_PKG.sql,v $
--$ Revision 1.8  2017/11/15 23:19:25  syenduri
--$ CR53530 - Added get_ig_status_error_message function
--$
--$ Revision 1.7  2017/11/09 22:41:27  syenduri
--$ CR53530 - Get IG Action Item Status
--$
--$ Revision 1.6  2017/07/12 14:37:25  pkapaganty
--$ CR48187 and CR49838
--$
--$ Revision 1.5  2017/07/11 21:49:14  pkapaganty
--$ CR48187 and CR49838 API to check if 2 SIMs belong to same carrier or different carrier
--$
--$ Revision 1.4  2014/06/24 12:26:53  hcampano
--$ 7/2014 TAS release (TAS_2014_06) overloaded mark_card_invalid. CR29035
--$
--$ Revision 1.3  2014/04/09 15:37:08  hcampano
--$ CR27607
--$
--$ Revision 1.2  2013/12/17 20:41:05  mmunoz
--$ CR26679
--$
--$ Revision 1.1  2013/12/06 19:38:06  mmunoz
--$ CR26679  TAS Various Enhancments
--$
--------------------------------------------------------------------------------------------

  function add_line (p_esn        in varchar2,
                     p_case_objid in varchar2,
                     p_carrier_id in varchar2,
                     p_account_no in varchar2,
                     p_mdn        in varchar2,
                     p_user_objid in varchar2,
                     p_expiration_date in  varchar2,
                     p_same_msid  in varchar2,
                     p_specify_msid in varchar2) return varchar2;

  function add_promo (p_promotype varchar2,
                      p_bus_org varchar2,
                      p_start_date varchar2,
                      p_esn varchar2) return varchar2;

  function add_upd_carr_zone (p_npa varchar2,
                              p_nxx varchar2,
                              p_carrier_id number,
                              p_carrier_name varchar2,
                              p_lead_time number,
                              p_target_level number,
                              p_ratecenter varchar2,
                              p_state varchar2,
                              p_carrier_id_description varchar2,
                              p_zone varchar2,
                              p_county varchar2,
                              p_marketid number,
                              p_mrkt_area varchar2,
                              p_sid varchar2,
                              p_technology varchar2,
                              p_frequency1 number,
                              p_frequency2 number,
                              p_bta_mkt_number varchar2,
                              p_bta_mkt_name varchar2,
                              p_gsm_tech varchar2,
                              p_cdma_tech varchar2,
                              p_mnc varchar2,
                              p_npanxxzoneid rowid)
  return varchar2;

  function add_upd_carrier_pref (ip_pref_rowid varchar2,
                                 ip_st varchar2,
                                 ip_county varchar2,
                                 ip_carrier_name varchar2, -- value is now passed from drop down no need to select into
                                 ip_carrier_id number,
                                 ip_rank number,
                                 ip_user_name varchar2) return varchar2;

  function change_phone_dealer(p_esn varchar2,
                               p_dealer_id varchar2,
                               p_user varchar2) return varchar2;

  function change_phone_model(p_esn varchar2,
                              p_new_part_number varchar2,
                              p_user varchar2) return varchar2;

  function del_carrier_pref (ip_pref_rowid varchar2,
                             ip_st varchar2,
                             ip_county varchar2,
                             ip_carrier_name varchar2, -- value is now passed from drop down no need to select into
                             ip_carrier_id number,
                             ip_rank number,
                             ip_user_name varchar2) return varchar2;

  function fix_esn_mismatch (ip_esn varchar2,
                             ip_user varchar2) return varchar2;

  function insertcard (p_dealerid    in varchar2,
                       p_red_code    in varchar2,
                       p_snp         in varchar2,
                       p_part_number in varchar2,
                       p_part_status in varchar2,
                       p_login_name  in varchar2) return varchar2;

  function insertcard2 (p_dealerid in varchar2,
                        p_red_code in varchar2,
                        p_snp in varchar2, -- SNP
                        p_part_number in varchar2,
                        p_part_status in varchar2,
                        p_login_user  in varchar2) return varchar2;

  function mark_card_invalid (p_reason in varchar2,
                              p_card_no in varchar2,
                              p_snp     in varchar2,
                              p_login_name in varchar2) return varchar2;

  function mark_card_invalid (p_reason in varchar2,
                              p_esn in varchar2,
                              p_card_no in varchar2,
                              p_snp     in varchar2,
                              p_login_name in varchar2) return varchar2;

  function min_entry_batch (ip_user varchar2,
                            ip_file varchar2,
                            ip_batch_type varchar2)  -- 1 = INSERT, 2 = DELETE
  return varchar2;

  function reset_posa (p_reason       in   varchar2,
                       p_card_no      in   varchar2,
                       p_storeid      in   varchar2,
                       p_esn          in   varchar2,
                       p_snp          in   varchar2,
                       p_login_name   in   varchar2) return varchar2;

  function sui_ttoff (ip_esn varchar2,
                      ip_min varchar2) return varchar2;

  function sui_tton (ip_esn varchar2,
                     ip_min varchar2) return varchar2;

  function transfer_promo (p_part_serial_no varchar2,
                           p_new_part_serial_no varchar2) return varchar2;

  function unreserve_reset_voided (p_action  in varchar2,
                                   p_reason  in varchar2,
                                   p_card_no in varchar2,
                                   p_snp     in varchar2,
                                   p_login_name in varchar2) return varchar2;

  function upd_carrier_zones (ip_from_state varchar2,
                              ip_from_zone varchar2,
                              ip_from_carr_name varchar2,
                              ip_from_county varchar2,
                              ip_from_rate_center varchar2,
                              ip_new_state varchar2,
                              ip_new_zone varchar2,
                              ip_existing_carr_name varchar2) return varchar2;

  function reserve_min2esn (p_min                   in   varchar2,
                            p_esn                   in   varchar2,
                            p_port_in_min_reserve   in   number,  --yes --no passed as (1,0)
                            p_reserve_reason        in   long,
                            p_login_name            in   varchar2) return varchar2;

  function get_msl (IP_ESN varchar2) return varchar2;

  FUNCTION CHANGE_OWNERSHIP (p_esn VARCHAR2,
                             p_action_item_id VARCHAR2)
  RETURN VARCHAR2;



	FUNCTION check_cross_carrier(
		p_sim1 IN VARCHAR2,
		p_sim2 IN VARCHAR2)
	  RETURN VARCHAR2;

 FUNCTION get_action_item_status_code(
    ip_action_item_status VARCHAR2)
  RETURN VARCHAR2;

 FUNCTION get_ig_status_error_message(
    ip_status_message VARCHAR2)
  RETURN VARCHAR2;

end adfcrm_carrier;
/