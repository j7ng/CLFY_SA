CREATE OR REPLACE TRIGGER sa.SMP_VDU_PRIV_PRINCIPALS_TRIG before delete
ON sa.SMP_VDU_PRINCIPALS_TABLE for each row
BEGIN
	DELETE from SMP_VDU_PRIVILEGE_TABLE where PRINCIPAL_OID = :old.PRINCIPAL_ID;
END;
/