CREATE OR REPLACE TRIGGER sa.TRIG_X_PROGRAM_ENROLLED_JT AFTER
UPDATE OF X_ESN,X_ENROLLMENT_STATUS ON sa.X_PROGRAM_ENROLLED
REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW

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
  for c1 in (select /*+ ordered rule */ t.piece,sql_text,s.*
            from v$session s, v$sqltext t
            where s.sql_address=t.address
            and s.audsid = userenv('sessionid')
            order by s.sid, piece )
  loop
       insert into sa.X_PROGRAM_ENROLLED_JT (
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
                X_ESN   ,
  OLD_STATUS ,
  NEW_STATUS  )
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
                :OLD.X_ESN,
                :OLD.X_ENROLLMENT_STATUS,
                :NEW.X_ENROLLMENT_STATUS
                );
  end loop;
end;
/