CREATE OR REPLACE package sa.COPY_TAB_PKG
as
 procedure disable_constraint (v_tab in varchar2, v_owner in varchar);
  procedure enable_constraint (v_tab in varchar2, v_owner in varchar);
 procedure copy_tab (p_tab in varchar2 , p_owner in varchar2);
 procedure copy_tab_long (p_tab in varchar2 , p_owner in varchar2);
 procedure send_check_mail(p_tab in varchar2 , p_owner in varchar2);
end;
/