CREATE OR REPLACE PROCEDURE sa."GET_CARRIER_ID"

(

  PARAM1 IN VARCHAR2

, PARAM2 OUT VARCHAR2

) AS

BEGIN

select max(b.carrier_id) into Param2

from carrierzones a,

     npanxx2carrierzones b,

               carrierpref c

where a.st = b.state

 and b.Carrier_Name ='CINGULAR WIRELESS'

  and a.zone = b.zone

  and a.st = c.st

  and a.county = c.county

  AND B.CARRIER_ID = C.CARRIER_ID

  and a.zip in ('90001')  ; ---31032 92301 26241  53129  46992  38655 38664  CLFYDEV6   18657  46910 56267  99707





END GET_CARRIER_ID;
/