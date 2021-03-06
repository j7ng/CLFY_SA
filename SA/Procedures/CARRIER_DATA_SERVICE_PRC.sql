CREATE OR REPLACE PROCEDURE sa.CARRIER_DATA_SERVICE_PRC
( IP_CARRIER_ID IN VARCHAR2
, OP_RESULT OUT NUMBER
) AS

cursor c1 is
SELECT * FROM TABLE_X_CARRIER
WHERE X_CARRIER_ID = IP_CARRIER_ID
AND X_DATA_SERVICE = 1;

R1 C1%ROWTYPE;

BEGIN

  OP_RESULT := 0;
  OPEN C1;
  FETCH C1 INTO R1;
  IF C1%FOUND THEN
     OP_RESULT:=1;
  ELSE
     OP_RESULT:=0;
  END IF;
  close c1;

END CARRIER_DATA_SERVICE_PRC;
/