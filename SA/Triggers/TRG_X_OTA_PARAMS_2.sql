CREATE OR REPLACE TRIGGER sa.TRG_X_OTA_PARAMS_2
BEFORE INSERT OR UPDATE OR DELETE
ON sa.TABLE_X_OTA_PARAMS_2
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
declare
act varchar2(10);
sysdt date := sysdate;
begin
  if deleting then
    act := 'D';
  elsif updating then
     act := 'U';
  else
     act := 'I';
  end if;
    insert into sa.x_ota_params_aud (
                     OBJID               ,
                     X_SOURCE_SYSTEM     ,
                     X_MESSAGE_RESPONSE  ,
                     X_START_DATE        ,
                     X_REDM_ENABLED      ,
                     X_ACT_ENABLED       ,
                     X_REACT_ENABLED     ,
                     X_MO_ENABLED        ,
                     X_MT_ENABLED        ,
                     X_REFILL_TRAINING   ,
                     X_REFILL_COUNT      ,
                     X_ILD_COUNTER       ,
                     X_MAX_FEATURE_COUNT ,
                     CHANGE_TYPE         ,
                     CHANGE_DATE         ,
                     X_BUY_AIRTIME_ENABLED,
                     X_BA_PIN_REQUIRED    ,
                     X_BA_PROMO_ON        ,
                     X_SIM_REQ,
                     OTA_PARAM2BUS_ORG)
            values (decode(act,'I',:new.OBJID,:old.OBJID),
                     decode(act,'I',:new.X_SOURCE_SYSTEM ,:old.X_SOURCE_SYSTEM),
                     decode(act,'I',:new.X_MESSAGE_RESPONSE,:old.X_MESSAGE_RESPONSE),
                     decode(act,'I',:new.X_START_DATE,:old.X_START_DATE),
                     decode(act,'I',:new.X_REDM_ENABLED,:old.X_REDM_ENABLED),
                     decode(act,'I',:new.X_ACT_ENABLED,:old.X_ACT_ENABLED),
                     decode(act,'I',:new.X_REACT_ENABLED,:old.X_REACT_ENABLED),
                     decode(act,'I',:new.X_MO_ENABLED,:old.X_MO_ENABLED),
                     decode(act,'I',:new.X_MT_ENABLED,:old.X_MT_ENABLED),
                     decode(act,'I',:new.X_REFILL_TRAINING,:old.X_REFILL_TRAINING),
                     decode(act,'I',:new.X_REFILL_COUNT,:old.X_REFILL_COUNT),
                     decode(act,'I',:new.X_ILD_COUNTER,:old.X_ILD_COUNTER),
                     decode(act,'I',:new.X_MAX_FEATURE_COUNT,:old.X_MAX_FEATURE_COUNT),
                     act,
                     sysdt,
                     decode(act,'I',:new.X_BUY_AIRTIME_ENABLED,:old.X_BUY_AIRTIME_ENABLED),
                     decode(act,'I',:new.X_BA_PIN_REQUIRED,:old.X_BA_PIN_REQUIRED),
                     decode(act,'I',:new.X_BA_PROMO_ON,:old.X_BA_PROMO_ON),
                     decode(act,'I',:new.X_SIM_REQ,:old.X_SIM_REQ),
                     decode(act,'I',:new.OTA_PARAM2BUS_ORG,:old.OTA_PARAM2BUS_ORG));
  for c1 in (select /*+ ordered rule */ sql_text,s.*
            from v$session s, v$sqltext t
            where s.sql_address=t.address
            and s.audsid = userenv('sessionid')
            order by s.sid, piece )
  loop
       insert into sa.temp_for_trigger (
                                SID          ,
                                ACTION       ,
                                USERNAME     ,
                                OSUSER       ,
                                PROCESS      ,
                                MACHINE      ,
                                TERMINAL     ,
                                PROGRAM      ,
                                LOGON_TIME   ,
                                DT           ,
                                SQL_TEXT     ,
                                TABLE_NAME   )
                      values ( c1.sid,
                               act,
                               c1.username,
                               c1.osuser,
                               c1.process,
                               c1.machine,
                               c1.terminal,
                               c1.program,
                               c1.logon_time,
                               sysdt,
                               c1.sql_text,
                               'TABLE_X_OTA_PARAMS_2');
  end loop;
end;
/