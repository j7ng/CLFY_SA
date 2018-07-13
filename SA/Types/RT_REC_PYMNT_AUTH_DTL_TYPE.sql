CREATE OR REPLACE TYPE sa.rt_rec_pymnt_auth_dtl_type AS OBJECT
(prg_purch_hdr_objid   NUMBER       ,
 auth_type             VARCHAR2(100),
 auth_request_id       VARCHAR2(30) ,
 auth_auth_avs         VARCHAR2(30) ,
 auth_cv_result        VARCHAR2(30) ,
 auth_auth_response    VARCHAR2(60) ,
 auth_avs_raw          VARCHAR2(30) ,
 auth_auth_time        VARCHAR2(20) ,
 auth_rflag            VARCHAR2(30) ,
 auth_auth_amount      NUMBER       ,
 auth_rcode            NUMBER       ,
 auth_trans_ref_no     VARCHAR2(100),
 auth_auth_code        VARCHAR2(100),
 auth_rmsg             VARCHAR2(255),
 auth_request_token    VARCHAR2(100),
 auth_recon_id         VARCHAR2(100),
 constructor FUNCTION rt_rec_pymnt_auth_dtl_type RETURN SELF AS RESULT
)
/