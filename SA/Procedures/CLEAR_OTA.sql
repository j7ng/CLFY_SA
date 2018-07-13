CREATE OR REPLACE PROCEDURE sa."CLEAR_OTA"
(
PARAM1 IN VARCHAR2
) AS


BEGIN

UPDATE sa.table_x_ota_transaction SET x_status = 'Completed' where X_ESN = Param1;
update table_x_call_trans set x_RESULT = 'Completed' where X_service_id = Param1;
Commit;

END CLEAR_OTA;
/