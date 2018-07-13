CREATE OR REPLACE procedure sa.check_frf as
  out_result      VARCHAR2(400) ;
  lmsg         VARCHAR2(4000):='SELECT name
, ceil( space_limit / 1024 / 1024) SIZE_M
, ceil( space_used  / 1024 / 1024) USED_M
, ceil( space_reclaimable  / 1024 / 1024) RECLAIMABLE_M
, decode( nvl( space_used, 0),
 0, 0
 , ceil ( ( ( space_used - space_reclaimable ) / space_limit) * 100) ) PCT_USED
 FROM v$recovery_file_dest
ORDER BY name;';
dbname varchar2(30);
PCT_USED number;
BEGIN

  SELECT name
  INTO dbname
  FROM v$database;

SELECT  decode( nvl( space_used, 0),
 0, 0
 , ceil ( ( ( space_used - space_reclaimable ) / space_limit) * 100) )  into  PCT_USED
 FROM v$recovery_file_dest
ORDER BY name;

if PCT_USED>=70 then
  SEND_MAIL('RECOVERY_FILE_DEST Is ' ||PCT_USED||'% Used. Use RMAN TARGET sys/sys@'||dbname||'. delete archivelog until time ''SYSDATE-3'';', 'jtong@tracfone.com', 'jtong@tracfone.com', lmsg, out_result );
END IF;

END;
/