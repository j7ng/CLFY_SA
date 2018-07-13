CREATE OR REPLACE function sa.get_test_esn_IMSI
                 (esn_part_number in varchar2, sim_part_num in varchar2)
                  return varchar2 is

p_esn varchar2(30);
p_sim varchar2(30);
o_sim varchar2(30);

begin

p_esn :=get_test_esn(esn_part_number);
o_sim := get_test_sim(sim_part_num);
p_sim := substr(p_esn,-15);

  dbms_output.put_line ('ESN is :'||p_esn);
  dbms_output.put_line ('SIM is :'||p_sim);

  update table_part_inst set  x_iccid = p_sim where part_serial_no  = p_esn;
COMMIT;
 UPDATE TABLE_X_SIM_INV
 SET X_SIM_IMSI =P_SIM,
   X_SIM_SERIAL_NO=P_SIM
where X_SIM_SERIAL_NO=o_sim;
commit;

return p_esn;
end;
/