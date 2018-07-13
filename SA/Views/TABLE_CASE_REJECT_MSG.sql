CREATE OR REPLACE FORCE VIEW sa.table_case_reject_msg (case_objid,act_entry_objid,rjct_msg_objid,user_objid,act_code,creation_time,description,login_name,s_login_name) AS
select table_act_entry.act_entry2case, table_act_entry.objid,
 table_reject_msg.objid, table_user.objid,
 table_act_entry.act_code, table_reject_msg.creation_time,
 table_reject_msg.description, table_user.login_name, table_user.S_login_name
 from table_act_entry, table_reject_msg, table_user
 where table_act_entry.act_entry2case IS NOT NULL
 AND table_reject_msg.objid = table_act_entry.act_entry2reject_msg
 AND table_user.objid = table_reject_msg.reject_person2user
 ;
COMMENT ON TABLE sa.table_case_reject_msg IS 'All reject_msg related to each case. Used by form Edit Case(762)';
COMMENT ON COLUMN sa.table_case_reject_msg.case_objid IS 'Internal reference number of the case object';
COMMENT ON COLUMN sa.table_case_reject_msg.act_entry_objid IS 'Internal reference number of the act_entry object';
COMMENT ON COLUMN sa.table_case_reject_msg.rjct_msg_objid IS 'Internal reference number of the reject_msg object';
COMMENT ON COLUMN sa.table_case_reject_msg.user_objid IS 'Internal reference number of the user object';
COMMENT ON COLUMN sa.table_case_reject_msg.act_code IS 'Activity code to distinguish between Forward and Reject activity';
COMMENT ON COLUMN sa.table_case_reject_msg.creation_time IS 'Creation time of the reject message';
COMMENT ON COLUMN sa.table_case_reject_msg.description IS 'Reason for rejection';
COMMENT ON COLUMN sa.table_case_reject_msg.login_name IS 'Login name of the user who did the rejection';