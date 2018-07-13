CREATE OR REPLACE PACKAGE sa."ADFCRM_GROUP_TRANS_PKG"
is
--------------------------------------------------------------------------------------------
--$RCSfile: CR####.sql,v $
--$Revision: 1.5 $
--$Author: userId $
--$Date: 2011/12/12 19:09:44 $
--$ $Log: CR####.sql,v $
--------------------------------------------------------------------------------------------
  function insert_group_temp(ipv_group_name varchar2,
                             ipv_group_id varchar2,
                             ipv_transaction_type varchar2,
                             ipv_web_user_objid varchar2,
                             ipv_contact_objid varchar2,
                             ipv_esn varchar2,
                             ipv_sim varchar2,
                             ipv_pin varchar2,
                             ipv_zipcode varchar2,
                             ipv_service_plan_id varchar2,
                             ipv_priority varchar2,
                             ipv_brand_name varchar2,
                             ipv_insert_date varchar2,
                             ipv_status varchar2,
                             ipv_update_date varchar2,
                             ipv_agent_name varchar2,
                             ipv_port_current_esn varchar2,
                             ipv_port_type varchar2,
                             ipv_port_service_provider varchar2,
                             ipv_port_current_brand varchar2,
                             ipv_port_account_number varchar2,
                             ipv_port_password_pin varchar2,
                             ipv_port_first_name varchar2,
                             ipv_port_last_name varchar2,
                             ipv_port_min varchar2,
                             ipv_port_last_4_ssn varchar2,
                             ipv_port_address varchar2,
                             ipv_port_city varchar2,
                             ipv_port_state varchar2,
                             ipv_port_zipcode varchar2,
                             ipv_port_country varchar2,
                             ipv_port_phone varchar2,
                             ipv_port_email varchar2,
                             ipv_case_id varchar2,
                             ipv_case_objid varchar2,
                             ipv_byop_lte_req_exchg_pn varchar2)
  return varchar2;

  function change_group_status(ipv_objid varchar2, ipv_status varchar2)
  return varchar2;

  function get_group_id(ip_search_type varchar2, ip_search_value varchar2)
  return varchar2;

  function get_group_nn(ip_search_type varchar2, ip_search_value varchar2)
  return varchar2;

  function get_service_plan(ip_search_type varchar2, ip_search_value varchar2)
  return varchar2;

  function get_group_status(ip_search_type varchar2, ip_search_value varchar2)
  return varchar2;

  function get_total_devices(ip_search_type varchar2, ip_search_value varchar2)
  return varchar2;

  function get_master_esn(ip_search_type varchar2, ip_search_value varchar2)
  return varchar2;

  function get_projected_end_date(ip_search_type varchar2, ip_search_value varchar2)
  return varchar2;

  function get_cards_in_queue(ip_search_type varchar2, ip_search_value varchar2)
  return varchar2;

  function get_expire_date(ip_search_type varchar2, ip_search_value varchar2)
  return varchar2;

  procedure get_program_info(p_esn varchar2,
                             p_service_plan_objid out varchar2,
                             p_service_type out varchar2,
                             p_program_type out varchar2,
                             p_next_charge_date out date,
                             p_program_units out number,
                             p_program_days out number,
                             p_rate_plan out varchar2,
                             p_x_prg_script_id out varchar2,
                             p_x_prg_desc_script_id out varchar2,
                             p_error_num out number);

  function pre_act_member_removal (p_esn varchar2, p_group_id varchar2) return varchar2;

  procedure get_group_info(ip_esn in varchar2,
                           op_account_group_id out varchar2,
                           op_account_group_name out varchar2,
                           op_status out varchar2,
                           op_count out varchar2);

  function pre_act_archiving (p_group_id varchar2) return varchar2;

  function delete_member_from_grp_if_req(ip_esn in varchar2) return varchar2;

end adfcrm_group_trans_pkg;
/