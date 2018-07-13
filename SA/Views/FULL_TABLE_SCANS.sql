CREATE OR REPLACE FORCE VIEW sa.full_table_scans ("SID","User Process","Short Scans","Long Scans","Rows Retrieved") AS
SELECT ss.sid, ss.username || '(' || se.sid || ') ' "User Process",
            SUM (DECODE (NAME, 'table scans (short tables)', VALUE))
               "Short Scans",
            SUM (DECODE (NAME, 'table scans (long tables)', VALUE))
               "Long Scans",
            SUM (DECODE (NAME, 'table scan rows gotten', VALUE))
               "Rows Retrieved"
       FROM v$session ss, v$sesstat se, v$statname sn
      WHERE se.statistic# = sn.statistic#
            AND (   NAME LIKE '%table scans (short tables)%'
                 OR NAME LIKE '%table scans (long tables)%'
                 OR NAME LIKE '%table scan rows gotten%')
            AND se.sid = ss.sid
            AND ss.username IS NOT NULL
   GROUP BY ss.sid,ss.username || '(' || se.sid || ') ';