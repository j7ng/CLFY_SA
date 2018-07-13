CREATE OR REPLACE PROCEDURE sa.GET_GENCODE_ESNS_PRC(IP_STATUS     IN    VARCHAR2,
                               IP_DAYS_BACK  IN    NUMBER default 0,
                               IP_ROWLIMIT   IN    NUMBER default 0,
                               OP_OUTPUT     OUT   SYS_REFCURSOR,
                               OP_RESULT     OUT   VARCHAR2)
IS
  sqlstmt varchar2(1000):= '';
BEGIN

   IF IP_STATUS IS NULL THEN
      OP_RESULT  := 'INPUT IP_STATUS CANNOT BE NULL';
   END IF;

   sqlstmt := sqlstmt ||' SELECT OBJID, X_ESN GEN_ESN, X_OTA_TRANS_ID,';
   sqlstmt := sqlstmt ||'(CASE WHEN x_insert_date >= TRUNC(SYSDATE)+1 THEN ''QUEUED''';
   sqlstmt := sqlstmt ||' ELSE ''POSTED'' END ) status, X_INSERT_DATE GEN_DATE,';
   sqlstmt := sqlstmt ||' X_SWEEP_AND_ADD_FLAG, X_STATUS';
   sqlstmt := sqlstmt ||' FROM (SELECT * FROM X_PROGRAM_GENCODE GEN ';
   sqlstmt := sqlstmt ||' WHERE 1 = 1 ';
   sqlstmt := sqlstmt ||' AND GEN.X_STATUS = '''||IP_STATUS ||'''';
   if ( IP_STATUS = 'STRSCHEDULED') then
       sqlstmt:= sqlstmt  ||' AND GEN.X_INSERT_DATE > SYSDATE - nvl('''||IP_DAYS_BACK||''',0)' ;
       sqlstmt := sqlstmt ||' AND GEN.X_INSERT_DATE  <= SYSDATE ';
   elsif ( IP_STATUS = 'INSERTED') then
       sqlstmt:= sqlstmt||' AND GEN.X_INSERT_DATE > SYSDATE -  nvl('''||IP_DAYS_BACK||''',0)'  ;
   else
        sqlstmt := sqlstmt||' AND 1=2 ';
   end if;
   sqlstmt := sqlstmt ||' AND NOT EXISTS (SELECT 1';
   sqlstmt := sqlstmt ||' FROM table_x_ota_transaction ota';
   sqlstmt := sqlstmt ||' WHERE x_status = ''OTA PENDING''';
   sqlstmt := sqlstmt ||' AND OTA.X_ESN = GEN.X_ESN)';
   sqlstmt := sqlstmt ||' ORDER BY GEN.X_INSERT_DATE ';
   sqlstmt := sqlstmt ||' )WHERE ROWNUM < nvl('''||IP_ROWLIMIT||''',0)';

   open op_output for sqlstmt;

end ;
/