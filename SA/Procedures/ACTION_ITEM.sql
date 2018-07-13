CREATE OR REPLACE PROCEDURE sa."ACTION_ITEM"

(

  PARAM1 IN VARCHAR2

, PARAM2 OUT varchar2

) AS

BEGIN

SELECT Status into PARAM2

FROM IG_TRANSACTION

Where Action_ITEM_ID = (Select Max(ACTION_ITEM_ID)from IG_TRANSACTION where Esn = Param1);

END ACTION_ITEM;
/