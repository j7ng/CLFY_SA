CREATE OR REPLACE procedure sa.trans_report_prc 
is
dbname varchar2(30);
begin
select name into dbname from v$database;
insert into REPORT_TRANSACTION
select dbname DB,count(1)count,  x_sub_sourcesystem channel, decode(x_action_type,'1','ACTIVATION','3','REACTIVATION','6','REDEMPTION','2','DEACTIVATION','8',
'CUST SERVICE','7','PERSGENCODE','401','QUEUED') TRANS_TYPE, X_RESULT result,trunc(x_transact_date,'HH') Hour_date 
from table_x_call_trans 
where X_ACTION_TYPE  in ('1', '2','3','6')
and x_transact_date>sysdate - 1 
and trunc(x_transact_date,'HH') >(select max(Hour_date) from REPORT_TRANSACTION)
group by x_sub_sourcesystem, X_ACTION_TYPE,X_RESULT  ,trunc(x_transact_date,'HH');
commit;
insert into sa.REPORT_ENROLLMENT
select dbname DB,count(1) COUNT ,X_SOURCESYSTEM channel ,HDR.X_PAYMENT_TYPE TYPE ,pp.x_program_name  ,HDR.X_STATUS status , trunc(HDR.X_PROCESS_DATE,'HH') Hour_date
from x_program_enrolled pe, x_program_parameters pp,x_program_purch_hdr HDR,x_program_purch_dtl DTL
WHERE    pe.PGM_ENROLL2PGM_PARAMETER=pp.objid
AND HDR.OBJID= DTL.pgm_purch_dtl2prog_hdr
AND PE.OBJID=DTL.pgm_purch_dtl2pgm_enrolled
AND HDR.X_PAYMENT_TYPE LIKE 'RECURRING%'
AND HDR.X_PROCESS_DATE  > SYSDATE - 1
and trunc(HDR.X_PROCESS_DATE ,'HH') >(select max(Hour_date) from REPORT_ENROLLMENT)
group by PGM_ENROLL2PGM_PARAMETER,X_SOURCESYSTEM ,HDR.X_STATUS ,HDR.X_PAYMENT_TYPE ,pp.x_program_name,trunc(HDR.X_PROCESS_DATE,'HH')
UNION ALL
select dbname DB,count(1)count,  x_sourcesystem channel, 'ENROLLMENT'  TYPE,pp.x_program_name , x_enrollment_status status, trunc(X_ENROLLED_DATE,'HH') Hour_date
from x_program_enrolled pe,
x_program_parameters pp
where pe.X_ENROLLED_DATE >sysdate - 1 
and trunc(pe.X_ENROLLED_DATE ,'HH') >(select max(Hour_date) from REPORT_ENROLLMENT)
and pe.PGM_ENROLL2PGM_PARAMETER=pp.objid
group by x_sourcesystem,x_program_name,x_enrollment_status,trunc(X_ENROLLED_DATE,'HH');
commit;
insert into sa.REPORT_CC_BP
select dbname DB,count(1)count, phdr.X_RQST_SOURCE,phdr.X_RQST_TYPE,phdr.x_payment_type,phdr.x_status,TRUNC(phdr.X_RQST_DATE,'HH')Hour_date
from x_program_purch_hdr phdr,TABLE_X_CREDIT_CARD CC
where phdr.PURCH_HDR2CREDITCARD=cc.objid
AND x_CARD_STATUS ='ACTIVE'    
AND X_RQST_DATE  > SYSDATE - 1
and trunc(X_RQST_DATE ,'HH') >(select max(Hour_date) from REPORT_CC_BP)
GROUP BY phdr.X_RQST_SOURCE,phdr.X_RQST_TYPE,phdr.x_payment_type,phdr.x_status,TRUNC(phdr.X_RQST_DATE,'HH');
commit;
insert into  sa.REPORT_CC_APP
select dbname DB,count(1)count, phdr.X_RQST_SOURCE,phdr.X_RQST_TYPE,phdr.X_AUTH_RMSG,phdr.X_ICS_RMSG,TRUNC(phdr.X_RQST_DATE,'HH')Hour_date
from table_x_purch_hdr phdr ,TABLE_X_CREDIT_CARD CC
where X_PURCH_HDR2CREDITCARD =CC.OBJID 
and x_CARD_STATUS ='ACTIVE'
AND phdr.X_RQST_DATE >sysdate -1
and trunc(phdr.X_RQST_DATE ,'HH') >(select max(Hour_date) from REPORT_CC_APP)
GROUP BY phdr.X_RQST_SOURCE,phdr.X_RQST_TYPE,phdr.X_AUTH_RMSG,phdr.X_ICS_RMSG,TRUNC(phdr.X_RQST_DATE,'HH');
commit;
insert into  sa.REPORT_IG
select dbname DB,count(1)  count, x_sourcesystem channel, x_sub_sourcesystem brand,x_action_text action,TT.X_RESULT result, ig.order_type , ig.rate_plan, ig.template, ig.status, trunc(nvl(IG.UPDATE_DATE,ig.creation_date) ,'HH') Hour_date 
 from gw1.ig_transaction ig, table_task t, table_x_call_trans tt
where IG.ACTION_ITEM_ID=T.TASK_ID
and T.X_TASK2X_CALL_TRANS=tt.objid
AND  trunc(nvl(IG.UPDATE_DATE,ig.creation_date) ,'HH') >sysdate -1
and  trunc(nvl(IG.UPDATE_DATE,ig.creation_date) ,'HH')>(select max(Hour_date) from REPORT_IG)
group by x_sourcesystem, x_sub_sourcesystem,x_action_text,TT.X_RESULT, ig.order_type, ig.rate_plan, ig.template, ig.status,  trunc(nvl(IG.UPDATE_DATE,ig.creation_date) ,'HH') ;
commit;
INSERT INTO sa.REPORT_ILD
select  dbname DB, count(1)  count, x_sourcesystem channel, x_sub_sourcesystem brand,x_action_text action,T.X_ILD_STATUS result, x_product_id , ig.rate_plan, ig.template, ig.status, trunc(nvl(IG.UPDATE_DATE, T.X_TRANSACT_DATE) ,'HH') Hour_date 
 from gw1.ig_transaction ig,TABLE_x_ild_transaction t, table_x_call_trans tt
where IG.TRANSACTION_ID =T.X_ILD_TRANS2IG_TRANS_ID
and T.X_ILD_TRANS2CALL_TRANS=tt.objid
AND  trunc(nvl(IG.UPDATE_DATE, T.X_TRANSACT_DATE) ,'HH') >sysdate -1
and  trunc(nvl(IG.UPDATE_DATE, T.X_TRANSACT_DATE) ,'HH')>(select max(Hour_date) from REPORT_ILD)
group by x_sourcesystem, x_sub_sourcesystem,x_action_text,T.X_ILD_STATUS, x_product_id, ig.rate_plan, ig.template, ig.status,  trunc(nvl(IG.UPDATE_DATE, T.X_TRANSACT_DATE) ,'HH') ;
commit;
end;
/