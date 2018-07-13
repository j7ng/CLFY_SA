CREATE OR REPLACE package sa.apex_apn_pkg
is
  procedure copy_pc_data_mappings(ipv_src varchar2,
                                  ipv_mapping_rowid varchar2,
                                  ipv_dest_list clob,
                                  ipv_user varchar2,
                                  opv_msg out varchar2);
end apex_apn_pkg;
/