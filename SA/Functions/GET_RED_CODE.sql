CREATE OR REPLACE FUNCTION sa."GET_RED_CODE"
                 (serial_no in varchar2)
                  return varchar2 is

cursor c1 (serial varchar2) is
select part_serial_no,x_red_code
from table_part_inst
where part_serial_no = serial
and x_domain = 'REDEMPTION CARDS';

r1 c1%rowtype;

begin

   if nvl(serial_no,'0') = '0' then
      return null;
   end if;

   open c1 (serial_no);
   fetch c1 into r1;
   if c1%found then
      close c1;
      return r1.x_red_code;
   else
      close c1;
      return serial_no;
   end if;

end;
/