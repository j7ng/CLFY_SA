CREATE OR REPLACE TRIGGER sa."TRG_ACCOUNT_GROUP" BEFORE INSERT OR UPDATE ON sa.X_ACCOUNT_GROUP REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
 --------------------------------------------------------------------------------------------
 --$RCSfile: trg_account_group.sql,v $
  --$Revision: 1.2 $
  --$Author: jpena $
  --$Date: 2015/02/13 17:55:08 $
  --$ $Log: trg_account_group.sql,v $
  --$ Revision 1.2  2015/02/13 17:55:08  jpena
  --$    UPDATE TIMESTAMP TO SYSDATE
  --$
  --$ Revision 1.9  2015/02/13 22:33:53  jpena
  --$ CR32463 - Brand X Changes
  --$
  --------------------------------------------------------------------------------------------

BEGIN
  :NEW.UPDATE_TIMESTAMP := SYSDATE;
END;
/