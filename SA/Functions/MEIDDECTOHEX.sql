CREATE OR REPLACE FUNCTION sa.MEIDDECTOHEX
(p_decnum VARCHAR2)
RETURN VARCHAR2 AS
BEGIN
-- 1.0   Alexander Barrera 06-29-07
-- Function for taking 18 digits numbers and obtain their
-- hex value for MEID.
-- It takes the number in two parts, convert to hex each one
-- separately.  then, formats them and concat them to get the
-- final MEID number in hex format

  declare
    num       number:=p_decnum;
    result    varchar2(50):='';
    t_res     number:=16;
    chardigit varchar2(1);
    counter   number;
    f_result  varchar2(50);
    partial_result varchar2(50);
  begin
  for i in 1..2 loop
    if i=1 then
      num := substr(p_decnum,1,10);
    else
      f_result := partial_result;
      partial_result := '';
      result := '';
      num := substr(p_decnum,11,18);
      t_res := 16;
    end if;
    while t_res>=16 loop
      t_res := trunc(num/16);
      if num-t_res*16>9 then
        chardigit := chr(num-t_res*16+55);
      else
        chardigit := num-t_res*16;
      end if;
      result := result||chardigit;
      num :=t_res;
    end loop;
    if t_res>9 then
      chardigit := chr(t_res+55);
    else
      chardigit := t_res;
    end if;
    result := result || chardigit;
    for counter in reverse 1..length(result) loop
      partial_result := partial_result || substr(result,counter,1);
    end loop;
 end loop;
 f_result := f_result || lpad(partial_result,6,'0');
 RETURN f_result;
 end;
END;
/