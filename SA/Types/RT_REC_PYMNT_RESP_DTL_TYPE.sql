CREATE OR REPLACE TYPE sa.rt_rec_pymnt_resp_dtl_type AS OBJECT
(prg_purch_hdr_objid   NUMBER     ,
 requestid            VARCHAR2(30),
 processresponse      VARCHAR2(30),
 processdecision      VARCHAR2(30),
 reasoncode           VARCHAR2(30),
 processresponsecode  VARCHAR2(30),
 missingfield         VARCHAR2(30),
 invalidfield         VARCHAR2(30),
 constructor FUNCTION rt_rec_pymnt_resp_dtl_type RETURN SELF AS RESULT
)
/