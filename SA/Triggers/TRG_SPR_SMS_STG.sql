CREATE OR REPLACE TRIGGER sa.trg_spr_sms_stg BEFORE INSERT OR UPDATE ON sa.X_spr_sms_stg REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
 --------------------------------------------------------------------------------------------
 --$RCSfile: trg_spr_sms_stg.sql,v $
  --$Revision: 1.2 $
  --$Author: aganesan $
  --$Date: 2015/05/13 19:39:35 $
  --$ $Log: trg_spr_sms_stg.sql,v $
  --$ Revision 1.2  2015/05/13 19:39:35  aganesan
  --$ CR34909 Changes.
  --$
  --$ Revision 1.9  2015/03/10 22:33:53  jpena
  --$ CR34081 - Super Carrier
  --$
  --------------------------------------------------------------------------------------------

BEGIN
  :NEW.UPDATE_TIMESTAMP := SYSDATE;
END;
/