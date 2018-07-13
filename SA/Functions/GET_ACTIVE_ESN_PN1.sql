CREATE OR REPLACE function sa.get_active_esn_pn1
                 (esn_part_number in varchar2)
                  return varchar2 is

p_esn varchar2(30);
p_sim varchar2(30);
p_min varchar2(30);
p_zip varchar2(30);
p_carr_id number;
p_sourcesystem varchar2(30);


begin

p_zip := '33322';
p_sourcesystem := 'WEBCSR';
p_carr_id := 106129;



p_esn :=get_test_esn(esn_part_number);
p_sim := get_test_sim('TF64SIMC4');
p_min := create_active_esn (p_carr_id , 'SA',p_esn,p_zip  ,p_sim ,p_sourcesystem );

  dbms_output.put_line ('ESN is :'||p_esn);
  dbms_output.put_line ('MIN is :'||p_min);
return p_esn;
end;
/