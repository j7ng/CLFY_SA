CREATE OR REPLACE function sa.get_test_esn_byop
                 (esn_part_number in varchar2, sim_part_num in varchar2)
                  return varchar2 is
p_esn varchar2(30);
p_sim varchar2(30);
begin
p_esn :=get_test_esn(esn_part_number);
p_sim := get_test_sim(sim_part_num);
  dbms_output.put_line ('ESN is :'||substr(p_sim,-15));
  dbms_output.put_line ('SIM is :'||p_sim);
  update table_part_inst set part_serial_no = substr(p_sim,-15), x_iccid = p_sim
where part_serial_no  = p_esn;
commit;
insert into GW1.TEST_OTA_ESN       values(substr(p_sim,-15));
commit;
insert into sa.TEST_IGATE_ESN      values(substr(p_sim,-15),'C');
commit;
return substr(p_sim,-15);
end;
/