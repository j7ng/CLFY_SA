CREATE OR REPLACE function sa.set_real_handset (p_esn varchar2) return varchar2
is
serial_no varchar2(30) :=trim(p_esn);
begin
delete from  GW1.TEST_OTA_ESN       where esn=serial_no;
delete from sa.TEST_IGATE_ESN    where esn=serial_no and esn_type='H';
insert into GW1.TEST_OTA_ESN       values(serial_no);
insert into sa.TEST_IGATE_ESN      values(serial_no,'H');
commit;
return serial_no||' Inserted into TEST TABLES as type H';
end;
/