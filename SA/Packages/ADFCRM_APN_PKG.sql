CREATE OR REPLACE package sa.adfcrm_apn_pkg
as
  ------------------------------------------------------------------------------
  type handset_manuf_rec is record (handset_manufacturer varchar2(30));

  type handset_manuf_tab is table of handset_manuf_rec;
  handset_manuf_rslt handset_manuf_rec;
  ------------------------------------------------------------------------------
  function handset_manuf_list
  return handset_manuf_tab pipelined;
  ------------------------------------------------------------------------------
  type handset_os_rec is record (operating_system varchar2(300));

  type handset_os_tab is table of handset_os_rec;
  handset_os_rslt handset_os_rec;
  ------------------------------------------------------------------------------
  function handset_os_list
  return handset_os_tab pipelined;
  ------------------------------------------------------------------------------
  type handset_rslt_rec is record (objid number, obj_desc varchar2(300));

  type handset_rslt_tab is table of handset_rslt_rec;
  handset_rslt_rslt handset_rslt_rec;
  ------------------------------------------------------------------------------
  function handset_rslt_list(ip_type varchar2, ip_value varchar2)
  return handset_rslt_tab pipelined;
  ------------------------------------------------------------------------------
  function get_settings(ip_esn in varchar2)
  return adfcrm_esn_structure;
  ------------------------------------------------------------------------------
  procedure find_settings_instruction(ip_os_objid number,
                                      ip_language varchar2,
                                      ip_brand varchar2,
                                      op_script_text out varchar2);
  ------------------------------------------------------------------------------
  type find_settings_ins_rec is record (script_text varchar2(4000));

  type find_settings_ins_tab is table of find_settings_ins_rec;
  find_settings_ins_rslt find_settings_ins_rec;
  ------------------------------------------------------------------------------
  function find_settings_instruction(ip_os_objid number,
                                     ip_language varchar2,
                                     ip_brand varchar2)
  return find_settings_ins_tab pipelined;
  ------------------------------------------------------------------------------
  procedure display_link_url(ip_esn varchar2,ip_os_objid varchar2,op_brand out varchar2, op_msg out varchar2);
  ------------------------------------------------------------------------------
  function get_url_script(ip_esn varchar2,ip_delivery_method varchar2, ip_os_objid varchar2,ip_lang varchar2)
  return varchar2;
  ------------------------------------------------------------------------------
  end adfcrm_apn_pkg;
/