CREATE OR REPLACE procedure sa.refresh_tab(v_tab in varchar2, v_owner in varchar) 
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
and constraint_type = 'P'
)
union
select  'alter table '||owner||'.'||table_name ||' disable CONSTRAINT '||constraint_name s
from all_constraints where owner = p_owner 
and upper(table_name)=p_tab
and constraint_type = 'R'
;

cursor c (p_tab varchar2 , p_owner in varchar2) is
select TABLE_NAME, 'DROP TABLE '||owner||'.BK_'||substr(TABLE_NAME,1,27) drbk, 'CREATE TABLE  '||owner||'.BK_'||substr(TABLE_NAME,1,27)||' AS SELECT * FROM '||owner||'.'||TABLE_NAME crbk, 
'TRUNCATE TABLE '||owner||'.'||TABLE_NAME tr,
 'INSERT INTO '||owner||'.'||TABLE_NAME||' SELECT * FROM '||owner||'.'||TABLE_NAME||'@READ_RTRP' ins
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
and constraint_type = 'P'
)
union
select 'alter table '||owner||'.'||table_name ||' enable CONSTRAINT '||constraint_name s
from all_constraints where owner = p_owner
and upper(table_name) = p_tab
and constraint_type = 'R'
;

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
DBMS_OUTPUT.put_line( l.tr);
DBMS_OUTPUT.put_line( l.ins);
execute immediate l.crbk;
execute immediate l.tr;
execute immediate l.ins;
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