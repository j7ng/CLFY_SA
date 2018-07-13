CREATE OR REPLACE TYPE sa.rt_rec_pymnt_enrl_hdr_type AS OBJECT
( bill_acct_num          VARCHAR2(30),
  webuser_objid          NUMBER      ,
  bill_num               VARCHAR2(30),
  src_system             VARCHAR2(30),
  sales_tax_rate         NUMBER      ,
  sales_tax_amount       NUMBER      ,
  e911_tax_rate          NUMBER      ,
  e911_tax_amount        NUMBER      ,
  usf_tax_rate           NUMBER      ,
  usf_tax_amount         NUMBER      ,
  rcrf_tax_rate          NUMBER      ,
  rcrf_tax_amount        NUMBER      ,
  total_tax_amount       NUMBER      ,
  amount_without_tax     NUMBER      ,
  total_amount           NUMBER      ,
  discount_amt           NUMBER      ,
  constructor FUNCTION rt_rec_pymnt_enrl_hdr_type RETURN SELF AS RESULT
)
/