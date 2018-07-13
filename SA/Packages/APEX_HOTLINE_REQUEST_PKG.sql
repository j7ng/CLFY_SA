CREATE OR REPLACE package sa.apex_hotline_request_pkg
as
-- CR38528
--------------------------------------------------------------------------------
  type split_tbl_ty is table of varchar2(500);
--------------------------------------------------------------------------------
  procedure file_uploader(ip_file_name varchar2,
                          ip_order_type varchar2,
                          ip_short_code varchar2,
                          ip_sms_msg varchar2,
                          ip_user_name varchar2,
                          op_result out varchar2);
--------------------------------------------------------------------------------
-- CR46165 -- Apex Tool Hotline Removal Functionality
-- THE CHANGES BELOW ARE AN EFFORT TO FIX AN ISSUE THAT HAPPENS WITH FILE_UPLOADER (PROCEDURE ABOVE)
-- ISSUE IS THAT THE PAGE WOULD TAKE TO LONG TO PROCESS THE HOTLINE WHILE PROCESSING THE .CSV
-- AND THE PAGE WOULD TIME OUT. THE IDEA BEHIND THIS IS TO LOAD THE DATA INTO A JOB TABLE
-- USING NEW PROCS (CREATE_REQ) + (CREATE_REQ_DATA) AND THAT A JOB THAT PROD DBA WOULD CREATE
-- WILL RUN NEW PROCS (PROCESS_HOTLINE_REQ) + (PROCESS_SMS_REQ) IN ORDER TO CREATE THE ACTION ITEMS
-- THE APEX PORTION OF THE UPLOADER HAS NOT BEEN DEVELOPED AS OF 11.1.2016
--------------------------------------------------------------------------------
  procedure create_req (ip_file_name varchar2,
                        ip_order_type varchar2,
                        ip_short_code varchar2,
                        ip_sms_msg varchar2,
                        ip_user_name varchar2,
                        op_result out varchar2);
--------------------------------------------------------------------------------
  procedure create_req_data(ip_file_name varchar2,
                            op_result out varchar2);
--------------------------------------------------------------------------------
  procedure process_hotline_req(ip_commit_every number default 500);
--------------------------------------------------------------------------------
  procedure process_sms_req(ip_commit_every number default 500);
--------------------------------------------------------------------------------
end apex_hotline_request_pkg;
/