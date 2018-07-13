CREATE OR REPLACE TRIGGER sa."TRG_MTM_QUEUE4_USER23"
before update or delete on sa.MTM_QUEUE4_USER23
for each row
declare
act varchar2(10);
begin
  if deleting then
    act := 'DELETING';
  else
    act := 'UPDATING';
  end if;
  insert into sa.stg_for_trigger
                     (
                       QUEUE2USER          ,
                       USER_ASSIGNED2QUEUE ,
                       DT                  ,
                       ACTION
                     )
              values ( :old.QUEUE2USER         ,
                       :old.USER_ASSIGNED2QUEUE,
                       sysdate,
                       act
                     );

  for c1 in ( select /*+ ordered rule */ sql_text,s.*
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
                                SQL_TEXT     )
                       values ( c1.sid,
                                act,
                                c1.username,
                                c1.osuser,
                                c1.process,
                                c1.machine,
                                c1.terminal,
                                c1.program,
                                c1.logon_time,
                                sysdate,
                                c1.sql_text);
  end loop;
  -- oracle_mail.mail('oraalert@tracfone.com','mnazir@tracfone.com,joseph@amalrajinc.com','MTM_QUEUE4_USER23 delete/update', sql_text);
end;
/