CREATE OR REPLACE procedure sa.remove_myaccount_st(p_esn varchar2)
is
cursor c is
select objid from TABLE_X_CONTACT_PART_INST where X_CONTACT_PART_INST2PART_INST =
(select objid from table_part_inst where part_serial_no=p_esn);
begin
for l in c
loop
update TABLE_X_CONTACT_PART_INST set X_CONTACT_PART_INST2CONTACT=0 where objid = l.objid;
end loop;
commit;
end;
/