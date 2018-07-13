CREATE OR REPLACE TRIGGER sa.trg_tc_mask
before insert or update
ON sa.TABLE_CONTACT for each row
BEGIN
 :new.X_SS_NUMBER :=null;
END;
/