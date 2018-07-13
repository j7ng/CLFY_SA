CREATE OR REPLACE PACKAGE sa."APEX_CASE_RES_PKG" is
  procedure load_data (ipn_resol2conf_hdr     table_x_case_resolutions.resol2conf_hdr%type,
                       ipn_objid              table_x_case_resolutions.objid%type,
                       opv_x_condition        out table_x_case_resolutions.x_condition%type,
                       opv_x_resolution       out table_x_case_resolutions.x_resolution%type,
                       opv_x_status           out table_x_case_resolutions.x_status%type,
                       opn_x_std_resol_time   out table_x_case_resolutions.x_std_resol_time%type,
                       opv_x_agent_resolution out table_x_case_resolutions.x_agent_resolution%type,
                       opv_x_cust_resol_eng   out table_x_case_resolutions.x_cust_resol_eng%type,
                       opv_x_cust_resol_spa   out table_x_case_resolutions.x_cust_resol_spa%type,
                       opv_condition_status   out varchar2);

  procedure ins_case_resolution (ipv_condition         table_x_case_resolutions.x_condition%type,
                                 ipv_resolution        table_x_case_resolutions.x_resolution%type,
                                 ipv_agent_resolution  table_x_case_resolutions.x_agent_resolution%type,
                                 ipv_status            table_x_case_resolutions.x_status%type,
                                 ipv_cust_resol_eng    table_x_case_resolutions.x_cust_resol_eng%type,
                                 ipv_cust_resol_spa    table_x_case_resolutions.x_cust_resol_spa%type,
                                 ipn_std_resol_time    table_x_case_resolutions.x_std_resol_time%type,
                                 ipn_resol2conf_hdr    table_x_case_resolutions.resol2conf_hdr%type,
                                 opv_msg out varchar2);

  procedure upd_case_resolution (ipn_objid             table_x_case_resolutions.objid%type,
                                 ipv_condition         table_x_case_resolutions.x_condition%type,
                                 ipv_resolution        table_x_case_resolutions.x_resolution%type,
                                 ipv_agent_resolution  table_x_case_resolutions.x_agent_resolution%type,
                                 ipv_status            table_x_case_resolutions.x_status%type,
                                 ipv_cust_resol_eng    table_x_case_resolutions.x_cust_resol_eng%type,
                                 ipv_cust_resol_spa    table_x_case_resolutions.x_cust_resol_spa%type,
                                 ipn_std_resol_time    table_x_case_resolutions.x_std_resol_time%type,
                                 opv_msg out varchar2);

  procedure del_case_resolution (ipn_objid table_x_case_resolutions.objid%type,
                                 opv_msg out varchar2);

  function get_case_res_query (ipv_query varchar2,
                               ipv_var_1 varchar2,
                               ipv_src_db varchar2)
  return varchar2;

  function display_res_drop_down (ipv_hdr_objid varchar2,
                                  ipv_src_db varchar2)
  return boolean;

end apex_case_res_pkg;
/