CREATE OR REPLACE PROCEDURE sa.sp_check_luts
                            (p_npa        in      varchar2,
                             p_nxx        in      varchar2,
                             p_result     out     number) -- 1 = true, 0 = false
is

cursor c1 is
select npa
from sa.npanxx2carrierzones
where p_npa = npa
  and p_nxx = nxx;

r1 c1%rowtype;
begin

 open c1;
 fetch c1 into r1;

 if c1%found then
  p_result := 1;
 else
  p_result := 0;
 end if;

 close c1;

end;
/