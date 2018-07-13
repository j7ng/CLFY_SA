CREATE OR REPLACE package sa.apex_zip_to_tech
as
--------------------------------------------------------------------------------
  function ret_dblinks
  return varchar2;
--------------------------------------------------------------------------------
  function ret_log (ipv_db varchar2,
                    ipv_rev number default null,
                    ipv_type varchar2 default null)
  return varchar2;
--------------------------------------------------------------------------------
  function ret_bptech (ipv_db varchar2,
                       ipv_techkey varchar2,
                       ipv_service varchar2)
  return varchar2;
--------------------------------------------------------------------------------
  procedure edit_bptech(ipv_db varchar2,
                        ipv_action varchar2,
                        ipv_techkey varchar2,
                        ipv_service varchar2,
                        ipv_bp_code varchar2);
--------------------------------------------------------------------------------
  type z2t_rec_ty is record (zip           varchar2(5),
                             state         varchar2(2),
                             county        varchar2(50),
                             pref1         varchar2(20),
                             pref2         varchar2(20),
                             service       varchar2(20),
                             language      varchar2(2),
                             action        varchar2(50),
                             market        varchar2(50),
                             zip2          varchar2(20),
                             aid           varchar2(20),
                             vid           varchar2(20),
                             vc            varchar2(20),
                             sahcid        varchar2(20),
                             com           varchar2(20),
                             locale        varchar2(30),
                             sitetype      varchar2(30),
                             gotophonelist varchar2(50),
                             tech          varchar2(20),
                             techzip       varchar2(30),
                             techkey       varchar2(20),
                             bp_code       varchar2(20));
--------------------------------------------------------------------------------
  type z2t_tab_ty is table of z2t_rec_ty;
--------------------------------------------------------------------------------
  z2t_rslt z2t_rec_ty;
--------------------------------------------------------------------------------
  procedure z2t_bp_tech_view (v_db varchar2,
                              v_zip varchar2,
                              v_service varchar2,
                              v_lang varchar2,
                              p_recordset out sys_refcursor);
--------------------------------------------------------------------------------
  function z2t_bp_tech_view (v_db varchar2,
                             v_zip varchar2,
                             v_service varchar2,
                             v_lang varchar2)
  return z2t_tab_ty
  pipelined;
--------------------------------------------------------------------------------
  type split_tbl_ty is table of varchar2(500);
--------------------------------------------------------------------------------
  procedure file_uploader(ip_file_name varchar2,
                          ip_user_name varchar2,
                          ip_rtype varchar2,
                          ip_source varchar2,
                          op_result out varchar2);
--------------------------------------------------------------------------------
end apex_zip_to_tech;
/