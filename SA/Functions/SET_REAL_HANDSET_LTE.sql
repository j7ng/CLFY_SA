CREATE OR REPLACE function sa.set_real_handset_lte (p_esn varchar2) return varchar2
is
serial_no varchar2(30) :=trim(p_esn);
begin

delete from  GW1.TEST_OTA_ESN       where esn=serial_no;
delete from sa.TEST_IGATE_ESN    where esn=serial_no and esn_type='H';
insert into sa.TEST_IGATE_ESN      values(serial_no,'H');
delete from  GW1.test_ota_esn_2       where esn=serial_no;
insert into gw1.test_ota_esn_2      values(serial_no);
commit;
return serial_no||' Inserted into TEST TABLES as type H for LTE HANDSET';
end;
/