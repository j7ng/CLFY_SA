CREATE OR REPLACE package sa.apex_crm_batch as
  type split_tbl_ty is table of varchar2(500);
  procedure file_uploader(ip_file_name varchar2,
                          ip_user_name varchar2,
                          ip_rtype varchar2,
                          ip_source varchar2,
                          op_result out varchar2);
end apex_crm_batch;
/