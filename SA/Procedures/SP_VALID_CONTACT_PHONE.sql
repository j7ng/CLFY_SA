CREATE OR REPLACE PROCEDURE sa.sp_valid_contact_phone(p_phone in out varchar2) as
  cursor c2(c_npanxx in varchar2) is
    select 1
      from x_valid_npa_nxx
     where npanxx = c_npanxx;
  c2_rec c2%rowtype;
  hold varchar2(30);
  hold2 varchar2(30);
begin
  hold := null;
  for i in 1..length(p_phone) loop
    if ascii(substr(p_phone,i,1)) between 48 and 57 then
      hold :=hold||substr(p_phone,i,1);
    end if;
  end loop;
  if substr(hold,1,1) = '1' then
    hold := substr(hold,2);
  end if;
  if length(hold) != 10 then
    hold := null;
  /*else
    open c2(substr(hold,1,6));
      fetch c2 into c2_rec;
      if c2%notfound then
        hold := null;
      end if;
    close c2;*/
  end if;
  if hold is null then
    p_phone := null;
  else
    p_phone := hold; --04/25/02
  end if;
end;
/