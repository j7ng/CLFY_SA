CREATE OR REPLACE FORCE VIEW sa.table_site_biz_cal (biz_cal_hdr_objid,biz_cal_objid,wk_work_hr_objid,effective_date,coverage_name,s_coverage_name,total_hour) AS
select table_biz_cal.biz_cal2biz_cal_hdr, table_biz_cal.objid,
 table_wk_work_hr.objid, table_biz_cal.effective_date,
 table_wk_work_hr.title, table_wk_work_hr.S_title, table_wk_work_hr.total_hour
 from table_biz_cal, table_wk_work_hr
 where table_wk_work_hr.objid = table_biz_cal.biz_cal2wk_work_hr
 AND table_biz_cal.biz_cal2biz_cal_hdr IS NOT NULL
 ;
COMMENT ON TABLE sa.table_site_biz_cal IS 'Used by form Business Hours (287)';
COMMENT ON COLUMN sa.table_site_biz_cal.biz_cal_hdr_objid IS 'Biz_cal_hdr internal record number';
COMMENT ON COLUMN sa.table_site_biz_cal.biz_cal_objid IS 'Biz cal internal record number';
COMMENT ON COLUMN sa.table_site_biz_cal.wk_work_hr_objid IS 'Wk_work_hr internal record number';
COMMENT ON COLUMN sa.table_site_biz_cal.effective_date IS 'Date/time the calendar takes effect at the site';
COMMENT ON COLUMN sa.table_site_biz_cal.coverage_name IS 'Name of the business calendar';
COMMENT ON COLUMN sa.table_site_biz_cal.total_hour IS 'Total hours in the business calendar for each work week';