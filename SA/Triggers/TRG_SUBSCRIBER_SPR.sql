CREATE OR REPLACE TRIGGER sa.trg_subscriber_spr BEFORE INSERT OR UPDATE ON sa.X_SUBSCRIBER_SPR REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
--------------------------------------------------------------------------------------------
--$RCSfile: trg_subscriber_spr.sql,v $
  --$Revision: 1.2 $
  --$Author: aganesan $
  --$Date: 2015/05/13 19:39:35 $
  --$ $Log: trg_subscriber_spr.sql,v $
  --$ Revision 1.2  2015/05/13 19:39:35  aganesan
  --$ CR34909 Changes.
  --$
  --$ Revision 1.9  2015/03/10 22:33:53  jpena
  --$ CR29586 - Super Carrier
  --$
  --------------------------------------------------------------------------------------------
BEGIN
  :NEW.UPDATE_TIMESTAMP := SYSDATE;
END;
/