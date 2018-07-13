CREATE OR REPLACE PROCEDURE sa."REFRESH_TAB_RTRP" (v_tab in varchar2, v_owner in varchar)
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

cursor c (p_tab varchar2 , p_owner in varchar2) is
select owner,TABLE_NAME, 'DROP TABLE '||owner||'.BK_'||substr(TABLE_NAME,1,27) drbk, 'CREATE TABLE  '||owner||'.BK_'||substr(TABLE_NAME,1,27)||' AS SELECT * FROM '||owner||'.'||TABLE_NAME crbk

--'TRUNCATE TABLE '||owner||'.'||TABLE_NAME tr,
-- 'INSERT INTO '||owner||'.'||TABLE_NAME||' SELECT * FROM '||owner||'.'||TABLE_NAME||'@READ_RTRP' ins
from dba_tables  where owner = p_owner
and upper(table_name) =p_tab;

cursor d (p_tab varchar2,p_owner in varchar2) is
select table_name from dba_tables where owner=p_owner and table_name ='BK_'||substr(p_tab,1,27) ;

bk_tab varchar2(30);

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
procedure MO_tab (p_tab varchar2 , p_owner in varchar2) is
    cnt2 number := 0;
    cnt1 number :=0;
        cnt3 number :=0;
         OUT_RESULT   VARCHAR2(200);
    exec_stmt varchar2(10000):= null;
  cursor t is
        select  a.owner,a.table_name, a.column_name
        from dba_tab_columns a, rtrp_tab_columns@jt_samp b
       where a.table_name = p_tab
       and a.owner=p_owner
       and a.table_name =b.table_name
         and a.owner = b.owner
         and a.column_name=b.column_name
        order by a.column_id asc;

begin
      execute immediate 'select count(*) from '||p_owner||'.'||p_tab||'@read_rtrp'  into cnt3;
if cnt3>0 then
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

begin

l_tab:=upper(v_tab);
l_owner:=upper(v_owner);

for l1 in c1(l_tab,l_owner)
loop
execute immediate l1.s;
DBMS_OUTPUT.put_line(l1.s);
end loop;

for l in c(l_tab,l_owner)
loop
open d(l.table_name, l_owner);
fetch d into bk_tab;
if d%found then
DBMS_OUTPUT.put_line(l.drbk);
execute immediate l.drbk;
end if;
DBMS_OUTPUT.put_line( l.crbk);
--DBMS_OUTPUT.put_line( l.cptab);
execute immediate l.crbk;
mo_tab(l.TABLE_NAME,l.owner);

commit;
close d;
end loop;

for l3 in c3(l_tab,l_owner)
loop
execute immediate l3.s;
DBMS_OUTPUT.put_line(l3.s);
end loop;
end;
/