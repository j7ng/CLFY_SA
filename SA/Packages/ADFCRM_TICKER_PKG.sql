CREATE OR REPLACE package sa.adfcrm_ticker_pkg
as
--------------------------------------------------------------------------------
  procedure adfcrm_refresh_ticker;
--------------------------------------------------------------------------------
  procedure ins_tick(ipv_date varchar2,
                     ipv_login_name varchar2,
                     scp_text varchar2,
                     ipv_font_clr varchar2,
                     ipv_font_wt varchar2);
--------------------------------------------------------------------------------

  function adfcrm_add_ticker (ipv_objid varchar2,
                                 ipv_script_text varchar2,
                                 ipv_font_clr varchar2,
                                 ipv_font_wt varchar2,
                                 v_login_name varchar2)
  return varchar2;
--------------------------------------------------------------------------------
  function adfcrm_show_hide_ticker(ipv_tkr_hist_obj varchar2, ipv_show_or_hide varchar2,ipv_login_name varchar2)
  return varchar2;
--------------------------------------------------------------------------------
  function repost_ticker(ipv_tkr_hist_obj varchar2,ipv_login_name varchar2)
  return varchar2;
--------------------------------------------------------------------------------
end adfcrm_ticker_pkg;
  -- PLSQL/SA/Packages/adfcrm_ticker_pkg_spec.sql REV:1.2 info For DBA only
/