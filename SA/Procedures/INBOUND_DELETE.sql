CREATE OR REPLACE PROCEDURE sa.INBOUND_DELETE (P_PART_SERIAL_NO IN VARCHAR2) AS

BEGIN

DELETE FROM TABLE_PART_INST
 WHERE  PART_SERIAL_NO = P_PART_SERIAL_NO
OR     PART_SERIAL_NO = TO_CHAR(HEX2DEC(P_PART_SERIAL_NO));
COMMIT;

DELETE FROM TABLE_SITE_PART
WHERE  X_SERVICE_ID = P_PART_SERIAL_NO
OR     X_SERVICE_ID = TO_CHAR(HEX2DEC(P_PART_SERIAL_NO));
COMMIT;

DELETE FROM TABLE_X_CALL_TRANS
WHERE  X_SERVICE_ID = P_PART_SERIAL_NO
OR     X_SERVICE_ID = TO_CHAR(HEX2DEC(P_PART_SERIAL_NO));
COMMIT;

END;
/