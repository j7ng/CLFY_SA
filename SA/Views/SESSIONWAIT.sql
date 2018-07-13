CREATE OR REPLACE FORCE VIEW sa.sessionwait (username,machine,"SID",buffer_gets,disk_reads,executions,get_per_exec,read_per_exec,nl) AS
select v$session.username,
       V$SESSION.MACHINE,
       v$session_wait.sid,
       v$sqlarea.BUFFER_GETS,
       v$sqlarea.DISK_READS,
       v$sqlarea.EXECUTIONS ,
       ROUND(v$sqlarea.BUFFER_GETS/decode(v$sqlarea.EXECUTIONS,null,1,0,1,v$sqlarea.EXECUTIONS),2) get_per_exec,
      ROUND( v$sqlarea.DISK_READS/decode(v$sqlarea.EXECUTIONS,null,1,0,1,v$sqlarea.EXECUTIONS),2) read_per_exec,
       v$sqlarea.sql_text nl
  from v$session, v$sqlarea, v$session_wait
 where (v$session_wait.event  like '%buffer%' or
        v$session_wait.event  like '%write%' or
        v$session_wait.event  like '%read%')
   and v$session_wait.sid    = v$session.sid
   and v$session.sql_address = v$sqlarea.address
   and v$session.sql_hash_value = v$sqlarea.hash_value;