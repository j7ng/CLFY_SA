CREATE OR REPLACE TYPE sa.rt_rec_pymnt_bill_dtl_type AS OBJECT
(prg_purch_hdr_objid    NUMBER      ,
 bill_rcode             NUMBER      ,
 bill_rflag             VARCHAR2(30),
 bill_rmsg              VARCHAR2(60),
 bill_bill_amount       NUMBER      ,
 bill_trans_ref_no      VARCHAR2(30),
 bill_bill_request_time VARCHAR2(20),
 constructor FUNCTION rt_rec_pymnt_bill_dtl_type RETURN SELF AS RESULT
)
/