CREATE OR REPLACE TRIGGER sa.trg_usage_host BEFORE INSERT OR UPDATE ON sa.X_USAGE_HOST REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
 --------------------------------------------------------------------------------------------
 --$RCSfile: trg_usage_host.sql,v $
  --$Revision: 1.2 $
  --$Author: aganesan $
  --$Date: 2015/05/13 19:39:36 $
  --$ $Log: trg_usage_host.sql,v $
  --$ Revision 1.2  2015/05/13 19:39:36  aganesan
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