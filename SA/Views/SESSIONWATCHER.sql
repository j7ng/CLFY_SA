CREATE OR REPLACE FORCE VIEW sa.sessionwatcher ("SID",serial#,spid,pid,status,username,osuser,machine,schemaname,terminal,"PROGRAM",lockwait,b_get,c_get,p_read,ratio,sql_text,logon_time,hours,last_call,open_cursor) AS
SELECT DISTINCT
            v$session.sid,
            v$session.serial#,
            v$process.spid,
            v$process.pid,
            v$session.status,
            v$session.username,
            v$session.osuser,
            v$session.machine,
            v$session.SCHEMANAME,
            v$session.terminal,
            v$session.program,
            v$session.LOCKWAIT,
            v$sess_io.BLOCK_GETS b_get,
            v$sess_io.CONSISTENT_GETS c_get,
            v$sess_io.PHYSICAL_READS p_read,
            ROUND (
               100
               * (  v$sess_io.BLOCK_GETS
                  + v$sess_io.CONSISTENT_GETS
                  - v$sess_io.PHYSICAL_READS)
               / DECODE ( (v$sess_io.BLOCK_GETS + v$sess_io.CONSISTENT_GETS),
                         0, 1,
                         (v$sess_io.BLOCK_GETS + v$sess_io.CONSISTENT_GETS)),
               2)
               ratio,
            NVL (v$sql.sql_text, 'No SQL Body') Sql_text,
            v$session.logon_time,
            ROUND ( (SYSDATE - v$session.logon_time) * 24, 2) hours,
            TRUNC (v$session.last_call_et / 60, 2) LAST_CALL,
            NVL (oc.open_cursors, 0) open_cursor
       FROM v$session,
            v$process,
            v$sess_io,
            v$sql,
            (  SELECT sid, COUNT (*) OPEN_CURSORS
                 FROM v$open_cursor
             GROUP BY sid) oc
      WHERE     v$session.TYPE <> 'BACKGROUND'
            AND v$session.username NOT IN ('SYSMAN', 'SYSTEM', 'SYS')
            AND v$session.sql_address = v$sql.address(+)
            AND v$session.sid = oc.sid(+)
            AND v$session.sid = v$sess_io.sid(+)
            AND v$session.PADDR = v$process.ADDR
   ORDER BY status, NVL (oc.open_cursors, 0) DESC;