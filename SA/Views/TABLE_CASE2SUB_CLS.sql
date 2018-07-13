CREATE OR REPLACE FORCE VIEW sa.table_case2sub_cls (cls_id,sub_id,case_id,id_number,title,s_title,behavior,sub_type,close_date,actl_phone_time,calc_phone_time,actl_rsrch_time,calc_rsrch_time,actl_bill_exp,actl_nonbill,calc_bill_exp,calc_nonbill,bill_time,nonbill_time,previous_closed) AS
select table_close_case.objid, table_subcase.objid,
 table_subcase.subcase2case, table_subcase.id_number,
 table_subcase.title, table_subcase.S_title, table_subcase.behavior,
 table_subcase.sub_type, table_close_case.close_date,
 table_close_case.actl_phone_time, table_close_case.calc_phone_time,
 table_close_case.actl_rsrch_time, table_close_case.calc_rsrch_time,
 table_close_case.actl_bill_exp, table_close_case.actl_nonbill,
 table_close_case.calc_bill_exp, table_close_case.calc_nonbill,
 table_close_case.bill_time, table_close_case.nonbill_time,
 table_close_case.previous_closed
 from table_close_case, table_subcase
 where table_subcase.objid = table_close_case.close_case2subcase
 AND table_subcase.subcase2case IS NOT NULL
 ;
COMMENT ON TABLE sa.table_case2sub_cls IS 'Displays case TandE data.  Used by form Case Close (340), 2 of 2 (405)';
COMMENT ON COLUMN sa.table_case2sub_cls.cls_id IS 'Close case internal record number';
COMMENT ON COLUMN sa.table_case2sub_cls.sub_id IS 'Subcase internal record number';
COMMENT ON COLUMN sa.table_case2sub_cls.case_id IS 'Case internal record number';
COMMENT ON COLUMN sa.table_case2sub_cls.id_number IS 'Unique ID number for the subcase; consists of case number-#';
COMMENT ON COLUMN sa.table_case2sub_cls.title IS 'Subcase title';
COMMENT ON COLUMN sa.table_case2sub_cls.behavior IS 'Internal field indicating the behavior of the subcase type; i.e.,  1=normal, 2=administrative subcase';
COMMENT ON COLUMN sa.table_case2sub_cls.sub_type IS 'Subcase type; general or administrative';
COMMENT ON COLUMN sa.table_case2sub_cls.close_date IS 'Case close date and time';
COMMENT ON COLUMN sa.table_case2sub_cls.actl_phone_time IS 'Actual time spent on the phone for the case or subcase; entered by user if different from captured phone time in seconds';
COMMENT ON COLUMN sa.table_case2sub_cls.calc_phone_time IS 'Time spent on the phone for the case or subcase; calculated from phone logs';
COMMENT ON COLUMN sa.table_case2sub_cls.actl_rsrch_time IS 'Actual time spent doing research for the case or subcase; entered by user if different from captured research time in seconds';
COMMENT ON COLUMN sa.table_case2sub_cls.calc_rsrch_time IS 'Time spent doing research for the case or subcase; calculated from research logs';
COMMENT ON COLUMN sa.table_case2sub_cls.actl_bill_exp IS 'Actual billable expenses for the case; not displayed/used';
COMMENT ON COLUMN sa.table_case2sub_cls.actl_nonbill IS 'Actual non-billable expenses for the case; not displayed/used';
COMMENT ON COLUMN sa.table_case2sub_cls.calc_bill_exp IS 'Calculated billable expenses for the case; calculated from T&E logs';
COMMENT ON COLUMN sa.table_case2sub_cls.calc_nonbill IS 'Calculated non-billable expenses for the case; calculated from T&E logs';
COMMENT ON COLUMN sa.table_case2sub_cls.bill_time IS 'Calculated billable time for the case/subcase; calculated from T&E log time items in seconds';
COMMENT ON COLUMN sa.table_case2sub_cls.nonbill_time IS 'Calculated non-billable time for the case/subcase; calculated from T&E log time items in seconds';
COMMENT ON COLUMN sa.table_case2sub_cls.previous_closed IS 'Date/time case/subcase was last closed; earlier than close date if the case has been closed before';