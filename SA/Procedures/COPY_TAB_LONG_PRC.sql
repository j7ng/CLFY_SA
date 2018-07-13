CREATE OR REPLACE procedure sa.copy_tab_long_prc (p_tab in varchar2 , p_owner in varchar2) is
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

  cursor t2 is
        select  a.owner,a.table_name, column_name||' '||decode(a.data_type,'NUMBER', a.data_type||'('||a.DATA_LENGTH||')',
                                                                  'VARCHAR2', a.data_type||'('||a.DATA_LENGTH||')',
                                                                   'VARCHAR', a.data_type||'('||a.DATA_LENGTH||')',
                                                                          'CHAR', a.data_type||'('||a.DATA_LENGTH||')',
                                                                  a.data_type)   column_name2 ,column_name
        from dba_tab_columns a
       where a.table_name = p_tab
       and a.owner=p_owner
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
 -- create bk table 
exec_stmt := 'create  table '||p_owner||'.'||bk_tab||'(';
for j2 in t2
loop
 if cnt2 >0 then
          exec_stmt := exec_stmt ||',';
        else
          cnt2 := 1;
        end if; 
        exec_stmt := exec_stmt||j2.column_name2;
 end loop;
      exec_stmt := exec_stmt || ')  ';
      
  -- dbms_output.put_line(exec_stmt);
   
   EXECUTE IMMEDIATE exec_stmt;
     exec_stmt :=null;

      exec_stmt := exec_stmt ||'declare 
                                cursor c1 is
                                  select * from '||p_owner||'.'||p_tab||';
                              begin
                                for c1_rec in c1 loop
                                  insert into '||p_owner||'.'||bk_tab||' values(';
      cnt2 := 0;
      for j2 in t2 loop
        if cnt2 >0 then
          exec_stmt := exec_stmt ||',';
        else
          cnt2 := 1;
        end if; 
        exec_stmt := exec_stmt||' c1_rec.'||j2.column_name;
      end loop;
      exec_stmt := exec_stmt || ');
                                  end loop;
                               end;';
-- dbms_output.put_line(exec_stmt);

      EXECUTE IMMEDIATE exec_stmt;
    commit;
  exec_stmt :=null;                           
                                         
   EXECUTE IMMEDIATE 'TRUNCATE TABLE '||p_owner||'.'||p_tab;
    
      exec_stmt := exec_stmt ||'declare 
                                cursor c1 is
                                  select * from '||p_owner||'.'||p_tab||'@read_rtrp;
                              begin
                                for c1_rec in c1 loop
                                  insert into '||p_owner||'.'||p_tab||' values(';

cnt2 :=0;      
 for j in t
loop
 if cnt2 >0 then
          exec_stmt := exec_stmt ||',';
        else
          cnt2 := 1;
        end if; 
    exec_stmt := exec_stmt||' c1_rec.'||j.column_name;
        
 end loop;     
     exec_stmt := exec_stmt || ');
                                  end loop;
                               end;';
   

--dbms_output.put_line(exec_stmt);
 EXECUTE IMMEDIATE exec_stmt;
          COMMIT;
else
      DBMS_OUTPUT.PUT_LINE('NO record in RTRP. No refresh is needed');
 end if;

end;
/