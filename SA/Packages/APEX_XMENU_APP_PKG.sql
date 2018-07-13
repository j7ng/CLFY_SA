CREATE OR REPLACE package sa.apex_xmenu_app_pkg is
  procedure ins_menu_item (p_orderby      varchar2,
                           p_mkey         varchar2,
                           p_category     varchar2,
                           p_lang         varchar2,
                           p_desc         varchar2,
                           p_channel      varchar2,
                           p_manuf_pc     varchar2,
                           p_brand        varchar2);

  procedure del_menu_item (p_orderby      varchar2,
                           p_mkey         varchar2,
                           p_category     varchar2,
                           p_lang         varchar2,
                           p_channel      varchar2,
                           p_manuf_pc     varchar2,
                           p_brand        varchar2);

  procedure upd_menu_item (p_orderby      varchar2,
                           p_mkey         varchar2,
                           p_category     varchar2,
                           p_lang         varchar2,
                           p_desc         varchar2,
                           p_channel      varchar2,
                           p_manuf_pc     varchar2,
                           p_brand        varchar2);

  procedure rollback_x_menu_change_log (p_src_link varchar2,
                                        p_del_rowid varchar2);

  procedure write_x_menu_change_log (p_action       varchar2,
                                     p_orderby      varchar2,
                                     p_mkey         varchar2,
                                     p_category     varchar2,
                                     p_lang         varchar2,
                                     p_new_desc     varchar2,
                                     p_old_desc     varchar2,
                                     p_channel      varchar2,
                                     p_manuf_pc     varchar2,
                                     p_brand        varchar2,
                                     p_src_link     varchar2,
                                     p_dest_link    varchar2,
                                     p_user_name    varchar2,
                                     p_export_label varchar2,
                                     p_export_no    number);

  procedure export_rollback_xmenu(p_src_link     in varchar2,
                                  p_dest_link    in varchar2,
                                  p_branch_label in varchar2,
                                  p_user_name    in varchar2,
                                  p_xprt_or_rlbk in varchar2,
                                  op_out_msg    out varchar2);

end apex_xmenu_app_pkg; 
/