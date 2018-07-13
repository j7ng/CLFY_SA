CREATE OR REPLACE PACKAGE sa."APEX_SAFELINK" as
  type split_tbl_ty is table of varchar2(500);
  procedure file_uploader(ip_job_name varchar2,
                          ip_file_name varchar2,
                          ip_priority number,
                          ip_sch_rundate date,
                          ip_user_reason varchar2,
                          ip_user_name varchar2,
                          ip_bus_reason  varchar2 default null,
                          op_result out varchar2);
  procedure runbatch(ip_jid varchar2 default null,
                     ip_srce_table varchar2 default null);
  procedure process_contact_edit;

  end;
/