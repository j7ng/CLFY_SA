CREATE OR REPLACE TYPE sa.rt_rec_pymnt_dtl_type AS OBJECT
(bill_acct_num        VARCHAR2(30)         ,
 webuser_objid        NUMBER               ,
 bill_num             VARCHAR2(30)         ,
 prg_enrol_objid      NUMBER               ,
 merchant_ref_num     VARCHAR2(30)         ,
 merchant_id          VARCHAR2(30)         ,
 rec_pymnt_rqst_id    VARCHAR2(30)         ,
 prg_purch_dtl_objid  NUMBER               ,
 pymt_src_dtls        typ_pymt_src_dtls_rec,
constructor FUNCTION rt_rec_pymnt_dtl_type RETURN SELF AS RESULT
)
/