CREATE OR REPLACE PROCEDURE sa."REQUEUE_ACTION_ITEM"

(

  PARAM1 IN VARCHAR2

) AS

BEGIN

UPDATE IG_TRANSACTION

SET status = 'W',

status_message = ''

WHERE transaction_id = (SELECT max(transaction_id)  FROM ig_transaction WHERE (creation_date >= TRUNC(SYSDATE) AND ESN = Param1));

COMMIT;

END REQUEUE_ACTION_ITEM;
/