CREATE OR REPLACE package body sa.COPY_TAB_PKG
as 
 procedure disable_constraint (v_tab in varchar2, v_owner in varchar)
is

l_tab varchar2(30);
l_owner varchar2(30);

cursor c1 (p_tab in varchar2, p_owner in varchar2) is
select 'alter table '||owner||'.'||table_name ||' disable CONSTRAINT '||constraint_name s
from all_constraints where owner = p_owner
and constraint_type = 'R'
and r_constraint_name in
(select distinct constraint_name
from all_constraints where owner = p_owner
and upper(table_name) =p_tab
and constraint_type  in ('P', 'U')
)
union
select  'alter table '||owner||'.'||table_name ||' disable CONSTRAINT '||constraint_name s
from all_constraints where owner = p_owner
and upper(table_name)=p_tab
and constraint_type = 'R'
;

begin


l_tab:=upper(v_tab);
l_owner:=upper(v_owner);

for l1 in c1(l_tab,l_owner)
loop
DBMS_OUTPUT.put_line(l1.s);
execute immediate l1.s;
end loop;
end;

 procedure enable_constraint (v_tab in varchar2, v_owner in varchar)
is
l_tab varchar2(30);
l_owner varchar2(30);

cursor c3 (p_tab varchar2,p_owner in varchar2) is
select 'alter table '||owner||'.'||table_name ||' enable CONSTRAINT '||constraint_name s
from all_constraints where owner = p_owner
and constraint_type = 'R'
and r_constraint_name in
(select distinct constraint_name
from all_constraints where owner = p_owner
and upper(table_name) = p_tab
and constraint_type  in ('P', 'U')
)
union
select 'alter table '||owner||'.'||table_name ||' enable CONSTRAINT '||constraint_name s
from all_constraints where owner = p_owner
and upper(table_name) = p_tab
and constraint_type = 'R';
begin
l_tab:=upper(v_tab);
l_owner:=upper(v_owner);

for l3 in c3(l_tab,l_owner)
loop
DBMS_OUTPUT.put_line(l3.s);
execute immediate l3.s;
end loop;
end;


 procedure copy_tab (p_tab in varchar2 , p_owner in varchar2)
 is
   cnt2 number := 0;

        cnt3 number :=0;

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
   send_check_mail(p_tab , p_owner ) ;
else
      DBMS_OUTPUT.PUT_LINE('NO record in RTRP. No refresh is needed');
 end if;

end;
 procedure copy_tab_long (p_tab in varchar2 , p_owner in varchar2)
  is
    cnt2 number := 0;

        cnt3 number :=0;

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
     send_check_mail(p_tab , p_owner ) ;
else
      DBMS_OUTPUT.PUT_LINE('NO record in RTRP. No refresh is needed');
 end if;

end;

 procedure send_check_mail(p_tab in varchar2 , p_owner in varchar2) IS

    cnt1 number :=0;

         OUT_RESULT   VARCHAR2(200);
BEGIN
     execute immediate 'select count(*) from '      ||p_owner||'.'||p_tab  into cnt1;
        DBMS_OUTPUT.PUT_LINE('RECORD CNT = ' || cnt1);
IF cnt1=0
 then
    SEND_MAIL(p_owner||'.'||p_tab||'  Has No Record After Refresh', 'jtong@tracfone.com', 'jtong@tracfone.com','SELECT * FROM '||p_owner||'.'||p_tab , out_result );
  IF out_result IS NULL THEN
    out_result  := 'SUCCESS';
  END IF;
--  DBMS_OUTPUT.PUT_LINE('RESULT = ' || OUT_RESULT);

end if;
end;
end;
/