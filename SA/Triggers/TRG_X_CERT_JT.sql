CREATE OR REPLACE TRIGGER sa.TRG_X_CERT_JT
before insert or update or delete on sa.x_cert
for each row
declare
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
  for c1 in (     select /*+ ordered rule */ s.*
            from v$session s
            where  s.audsid = userenv('sessionid') )
 LOOP           
       insert into sa.x_cert_his (
                              SID              ,
ACTION           ,
USERNAME         ,
OSUSER           ,
PROCESS          ,
MACHINE          ,
TERMINAL         ,
PROGRAM          ,
LOGON_TIME       ,
DT               ,
OLD_OBJID        ,
OLD_X_CERT       ,
OLD_X_KEY_ALGO   ,
OLD_X_CC_ALGO    ,
OLD_CREATE_DATE  ,
OLD_NOTES        ,
NEW_OBJID        ,
NEW_X_CERT       ,
NEW_X_KEY_ALGO   ,
NEW_X_CC_ALGO    ,
NEW_CREATE_DATE  ,
NEW_NOTES        )
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
                :OLD.OBJID        ,
:OLD.X_CERT       ,
:OLD.X_KEY_ALGO   ,
:OLD.X_CC_ALGO    ,
:OLD.CREATE_DATE  ,
:OLD.NOTES        ,
:NEW.OBJID        ,
:NEW.X_CERT       ,
:NEW.X_KEY_ALGO   ,
:NEW.X_CC_ALGO    ,
:NEW.CREATE_DATE  ,
:NEW.NOTES        );
  end loop;
end;
/