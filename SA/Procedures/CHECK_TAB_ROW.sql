CREATE OR REPLACE procedure sa.check_tab_row (owner in varchar2, tab  in varchar2) is

tab_owner varchar2(30) := upper(trim(owner));
tab_name varchar2(30):= upper(trim(tab));
row_cnt number:=0;

cursor c is
select 'SELECT COUNT (*) from '||owner||'.'||table_name stmt  from dba_tables where owner=tab_owner and table_name=tab_name;

l c%rowtype;
begin
open  c;
 fetch  c into l;
if c%found
then
 EXECUTE IMMEDIATE L.stmt INTO row_cnt;
 insert into tab_row_cnt values(tab_owner,tab_name,row_cnt);
 commit;
 if row_cnt>5000 then
 dbms_output.put_line('TABLE '||tab_owner||'.'||tab_name||' ROW COUNT IS '||row_cnt);
 end if;
else
dbms_output.put_line('TABLE '||tab_owner||'.'||tab_name||' DOESNT EXIST');
end if;
close c;
end;
/