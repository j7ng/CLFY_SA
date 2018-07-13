CREATE OR REPLACE function sa.get_active_esn
                 (esn_part_number in varchar2, sim_part_number in varchar2, zip in varchar2 , carrier_id in number , sourcesystem in varchar2  )
                  return varchar2 is

p_esn varchar2(30);
p_sim varchar2(30);
p_min varchar2(30);
p_zip varchar2(30);
p_carr_id number;
p_sourcesystem varchar2(30);


cursor c (cid number) is
select X_CARRIER_ID from table_x_carrier where X_CARRIER_ID=cid;

begin

p_zip := nvl(zip, '33322');
p_sourcesystem := nvl(sourcesystem,'WEBCSR');

open c(carrier_id);
fetch c into p_carr_id;
close c;

if c%notfound
then p_carr_id := 106129;
end if;


p_esn :=get_test_esn(esn_part_number);
p_sim := get_test_sim(sim_part_number);
p_min := create_active_esn (p_carr_id , 'SA',p_esn,p_zip  ,p_sim ,p_sourcesystem );

return p_min;
end;
/