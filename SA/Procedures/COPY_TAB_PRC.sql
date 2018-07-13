CREATE OR REPLACE procedure sa.copy_tab_prc (p_tab in varchar2 , p_owner in varchar2) is
    cnt2 number := 0;
    cnt1 number :=0;
        cnt3 number :=0;
         OUT_RESULT   VARCHAR2(200);
    exec_stmt varchar2(10000):= null;
    bk_tab varchar2(30) :='BK_'||SUBSTR(p_tab,1,27) ;

  cursor t is
        select  a.owner,a.table_name, a.column_name
        from dba_tab_columns a, rtrp_tab_columns@jt_samp b
       where a.table_name = p_tab
       and a.owner=p_owner
       and a.table_name =b.table_name 
         and a.owner = b.owner 
         and a.column_name=b.column_name
        order by a.column_id asc;
 
cursor cc is 
 SELECT COUNT(*) ct from dba_tables where table_name=bk_tab   and owner=  p_owner;
 
     bk_cnt cc%rowtype;
begin
      execute immediate 'select count(*) from '||p_owner||'.'||p_tab||'@read_rtrp'  into cnt3;
if cnt3>0 then
 open cc;
 fetch cc into bk_cnt;
 if bk_cnt.ct>0 
 then 
 execute immediate 'drop table '||p_owner||'.'||bk_tab||' purge';
 end if;
 close cc;

 execute immediate 'CREATE TABLE '||p_owner||'.'||bk_tab||' AS SELECT * FROM '||p_owner||'.'||p_tab;
    EXECUTE IMMEDIATE 'TRUNCATE TABLE '||p_owner||'.'||p_tab;
 exec_stmt := 'INSERT INTO '||p_owner||'.'||p_tab||'(';
for j in t
loop
 if cnt2 >0 then
          exec_stmt := exec_stmt ||',';
        else
          cnt2 := 1;
        end if; 
        exec_stmt := exec_stmt||j.column_name;
 end loop;
      exec_stmt := exec_stmt || ') SELECT ';
cnt2 :=0;      
 for j in t
loop
 if cnt2 >0 then
          exec_stmt := exec_stmt ||',';
        else
          cnt2 := 1;
        end if; 
        exec_stmt := exec_stmt||j.column_name;
 end loop;     
   exec_stmt := exec_stmt || ' FROM  '||p_owner||'.'||p_tab||'@read_rtrp';
--dbms_output.put_line(exec_stmt);
        EXECUTE IMMEDIATE exec_stmt;
          COMMIT;
      execute immediate 'select count(*) from '      ||p_owner||'.'||p_tab  into cnt1;
        DBMS_OUTPUT.PUT_LINE('RECORD CNT = ' || cnt1);
IF cnt1=0      
 then
    SEND_MAIL(p_owner||'.'||p_tab||'  Has No Record After Refresh', 'jtong@tracfone.com', 'jtong@tracfone.com',  exec_stmt, out_result );
  IF out_result IS NULL THEN
    out_result  := 'SUCCESS';
  END IF;
  DBMS_OUTPUT.PUT_LINE('RESULT = ' || OUT_RESULT);

end if;     
else
      DBMS_OUTPUT.PUT_LINE('NO record in RTRP. No refresh is needed');
 end if;

end;
/