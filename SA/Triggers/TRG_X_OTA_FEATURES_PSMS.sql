CREATE OR REPLACE TRIGGER sa.TRG_x_ota_features_psms
BEFORE INSERT OR UPDATE of x_psms_destination_addr ON sa.table_x_ota_features for each row
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

  for c1 in (     select /*+ ordered rule */ s.*
            from v$session s
            where  s.audsid = userenv('sessionid') )
  loop
       insert into sa.table_x_ota_features_psms (
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
 OBJID                       ,
 X_OTA_FEATURES2PART_INST    ,
 OLD_X_PSMS_DESTINATION_ADDR        ,
 NEW_X_PSMS_DESTINATION_ADDR
)
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
 :NEW.OBJID               ,
 :NEW.X_OTA_FEATURES2PART_INST           ,
 :OLD.x_psms_destination_addr   ,
 :NEW.x_psms_destination_addr );
  end loop;
end;
/