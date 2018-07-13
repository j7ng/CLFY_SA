CREATE TABLE sa.table_biz_cal (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  effective_date DATE,
  dev NUMBER,
  biz_cal2wk_work_hr NUMBER(*,0),
  biz_cal2holiday_grp NUMBER(*,0),
  biz_cal2biz_cal_hdr NUMBER(*,0)
);
ALTER TABLE sa.table_biz_cal ADD SUPPLEMENTAL LOG GROUP dmtsora569206655_0 (biz_cal2biz_cal_hdr, biz_cal2holiday_grp, biz_cal2wk_work_hr, dev, effective_date, objid, title) ALWAYS;