CREATE OR REPLACE procedure sa.refresh_TF_OF_ITEM_V_CARDS_INV  as 
cnt number ;
dblink  varchar2(30);

cursor c is 
   SELECT name from v$database;
   v_name c%rowtype;
   
begin

 open c;
  fetch c into  v_name;
  if v_name.name <>'CLFYSAMP' then 
  dblink :='jt_samp';
  else
  dblink :='read_rtrp';
  end if;
  close c;
cnt  := 0;
execute immediate 'select count(*) from sa.TF_OF_ITEM_V_CARDS_INV @'||dblink into cnt;
if cnt >0 then
execute immediate 'drop table sa.TF_OF_ITEM_V_CARDS_INV  purge';
execute immediate 'create table sa.TF_OF_ITEM_V_CARDS_INV  as select * from sa.TF_OF_ITEM_V_CARDS_INV @'||dblink ;
select count(*) into cnt from sa.TF_OF_ITEM_V_PHONE_INV;
dbms_output.put_line('TF_OF_ITEM_V_CARDS_INV  is REFRESHED with RECORDS - '||cnt);
end if;
end;
/