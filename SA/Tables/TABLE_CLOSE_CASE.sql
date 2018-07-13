CREATE TABLE sa.table_close_case (
  objid NUMBER,
  close_date DATE,
  actl_phone_time NUMBER,
  calc_phone_time NUMBER,
  actl_rsrch_time NUMBER,
  calc_rsrch_time NUMBER,
  used_unit NUMBER,
  "SUMMARY" VARCHAR2(255 BYTE),
  tot_actl_phone_time NUMBER,
  tot_actl_rsrch_time NUMBER,
  actl_bill_exp NUMBER(19,4),
  actl_nonbill NUMBER(19,4),
  calc_bill_exp NUMBER(19,4),
  calc_nonbill NUMBER(19,4),
  tot_actl_bill NUMBER(19,4),
  tot_actl_nonb NUMBER(19,4),
  bill_time NUMBER,
  nonbill_time NUMBER,
  previous_closed DATE,
  dev NUMBER,
  last_close2case NUMBER(*,0),
  closer2employee NUMBER(*,0),
  close_case2act_entry NUMBER(*,0),
  close_rsolut2gbst_elm NUMBER(*,0),
  cls_old_stat2gbst_elm NUMBER(*,0),
  cls_new_stat2gbst_elm NUMBER(*,0),
  close_case2subcase NUMBER(*,0),
  close_case2case_resol NUMBER
);
ALTER TABLE sa.table_close_case ADD SUPPLEMENTAL LOG GROUP dmtsora353922026_0 (actl_bill_exp, actl_nonbill, actl_phone_time, actl_rsrch_time, bill_time, calc_bill_exp, calc_nonbill, calc_phone_time, calc_rsrch_time, closer2employee, close_case2act_entry, close_case2case_resol, close_case2subcase, close_date, close_rsolut2gbst_elm, cls_new_stat2gbst_elm, cls_old_stat2gbst_elm, dev, last_close2case, nonbill_time, objid, previous_closed, "SUMMARY", tot_actl_bill, tot_actl_nonb, tot_actl_phone_time, tot_actl_rsrch_time, used_unit) ALWAYS;
COMMENT ON TABLE sa.table_close_case IS 'Close case object which records case or subcase closure activity and contains the case/subcase metrics';
COMMENT ON COLUMN sa.table_close_case.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_close_case.close_date IS 'Case close date and time';
COMMENT ON COLUMN sa.table_close_case.actl_phone_time IS 'Actual elapsed time spent on the phone for the case or subcase; entered by user if different from captured phone time in seconds';
COMMENT ON COLUMN sa.table_close_case.calc_phone_time IS 'Time spent on the phone for the case or subcase; calculated from phone logs';
COMMENT ON COLUMN sa.table_close_case.actl_rsrch_time IS 'Actual elapsed time spent doing research for the case or subcase; entered by user if different from captured research time in seconds';
COMMENT ON COLUMN sa.table_close_case.calc_rsrch_time IS 'Elapsed time spent doing research for the case or subcase; calculated from research logs in seconds';
COMMENT ON COLUMN sa.table_close_case.used_unit IS 'Number of contract units used';
COMMENT ON COLUMN sa.table_close_case."SUMMARY" IS 'Close case summary';
COMMENT ON COLUMN sa.table_close_case.tot_actl_phone_time IS 'Total actual elapsed time spent on the phone, including both captured and added time, for the case and all its subcases in seconds';
COMMENT ON COLUMN sa.table_close_case.tot_actl_rsrch_time IS 'Total elapsed time spent doing research for the case and all its subcases in seconds';
COMMENT ON COLUMN sa.table_close_case.actl_bill_exp IS 'Actual billable expenses for the case; not displayed/used';
COMMENT ON COLUMN sa.table_close_case.actl_nonbill IS 'Actual non-billable expenses for the case; not displayed/used';
COMMENT ON COLUMN sa.table_close_case.calc_bill_exp IS 'Calculated billable expenses for the case; calculated from T&E logs';
COMMENT ON COLUMN sa.table_close_case.calc_nonbill IS 'Calculated non-billable expenses for the case; calculated from T&E logs';
COMMENT ON COLUMN sa.table_close_case.tot_actl_bill IS 'Total actual billable expenses for the case and all subcases; not displayed/used';
COMMENT ON COLUMN sa.table_close_case.tot_actl_nonb IS 'Total actual non-billable expenses for the case and all subcases; not displayed/used';
COMMENT ON COLUMN sa.table_close_case.bill_time IS 'Calculated billable time for the case/subcase; calculated from T&E log time items in seconds';
COMMENT ON COLUMN sa.table_close_case.nonbill_time IS 'Calculated non-billable time for the case/subcase; calculated from T&E log time items in seconds';
COMMENT ON COLUMN sa.table_close_case.previous_closed IS 'Date/time case/subcase was last closed; earlier than close date if the case has been closed before';
COMMENT ON COLUMN sa.table_close_case.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_close_case.last_close2case IS 'Case for which this is a close case entry';
COMMENT ON COLUMN sa.table_close_case.closer2employee IS 'Employee who closed case';
COMMENT ON COLUMN sa.table_close_case.close_case2act_entry IS 'Activity log entry';
COMMENT ON COLUMN sa.table_close_case.close_rsolut2gbst_elm IS 'Resolution code for close case entry; defined as a Clarify-defined pop up list item';
COMMENT ON COLUMN sa.table_close_case.cls_old_stat2gbst_elm IS 'Status before the case was closed';
COMMENT ON COLUMN sa.table_close_case.cls_new_stat2gbst_elm IS 'Status after the case was closed';
COMMENT ON COLUMN sa.table_close_case.close_case2subcase IS 'Subcase closed by the activity';