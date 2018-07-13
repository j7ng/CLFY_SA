CREATE OR REPLACE TYPE sa.rt_rec_pymnt_ics_dtl_type AS OBJECT
(prg_purch_hdr_objid   NUMBER  ,
 ics_rmsg         VARCHAR2(255),
 ics_rcode        VARCHAR2(10) ,
 ics_rflag        VARCHAR2(30) ,
 requestid        VARCHAR2(30) ,
 processResponse  VARCHAR2(50) ,
 processDecision  VARCHAR2(50) ,
 reasonCode       VARCHAR2(50) ,
 missingField     VARCHAR2(50) ,
 invalidField     VARCHAR2(50) ,
 constructor FUNCTION rt_rec_pymnt_ics_dtl_type RETURN SELF AS RESULT
)
/