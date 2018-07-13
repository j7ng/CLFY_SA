CREATE OR REPLACE PROCEDURE sa.Refresh_Carrier 
as
    vSql       varchar2(500 char);
    lCount     number;
    lDate      varchar2(30 char);
    lTableName varchar2(40 char);
     OUT_RESULT   VARCHAR2(200);
     dbname varchar2(30);
begin
    select to_char(sysdate,'mmdd_HH24MI')
    into   lDate
    from   dual;
    select name into dbname from v$database;
    /* Code to create backup tables goes here*/
    begin
        lTableName := 'TABLE_X_CARFEA'||'_'||lDate;
        vSql := 'create table SA.'||lTableName||' as select * from SA.TABLE_X_CARRIER_FEATURES';
        execute immediate vSql;
                vSql := 'Truncate table sa.TABLE_X_CARRIER_FEATURES';
        execute immediate vSql;
   vSql := 'INSERT INTO TABLE_X_CARRIER_FEATURES   SELECT * FROM SA.TABLE_X_CARRIER_FEATURES@read_rtrp';
  execute immediate vSql;
   commit;
                execute immediate 'select count(*) from SA.TABLE_X_CARRIER_FEATURES'  into lCount;
   if lCount =0          
then
    SEND_MAIL( 'TABLE_X_CARRIER_FEATURES Has No Record After Refresh in '||dbname, 'jtong@tracfone.com', 'DBAEnvironment@tracfone.com',  'INSERT INTO TABLE_X_CARRIER_FEATURES   SELECT * FROM SA.TABLE_X_CARRIER_FEATURES@read_rtrp', out_result );
  IF out_result IS NULL THEN
    out_result  := 'SUCCESS';
  END IF;
  DBMS_OUTPUT.PUT_LINE('RESULT = ' || OUT_RESULT);
  COMMIT;
end if;
     exception
         when others then
           dbms_output.put_line('Refresh TABLE_X_CARRIER_FEATURES Table Error : '||sqlerrm);
    end;
    /* Code to drop backup tables of three days older DEPLOYMENT_TRACKING_*/
     begin
        for xx in (select owner,table_name
                   from   all_tables
                   where  table_name like 'TABLE_X_CARFEA_%'
                   and    to_date(substr(table_name,-9),'mmdd_HH24MI') <  trunc(sysdate) -2 
                   and    owner = 'SA')
        loop
          dbms_output.put_line('Dropping Backup table '||xx.owner||'.'||xx.table_name);
          execute immediate 'drop table '||
                             xx.owner || '.' ||
                             xx.table_name ||
                             ' purge';
        end loop;
    exception
         when others then
           dbms_output.put_line('Dropping Backup TABLE_X_CARRIER_FEATURES Error : '||sqlerrm);
    end;
exception
    when others then
    dbms_output.put_line(sqlcode||':'||sqlerrm);
end Refresh_Carrier;
/