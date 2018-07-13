CREATE OR REPLACE FORCE VIEW sa.check_trigger ("OWNER",trigger_name,table_owner,table_name,prd_status,sit1_status,prd_type,sit__type,prd_event,sit__event) AS
SELECT a.owner, a.trigger_name  , a.table_owner, a.table_name, a.STATUS prd_STATUS, b.STATUS SIT1_STATUS, a.trigger_type prd_type, b.trigger_type sit__type, a.triggering_event prd_event, b.triggering_event sit__event
 from trigger_rtrp@jt_samp  a,      dba_triggers b
 where a.owner not in ('TOAD') and b.owner not in ('TOAD') and a.trigger_name=b.trigger_name  and a.STATUS<>b.STATUS  and a.table_owner=b.table_owner and a.table_name=b.table_name
 and a.trigger_name not in ('T_CALL_TRANS_EXT','TRIG_RTC_ACTIVATION','TRIG_RTC_ONACC_PWRESET') and a.trigger_name not like '%BIUD'
 union
 SELECT  a.owner,a.trigger_name  , a.table_owner, a.table_name, a.STATUS prd_STATUS, 'MISSING' SIT1_STATUS, a.trigger_type prd_type, 'MISSING'  sit__type, a.triggering_event prd_event, 'MISSING'  sit__event  from trigger_rtrp@jt_samp   a
 where a.owner not in ('TOAD','T_CALL_TRANS_EXT') and a.STATUS<>'DISABLED' and a.trigger_name not like '%BIUD'and  a.trigger_name  not in (select    trigger_name from     dba_triggers) and exists  (select 1 from dba_tables c where a.table_owner=c.owner and  a.table_name =c.table_name)
 and trigger_name not in ('TRG_USER_LDAP_AIU','T_CALL_TRANS_EXT')
 union
 select  a.owner,a.trigger_name  , a.table_owner, a.table_name, 'N/A'  prd_STATUS, a.STATUS SIT1_STATUS, 'N/A' prd_type, trigger_type sit__type, 'N/A' prd_event, triggering_event sit__event   from dba_triggers       a
WHERE (TRIGGER_NAME LIKE '%BLK%' )AND OWNER='SA' AND STATUS='DISABLED';