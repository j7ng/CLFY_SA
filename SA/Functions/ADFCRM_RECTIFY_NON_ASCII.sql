CREATE OR REPLACE FUNCTION sa.ADFCRM_RECTIFY_NON_ASCII(INPUT_STR IN VARCHAR2)
RETURN VARCHAR2
IS
str VARCHAR2(2000);
act number :=0;
cnt number :=0;
askey number :=0;
OUTPUT_STR VARCHAR2(2000);
begin
str:='^'||TO_CHAR(INPUT_STR)||'^';
cnt:=length(str);
for i in 1 .. cnt loop
askey :=0;
select ascii(substr(str,i,1)) into askey
from dual;
if (askey < 32 or askey >=127) and askey<>10 and askey<>13 and askey<>241 and askey<>209 and askey<>225 and askey<>233 and askey<>237 and askey<>243 and askey<>250 then
str :='^'||REPLACE(str, CHR(askey),'');
end if;
end loop;
OUTPUT_STR := trim(ltrim(rtrim(trim(str),'^'),'^'));
RETURN (OUTPUT_STR);
end;
/