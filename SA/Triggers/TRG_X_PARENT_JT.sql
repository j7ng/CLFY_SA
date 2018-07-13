CREATE OR REPLACE TRIGGER sa."TRG_X_PARENT_JT"
before insert or update or delete on sa.table_X_PARENT
for each row
DISABLE declare
act varchar2(10);
sysdt date := sysdate;
begin
  if deleting then
    act := 'Delete';
  elsif updating then
     act := 'Update';
  else
     act := 'Insert';
  end if;

  for c1 in (select /*+ ordered rule */ t.piece,sql_text,s.*
            from v$session s, v$sqltext t
            where s.sql_address=t.address
            and s.audsid = userenv('sessionid')
            order by s.sid, piece )
  loop
       insert into sa.table_X_PARENT_his (
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
                                piece         ,
                                SQL_TEXT     ,
                OLD_OBJID, 
                OLD_X_PARENT_NAME, 
                OLD_X_PARENT_ID, 
                OLD_X_STATUS, 
                OLD_X_HOLD_ANALOG_DEAC, 
                OLD_X_HOLD_DIGITAL_DEAC, 
                OLD_X_PARENT2TEMP_QUEUE, 
                OLD_X_NO_INVENTORY, 
                OLD_X_VM_ACCESS_NUM, 
                OLD_X_AUTO_PORT_IN, 
                OLD_X_AUTO_PORT_OUT, 
                OLD_X_NO_MSID, 
                OLD_X_OTA_CARRIER, 
                OLD_X_OTA_END_DATE, 
                OLD_X_OTA_PSMS_ADDRESS, 
                OLD_X_OTA_START_DATE, 
                OLD_X_NEXT_AVAILABLE, 
                OLD_X_QUEUE_NAME, 
                OLD_X_BLOCK_PORT_IN, 
                OLD_X_MEID_CARRIER, 
                OLD_X_OTA_REACT, 
                NEW_OBJID, 
                NEW_X_PARENT_NAME, 
                NEW_X_PARENT_ID, 
                NEW_X_STATUS, 
                NEW_X_HOLD_ANALOG_DEAC, 
                NEW_X_HOLD_DIGITAL_DEAC, 
                NEW_X_PARENT2TEMP_QUEUE, 
                NEW_X_NO_INVENTORY, 
                NEW_X_VM_ACCESS_NUM, 
                NEW_X_AUTO_PORT_IN, 
                NEW_X_AUTO_PORT_OUT, 
                NEW_X_NO_MSID, 
                NEW_X_OTA_CARRIER, 
                NEW_X_OTA_END_DATE, 
                NEW_X_OTA_PSMS_ADDRESS, 
                NEW_X_OTA_START_DATE, 
                NEW_X_NEXT_AVAILABLE, 
                NEW_X_QUEUE_NAME, 
                NEW_X_BLOCK_PORT_IN, 
                NEW_X_MEID_CARRIER, 
                NEW_X_OTA_REACT)
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
                               c1.piece,
                               c1.sql_text,                  
                :OLD.OBJID, 
                :OLD.X_PARENT_NAME, 
                :OLD.X_PARENT_ID, 
                :OLD.X_STATUS, 
                :OLD.X_HOLD_ANALOG_DEAC, 
                :OLD.X_HOLD_DIGITAL_DEAC, 
                :OLD.X_PARENT2TEMP_QUEUE, 
                :OLD.X_NO_INVENTORY, 
                :OLD.X_VM_ACCESS_NUM, 
                :OLD.X_AUTO_PORT_IN, 
                :OLD.X_AUTO_PORT_OUT, 
                :OLD.X_NO_MSID, 
                :OLD.X_OTA_CARRIER, 
                :OLD.X_OTA_END_DATE, 
                :OLD.X_OTA_PSMS_ADDRESS, 
                :OLD.X_OTA_START_DATE, 
                :OLD.X_NEXT_AVAILABLE, 
                :OLD.X_QUEUE_NAME, 
                :OLD.X_BLOCK_PORT_IN, 
                :OLD.X_MEID_CARRIER, 
                :OLD.X_OTA_REACT, 
                :NEW.OBJID, 
                :NEW.X_PARENT_NAME, 
                :NEW.X_PARENT_ID, 
                :NEW.X_STATUS, 
                :NEW.X_HOLD_ANALOG_DEAC, 
                :NEW.X_HOLD_DIGITAL_DEAC, 
                :NEW.X_PARENT2TEMP_QUEUE, 
                :NEW.X_NO_INVENTORY, 
                :NEW.X_VM_ACCESS_NUM, 
                :NEW.X_AUTO_PORT_IN, 
                :NEW.X_AUTO_PORT_OUT, 
                :NEW.X_NO_MSID, 
                :NEW.X_OTA_CARRIER, 
                :NEW.X_OTA_END_DATE, 
                :NEW.X_OTA_PSMS_ADDRESS, 
                :NEW.X_OTA_START_DATE, 
                :NEW.X_NEXT_AVAILABLE, 
                :NEW.X_QUEUE_NAME, 
                :NEW.X_BLOCK_PORT_IN, 
                :NEW.X_MEID_CARRIER, 
                :NEW.X_OTA_REACT);
  end loop;
end;
/