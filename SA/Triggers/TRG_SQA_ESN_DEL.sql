CREATE OR REPLACE TRIGGER sa.TRG_sqa_esn_DEL
before DELETE ON sa.sqa_esn
for each row
declare
sysdt date := sysdate;
begin

  for c1 in (select /*+ ordered rule */
 s.*
from v$session s
where s.audsid = userenv('sessionid')
         )
  loop
       insert into sa.sqa_esn_DEL (
                                USERNAME     ,
                                OSUSER       ,
                                PROCESS      ,
                                MACHINE      ,
                                TERMINAL     ,
                                PROGRAM      ,
                                LOGON_TIME   ,
                                DT           ,
                           ESN)
                      values (
                               c1.username,
                               c1.osuser,
                               c1.process,
                               c1.machine,
                               c1.terminal,
                               c1.program,
                               c1.logon_time,
                               sysdt,  :OLD.ESN
);
  end loop;
end;
/