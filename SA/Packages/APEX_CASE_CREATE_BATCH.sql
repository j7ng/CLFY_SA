CREATE OR REPLACE package sa.apex_case_create_batch as
  type split_tbl_ty is table of varchar2(500);
  procedure file_uploader(ip_file_name varchar2,
                          ip_user_name varchar2,
                          op_result out varchar2);
  function case_type_and_title_allowed(ip_case_type varchar2, ip_case_title varchar2)
  return number;
end apex_case_create_batch;
-- ANTHILL_TEST PLSQL/SA/Packages/apex_case_create_batch_pkg.sql 	CR40646: 1.1
/