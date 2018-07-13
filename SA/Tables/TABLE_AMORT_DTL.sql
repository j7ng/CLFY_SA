CREATE TABLE sa.table_amort_dtl (
  objid NUMBER,
  bill_prd_amt NUMBER(19,4),
  prd_start_dt DATE,
  prd_end_dt DATE,
  last_gen_dt DATE,
  net_prd_amt NUMBER(19,4),
  dev NUMBER,
  amort_dtl2contr_pr NUMBER(*,0),
  amort_dtl2period_amt NUMBER(*,0),
  amort_dtl2contr_itm NUMBER(*,0),
  detail2contr_schedule NUMBER(*,0),
  detail2trans_record NUMBER(*,0)
);
ALTER TABLE sa.table_amort_dtl ADD SUPPLEMENTAL LOG GROUP dmtsora1187051962_0 (amort_dtl2contr_itm, amort_dtl2contr_pr, amort_dtl2period_amt, bill_prd_amt, detail2contr_schedule, detail2trans_record, dev, last_gen_dt, net_prd_amt, objid, prd_end_dt, prd_start_dt) ALWAYS;