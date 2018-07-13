CREATE OR REPLACE PROCEDURE sa.sp_valid_contact_email(p_email in out varchar2) as
  hold varchar2(200);
  cnt1 number;
  cnt2 number;
begin
    hold := replace(lower(p_email),' at ','@');
    hold := translate(hold,
        'abcdefghijklmnopqrstuvwxyz1234567890._,/!)(<>;:\"[]*'' ',
        'abcdefghijklmnopqrstuvwxyz1234567890._._' );
    while length(hold)>0 loop
      if ascii(substr(lower(rtrim(hold)),length(rtrim(hold)),1)) not between 97 and 122 then
        hold := substr(hold,1,length(hold)-1);
      else
        exit;
      end if;
    end loop;
    if substr(hold,length(hold)-2,3) = 'aol' then
      hold := hold||'.com';
    elsif substr(hold,length(hold)-3,4) = 'comm' then
      hold := substr(hold,1,length(hold)-1);
    elsif substr(hold,length(hold)-4,5) = 'yahoo' then
      hold := hold||'.com';
    elsif substr(hold,length(hold)-6,7) = 'hotmail' then
      hold := hold||'.com';
    end if;
    if    instr(hold,'@') in (0,1)
       or instr(hold,'@') = length(hold)
       or instr(hold,'@') = length(hold) -1
       or instr(hold,'@') = length(hold) -2
       or instr(hold,'@') = length(hold) -3
       or instr(hold,'@',1,2) between 2 and length(hold)-1
       or instr(hold,'@') is null
       or substr(hold,instr(hold,'@')+1,1) = '.'
       or (substr(hold,length(hold)-2,1) != '.'
          and substr(hold,length(hold)-3,1) != '.')
       or substr(hold,length(hold)-1,1) = '.'
       or instr(hold,'.',instr(hold,'@')+1) = 0
       or instr(hold,'.',instr(hold,'@')+1) is null then
      hold := null;
    end if;
    if substr(hold,length(hold)-3,4) = '.att' then
      hold := hold||'.net';
    elsif substr(hold,length(hold)-3,4) = '.c0m' then
      hold := substr(hold,1,length(hold)-4)||'.com';
    elsif substr(hold,length(hold)-3,4) = '.cim' then
      hold := substr(hold,1,length(hold)-4)||'.com';
    elsif substr(hold,length(hold)-3,4) = '.con' then
      hold := substr(hold,1,length(hold)-4)||'.com';
    elsif substr(hold,length(hold)-3,4) = '.cpm' then
      hold := substr(hold,1,length(hold)-4)||'.com';
    elsif substr(hold,length(hold)-3,4) = '.ebu' then
      hold := substr(hold,1,length(hold)-4)||'.edu';
    elsif substr(hold,length(hold)-3,4) = '.abu' then
      hold := substr(hold,1,length(hold)-4)||'.edu';
    elsif substr(hold,length(hold)-3,4) = '.edo' then
      hold := substr(hold,1,length(hold)-4)||'.edu';
    elsif substr(hold,length(hold)-3,4) = '.met' then
      hold := substr(hold,1,length(hold)-4)||'.net';
    elsif substr(hold,length(hold)-3,4) = '.nat' then
      hold := substr(hold,1,length(hold)-4)||'.net';
    elsif substr(hold,length(hold)-3,4) = '.cet' then
      hold := substr(hold,1,length(hold)-4)||'.net';
    elsif substr(hold,length(hold)-3,4) = '.ner' then
      hold := substr(hold,1,length(hold)-4)||'.net';
    elsif substr(hold,length(hold)-3,4) = '.not' then
      hold := substr(hold,1,length(hold)-4)||'.net';
    elsif substr(hold,length(hold)-3,4) = '.msn' then
      hold := substr(hold,1,length(hold)-4)||'.msn.com';
    elsif substr(hold,length(hold)-3,4) = '.ney' then
      hold := substr(hold,1,length(hold)-4)||'.net';
    elsif substr(hold,length(hold)-3,4) = '.ocm' then
      hold := substr(hold,1,length(hold)-4)||'.com';
    elsif substr(hold,length(hold)-3,4) = '.gob' then
      hold := substr(hold,1,length(hold)-4)||'.gov';
    elsif substr(hold,length(hold)-3,4) = '.xom' then
      hold := substr(hold,1,length(hold)-4)||'.com';
    end if;
    if (    substr(hold,length(hold)-2,1) != '.'
        and substr(hold,length(hold)-3,4) not in ('biz','.mil','.gov','.com','.net','.org','.edu')) then
      hold := null;
    end if;
    p_email := hold;
end;
/