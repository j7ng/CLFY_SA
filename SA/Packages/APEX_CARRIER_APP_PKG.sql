CREATE OR REPLACE PACKAGE sa."APEX_CARRIER_APP_PKG"
is
  procedure export_scripts(ip_src_db  varchar2,
                           ip_action  varchar2, -- action: LABEL,CARRIER,SCRIPT
                           ip_id      varchar2, -- id:  label name, x_carrier_id or apex script objid
                           op_msg_out out varchar2);
end apex_carrier_app_pkg;
/