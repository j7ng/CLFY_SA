CREATE OR REPLACE FUNCTION sa."ADD_FREQ_FUNC" (
   ip_part_number   IN   VARCHAR2,
   ip_frequency     IN   VARCHAR2
)
   RETURN BOOLEAN
IS

cursor c1 is
select pn.OBJID
from table_part_num pn
where pn.part_number = ip_part_number
and pn.domain = 'PHONES';

r1 c1%rowtype;

cursor c2 is
select objid from table_x_frequency where x_frequency = to_number(ip_frequency);



r2 c2%rowtype;


cursor c3 is
select pn.objid
from table_part_num pn, MTM_PART_NUM14_X_FREQUENCY0 mtm, table_x_frequency f
where part_number = ip_part_number
and pn.objid = mtm.PART_NUM2X_FREQUENCY
and f.x_frequency = to_number(ip_frequency)
and f.objid = mtm.x_frequency2part_num;

r3 c3%rowtype;


pobjid number;
fobjid number;

begin

fobjid :=0;
pobjid  :=0;

open c1;
fetch c1 into r1;
if c1%found then
   pobjid := r1.objid;
end if;
close c1;
if pobjid = 0 then
   return false;
end if;

open c2;
fetch c2 into r2;
if c2%found then
   fobjid := r2.objid;
end if;
close c2;

if fobjid = 0 then
   return false;
end if;

open c3;
fetch c3 into r3;
if c3%notfound then

    insert into MTM_PART_NUM14_X_FREQUENCY0 mtm
    (mtm.PART_NUM2X_FREQUENCY,mtm.X_FREQUENCY2PART_NUM)
    values (pobjid,fobjid);

-- commit; CR13581
end if;
close c3;
return true;
end;
/