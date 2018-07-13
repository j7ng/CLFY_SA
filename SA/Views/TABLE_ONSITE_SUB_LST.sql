CREATE OR REPLACE FORCE VIEW sa.table_onsite_sub_lst (objid,creation_time,perf_by,billable_time,non_bill_time,billable_exp,non_bill_exp,total_time,total_exp,subcase_objid) AS
select table_onsite_log.objid, table_onsite_log.creation_time,
 table_onsite_log.perf_by, table_onsite_log.billable_time,
 table_onsite_log.non_bill_time, table_onsite_log.billable_exp,
 table_onsite_log.non_bill_exp, table_onsite_log.total_time,
 table_onsite_log.total_exp, table_onsite_log.subc_onsite2subcase
 from table_onsite_log
 where table_onsite_log.subc_onsite2subcase IS NOT NULL
 ;
COMMENT ON TABLE sa.table_onsite_sub_lst IS 'Joins onsite_log and subcase';
COMMENT ON COLUMN sa.table_onsite_sub_lst.objid IS 'Onsite log internal record number';
COMMENT ON COLUMN sa.table_onsite_sub_lst.creation_time IS 'Date and time the T&E log was created';
COMMENT ON COLUMN sa.table_onsite_sub_lst.perf_by IS 'Login name of the Person that performs the T&E task';
COMMENT ON COLUMN sa.table_onsite_sub_lst.billable_time IS 'Total T&E log time that is billable in seconds';
COMMENT ON COLUMN sa.table_onsite_sub_lst.non_bill_time IS 'Total T&E log time that is not billable in seconds';
COMMENT ON COLUMN sa.table_onsite_sub_lst.billable_exp IS 'Total T&E log expenses that are billable';
COMMENT ON COLUMN sa.table_onsite_sub_lst.non_bill_exp IS 'Total T&E log expenses that are not billable';
COMMENT ON COLUMN sa.table_onsite_sub_lst.total_time IS 'Total time, both billable and non-billable';
COMMENT ON COLUMN sa.table_onsite_sub_lst.total_exp IS 'Total non-billable and billable expenses';
COMMENT ON COLUMN sa.table_onsite_sub_lst.subcase_objid IS 'Subcase internal record number';