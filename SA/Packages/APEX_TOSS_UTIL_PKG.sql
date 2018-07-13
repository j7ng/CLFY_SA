CREATE OR REPLACE PACKAGE sa."APEX_TOSS_UTIL_PKG"
AS
--------------------------------------------------------------------------------------------
--$RCSfile: APEX_TOSS_UTIL_PKG.sql,v $
--$Revision: 1.11 $
--$Author: hcampano $
--$Date: 2017/08/25 17:27:12 $
--$ $Log: APEX_TOSS_UTIL_PKG.sql,v $
--$ Revision 1.11  2017/08/25 17:27:12  hcampano
--$ CR52985	 - Multi Denomination Cards - Customer Care Rel
--$
--$ Revision 1.10  2017/05/30 16:02:16  syenduri
--$ Check-in behalf of Natalio - Done changes for WFM : Invalid Reserve Pin Changes
--$
--$ Revision 1.9  2016/04/19 19:21:00  mmunoz
--$ CR28748: Added part_class in airtime_cards_rec type
--$
--$ Revision 1.8  2015/07/23 14:40:08  hcampano
--$ TAS_2015_14B - Fixed production issue where long emails and account groups create errors when accessing pin information
--$
--$ Revision 1.7  2015/01/25 15:45:36  hcampano
--$ TAS_2015_03 - fixing development issues.
--$
--$ Revision 1.6  2015/01/21 20:57:14  hcampano
--$ TAS_2015_03
--$
--$ Revision 1.5  2015/01/09 14:54:33  hcampano
--$ Changes for Brand X. TAS_2015_03
--$
--$ Revision 1.4  2014/06/24 12:23:46  hcampano
--$ 7/2014 TAS release (TAS_2014_06) overloaded sp_mark_card_invalid. CR29035
--$
--$ Revision 1.3  2014/05/29 15:37:39  hcampano
--$ TAS_2014_03B - Added new column to airtime cards func
--$
--$ Revision 1.2  2014/05/28 20:55:49  hcampano
--$ TAS_2014_03B - Rollout B, New DB objects
--$
--$ Revision 1.1  2012/08/30 13:54:21  mmunoz
--$ Package created to handle the transactions invoked for the menu TOSS UTIL in APEX
--$
--------------------------------------------------------------------------------------------

  function get_parent_snp_func(ip_snp_or_card_no varchar2)
  return varchar2;
--------------------------------------------------------------------------------
  type airtime_cards_rec is record
  (card_no            varchar2(30),
   part_number        varchar2(30),
   description        varchar2(255),
   x_result           varchar2(20),
   access_days        number,
   card_units         number,
   snp_esn            varchar2(30),
   source_sys         varchar2(30),
   x_transact_date    date,
   status             varchar2(20),
   status_desc        varchar2(20),
   dealer_id          varchar2(80),
   dealer_name        varchar2(80),
   reserved_for_esn   varchar2(30),
   change_card_status varchar2(20),
   mark_card_invalid  varchar2(20),
   part_serial_no     varchar2(30),
   x_service_id       varchar2(30),
   related_cases      varchar2(300),
   current_min        varchar2(30),
   account_group_name varchar2(50),
   account_group_id   varchar2(30),
   s_login_name       varchar2(50),
   call_trans_objid   number,
   part_class         varchar2(50),
   org_id             varchar2(40)
  );

  type airtime_cards_tab is table of airtime_cards_rec;
  airtime_cards_rslt airtime_cards_rec;

  function airtime_cards(ip_search_type varchar2, ip_search_value varchar2)
  return airtime_cards_tab pipelined;

  function airtime_cards(ip_snp_or_card_no varchar2)
  return airtime_cards_tab pipelined;

  function airtime_cards_by_group_id(group_id varchar2)
  return airtime_cards_tab pipelined;
--------------------------------------------------------------------------------
  procedure sp_mark_card_invalid (
   ip_snp    in varchar2      --assumption ip_snp is the parent snp
  ,op_result out number
  ,op_msg    out varchar2
  );
--------------------------------------------------------------------------------
  procedure sp_mark_card_invalid (
   ip_snp    in varchar2      --assumption ip_snp is the parent snp
  ,ip_esn    in varchar2
  ,op_result out number
  ,op_msg    out varchar2
  );
--------------------------------------------------------------------------------
  procedure sp_ResetVoided_Unreserve (
   ip_snp    in varchar2      --assumption ip_snp is the parent snp
  ,op_result out number
  ,op_msg    out varchar2
  );
--------------------------------------------------------------------------------
  function get_my_account_email(ip_esn varchar2)
  return varchar2;
--------------------------------------------------------------------------------
  procedure tas_denom (ip_snp_prefix varchar2,
	                   ip_snp varchar2,
	                   ip_upc_no varchar2,
	                   ip_incident_id varchar2,
	                   ip_login_name varchar2,
	                   ip_notes varchar2, -- LONG COLUMN
	                   op_err_no out varchar2,
	                   op_err_msg out varchar2);
--------------------------------------------------------------------------------
  procedure tas_denom (ip_snp_prefix varchar2,
	                   ip_snp varchar2,
	                   ip_upc_no varchar2,
	                   ip_incident_id varchar2,
	                   ip_login_name varchar2,
	                   ip_notes varchar2, -- LONG COLUMN
                       ip_confirm varchar2, -- MUST BE NULL OR Y
                       op_action out varchar2,
	                   op_err_no out varchar2,
	                   op_err_msg out varchar2);
end apex_toss_util_pkg;
/