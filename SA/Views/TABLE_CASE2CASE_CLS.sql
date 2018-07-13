CREATE OR REPLACE FORCE VIEW sa.table_case2case_cls (case_id,id_number,title,s_title,close_date,actl_phone_time,calc_phone_time,actl_rsrch_time,calc_rsrch_time,actl_bill_exp,actl_nonbill,calc_bill_exp,calc_nonbill,bill_time,nonbill_time,previous_closed) AS
select table_case.objid, table_case.id_number,
 table_case.title, table_case.S_title, table_close_case.close_date,
 table_close_case.actl_phone_time, table_close_case.calc_phone_time,
 table_close_case.actl_rsrch_time, table_close_case.calc_rsrch_time,
 table_close_case.actl_bill_exp, table_close_case.actl_nonbill,
 table_close_case.calc_bill_exp, table_close_case.calc_nonbill,
 table_close_case.bill_time, table_close_case.nonbill_time,
 table_close_case.previous_closed
 from table_case, table_close_case, table_act_entry
 where table_case.objid = table_act_entry.act_entry2case
 AND table_act_entry.objid = table_close_case.close_case2act_entry
 ;
COMMENT ON TABLE sa.table_case2case_cls IS 'View of all close case information.  Used on close case form';
COMMENT ON COLUMN sa.table_case2case_cls.case_id IS 'Case internal record number';
COMMENT ON COLUMN sa.table_case2case_cls.id_number IS 'Response priority of case; from a Clarify-defined pop up list';
COMMENT ON COLUMN sa.table_case2case_cls.title IS 'Case or service call title; summary of case details';
COMMENT ON COLUMN sa.table_case2case_cls.close_date IS 'Case close date and time';
COMMENT ON COLUMN sa.table_case2case_cls.actl_phone_time IS 'Actual time spent on the phone for the case or subcase in seconds; entered by user if different from captured phone time';
COMMENT ON COLUMN sa.table_case2case_cls.calc_phone_time IS 'Time spent on the phone for the case or subcase; calculated from phone logs';
COMMENT ON COLUMN sa.table_case2case_cls.actl_rsrch_time IS 'Actual time spent doing research for the case or subcase in seconds; entered by user if different from captured research time';
COMMENT ON COLUMN sa.table_case2case_cls.calc_rsrch_time IS 'Time spent doing research for the case or subcase; calculated from research logs';
COMMENT ON COLUMN sa.table_case2case_cls.actl_bill_exp IS 'Actual billable expenses for the case; not displayed/used';
COMMENT ON COLUMN sa.table_case2case_cls.actl_nonbill IS 'Actual non-billable expenses for the case; not displayed/used';
COMMENT ON COLUMN sa.table_case2case_cls.calc_bill_exp IS 'Calculated billable expenses for the case; calculated from T&E logs';
COMMENT ON COLUMN sa.table_case2case_cls.calc_nonbill IS 'Calculated non-billable expenses for the case; calculated from T&E logs';
COMMENT ON COLUMN sa.table_case2case_cls.bill_time IS 'Calculated billable time for the case/subcase in seconds; calculated from T&E log time items';
COMMENT ON COLUMN sa.table_case2case_cls.nonbill_time IS 'Calculated non-billable time for the case/subcase in seconds; calculated from T&E log time items';
COMMENT ON COLUMN sa.table_case2case_cls.previous_closed IS 'Date/time case/subcase was last closed; earlier than close date if the case has been closed before';