CREATE OR REPLACE TYPE sa.rt_rec_pymnt_score_dtl_type AS OBJECT
(prg_purch_hdr_objid    NUMBER       ,
 score_model_used       VARCHAR2(100),
 score_factors          VARCHAR2(30) ,
 score_score_result     VARCHAR2(30) ,
 score_rcode            NUMBER       ,
 score_rmsg             VARCHAR2(60) ,
 score_rflag            VARCHAR2(30) ,
 score_host_severity    VARCHAR2(30) ,
 score_time_local       VARCHAR2(60) ,
 score_suspicious_info  VARCHAR2(100),
 constructor FUNCTION rt_rec_pymnt_score_dtl_type RETURN SELF AS RESULT
)
/