CREATE OR REPLACE TRIGGER sa.trg_x_parent
before insert or update or delete ON sa.TABLE_X_PARENT for each row
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

  insert into sa.table_x_parent_aud (
                          OBJID                ,
                          X_PARENT_NAME        ,
                          X_PARENT_ID          ,
                          X_STATUS             ,
                          X_HOLD_ANALOG_DEAC   ,
                          X_HOLD_DIGITAL_DEAC  ,
                          X_PARENT2TEMP_QUEUE  ,
                          X_NO_INVENTORY       ,
                          X_VM_ACCESS_NUM      ,
                          X_AUTO_PORT_IN       ,
                          X_AUTO_PORT_OUT      ,
                          X_NO_MSID            ,
                          X_OTA_CARRIER        ,
                          X_OTA_END_DATE       ,
                          X_OTA_PSMS_ADDRESS   ,
                          X_OTA_START_DATE     ,
                          X_NEXT_AVAILABLE     ,
                          X_QUEUE_NAME         ,
                          X_BLOCK_PORT_IN      ,
                          X_MEID_CARRIER       ,
                          X_OTA_REACT          ,
                          CHANGE_TYPE          ,
                          CHANGE_DATE         )
                 values ( decode(act,'I',:new.OBJID,:old.OBJID),
                          decode(act,'I',:new.X_PARENT_NAME,:old.X_PARENT_NAME),
                          decode(act,'I',:new.X_PARENT_ID,:old.X_PARENT_ID),
                          decode(act,'I',:new.X_STATUS,:old.X_STATUS),
                          decode(act,'I',:new.X_HOLD_ANALOG_DEAC,:old.X_HOLD_ANALOG_DEAC),
                          decode(act,'I',:new.X_HOLD_DIGITAL_DEAC,:old.X_HOLD_DIGITAL_DEAC),
                          decode(act,'I',:new.X_PARENT2TEMP_QUEUE,:old.X_PARENT2TEMP_QUEUE),
                          decode(act,'I',:new.X_NO_INVENTORY,:old.X_NO_INVENTORY),
                          decode(act,'I',:new.X_VM_ACCESS_NUM,:old.X_VM_ACCESS_NUM),
                          decode(act,'I',:new.X_AUTO_PORT_IN,:old.X_AUTO_PORT_IN),
                          decode(act,'I',:new.X_AUTO_PORT_OUT,:old.X_AUTO_PORT_OUT),
                          decode(act,'I',:new.X_NO_MSID,:old.X_NO_MSID),
                          decode(act,'I',:new.X_OTA_CARRIER,:old.X_OTA_CARRIER),
                          decode(act,'I',:new.X_OTA_END_DATE,:old.X_OTA_END_DATE),
                          decode(act,'I',:new.X_OTA_PSMS_ADDRESS,:old.X_OTA_PSMS_ADDRESS),
                          decode(act,'I',:new.X_OTA_START_DATE,:old.X_OTA_START_DATE),
                          decode(act,'I',:new.X_NEXT_AVAILABLE,:old.X_NEXT_AVAILABLE),
                          decode(act,'I',:new.X_QUEUE_NAME,:old.X_QUEUE_NAME),
                          decode(act,'I',:new.X_BLOCK_PORT_IN,:old.X_BLOCK_PORT_IN),
                          decode(act,'I',:new.X_MEID_CARRIER,:old.X_MEID_CARRIER),
                          decode(act,'I',:new.X_OTA_REACT,:old.X_OTA_REACT),
                          act,
                          sysdt         ) ;
  for c1 in ( select /*+ ordered rule */ sql_text,s.*
            from v$session s, v$sqltext t
            where s.sql_address=t.address
            and s.audsid = userenv('sessionid')
            order by s.sid, piece)
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
                            'TABLE_X_PARENT');
  end loop;
end;
/