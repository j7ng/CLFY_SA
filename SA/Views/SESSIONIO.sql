CREATE OR REPLACE FORCE VIEW sa.sessionio (user_name,osuser,logon_time,last_call_min,c_gets,b_gets,"READS",ratio,"SID",spid,machine,status) AS
select substr(v$session.username,1,10) user_name,
v$session.OSUSER,
v$session.LOGON_TIME,
round((v$session.LAST_CALL_ET/60),2) last_call_min,
       consistent_gets c_gets,
       block_gets      b_gets,
       physical_reads  reads,
       round(100*(consistent_gets+block_gets-physical_reads)/
           (consistent_gets+block_gets), 2) ratio,
       v$session.sid sid,
       v$process.spid,
      -- v$session.process proc,
      -- terminal term,
       machine,
       v$session.status
  from v$session,
       v$sess_io,
       v$process
 where v$session.sid = v$sess_io.sid
       and v$session.PADDR=v$process.ADDR
   and (consistent_gets+block_gets)>0;