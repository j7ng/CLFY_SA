CREATE OR REPLACE function sa.get_test_esn_sim
                 (esn_part_number in varchar2, sim_part_num in varchar2)
                  return varchar2 is

p_esn varchar2(30);
p_sim varchar2(30);



begin


p_esn :=get_test_esn(esn_part_number);
p_sim := get_test_sim(sim_part_num);

  dbms_output.put_line ('ESN is :'||p_esn);
  dbms_output.put_line ('SIM is :'||p_sim);
return p_esn;
end;
/