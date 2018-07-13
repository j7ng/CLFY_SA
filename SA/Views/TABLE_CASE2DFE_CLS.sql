CREATE OR REPLACE FORCE VIEW sa.table_case2dfe_cls (case_id,sub_id,id_number,title,close_date,actl_phone_time,calc_phone_time,actl_rsrch_time,calc_rsrch_time,actl_bill_exp,actl_nonbill,calc_bill_exp,calc_nonbill,bill_time,nonbill_time,previous_closed) AS
select table_disptchfe.disptchfe2case, table_disptchfe.objid,
 table_disptchfe.work_order, table_disptchfe.description,
 table_close_case.close_date, table_close_case.actl_phone_time,
 table_close_case.calc_phone_time, table_close_case.actl_rsrch_time,
 table_close_case.calc_rsrch_time, table_close_case.actl_bill_exp,
 table_close_case.actl_nonbill, table_close_case.calc_bill_exp,
 table_close_case.calc_nonbill, table_close_case.bill_time,
 table_close_case.nonbill_time, table_close_case.previous_closed
 from table_disptchfe, table_close_case, table_act_entry
 where table_disptchfe.disptchfe2case IS NOT NULL
 AND table_act_entry.objid = table_close_case.close_case2act_entry
 ;
COMMENT ON TABLE sa.table_case2dfe_cls IS 'Used to access TandE data from TandE logs associated with Field Dispatch entries for use at the time of case closure';
COMMENT ON COLUMN sa.table_case2dfe_cls.case_id IS 'Case internal record number';
COMMENT ON COLUMN sa.table_case2dfe_cls.sub_id IS 'Disptchfe internal record number';
COMMENT ON COLUMN sa.table_case2dfe_cls.id_number IS 'Work order number entered by the user';
COMMENT ON COLUMN sa.table_case2dfe_cls.title IS 'Task description';
COMMENT ON COLUMN sa.table_case2dfe_cls.close_date IS 'Case close date and time';
COMMENT ON COLUMN sa.table_case2dfe_cls.actl_phone_time IS 'Actual time spent on the phone for the case or subcase; entered by user if different from captured phone time in seconds';
COMMENT ON COLUMN sa.table_case2dfe_cls.calc_phone_time IS 'Time spent on the phone for the case or subcase; calculated from phone logs';
COMMENT ON COLUMN sa.table_case2dfe_cls.actl_rsrch_time IS 'Actual time spent doing research for the case or subcase in seconds; entered by user if different from captured research time';
COMMENT ON COLUMN sa.table_case2dfe_cls.calc_rsrch_time IS 'Time spent doing research for the case or subcase; calculated from research logs in seconds';
COMMENT ON COLUMN sa.table_case2dfe_cls.actl_bill_exp IS 'Actual billable expenses for the case; not displayed/used';
COMMENT ON COLUMN sa.table_case2dfe_cls.actl_nonbill IS 'Actual non-billable expenses for the case; not displayed/used';
COMMENT ON COLUMN sa.table_case2dfe_cls.calc_bill_exp IS 'Calculated billable expenses for the case; calculated from T&E logs';
COMMENT ON COLUMN sa.table_case2dfe_cls.calc_nonbill IS 'Calculated non-billable expenses for the case; calculated from T&E logs';
COMMENT ON COLUMN sa.table_case2dfe_cls.bill_time IS 'Calculated billable time for the case/subcase; calculated from T&E log time items in seconds';
COMMENT ON COLUMN sa.table_case2dfe_cls.nonbill_time IS 'Calculated non-billable time for the case/subcase; calculated from T&E log time items in seconds';
COMMENT ON COLUMN sa.table_case2dfe_cls.previous_closed IS 'Date/time case/subcase was last closed; earlier than close date if the case has been closed before';