CREATE OR REPLACE TRIGGER sa.TRG_table_x_parameters_JT
before insert or update or delete on sa.table_x_parameters
for each row
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
       insert into sa.table_x_parameters_his (
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
                                OLD_OBJID         ,
OLD_DEV           ,
OLD_X_PARAM_NAME  ,
OLD_X_PARAM_VALUE ,
OLD_X_NOTES       ,
NEW_OBJID         ,
NEW_DEV           ,
NEW_X_PARAM_NAME  ,
NEW_X_PARAM_VALUE ,
NEW_X_NOTES        )
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
                                :OLD.OBJID         ,
 :OLD.DEV           ,
 :OLD.X_PARAM_NAME  ,
 :OLD.X_PARAM_VALUE ,
 :OLD.X_NOTES       ,
 :NEW.OBJID         ,
 :NEW.DEV           ,
 :NEW.X_PARAM_NAME  ,
 :NEW.X_PARAM_VALUE ,
 :NEW.X_NOTES       );
  end loop;
end;
/