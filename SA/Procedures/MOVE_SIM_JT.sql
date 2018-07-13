CREATE OR REPLACE procedure sa.move_sim_jt
as
cursor c is
select objid from table_sim_rtrp@jt_samp b
where not exists(select 1 from table_x_sim_inv a where a.objid=b.objid or a.x_sim_serial_no=b.x_sim_serial_no)
and rownum<2001;


cnt number :=0;
begin
select count(*) into cnt from table_x_sim_inv
where X_SIM_INV_STATUS='253'
AND x_sim_serial_no LIKE '890126%'
and X_CREATED_BY2USER<>0;

if cnt<50000 then
for l in c
loop
insert into table_x_sim_inv
select * from table_sim_rtrp@jt_samp where objid=l.objid ;
commit;
end loop;
end if;
end;
/