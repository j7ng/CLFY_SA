CREATE OR REPLACE TRIGGER sa.trg_pcrf_trans_low_prty BEFORE INSERT OR UPDATE ON sa.x_pcrf_trans_low_prty REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
 --------------------------------------------------------------------------------------------
 --$RCSfile: CR38631_DDL.sql,v $
  --$Revision: 1.1 $
  --$Author: jpena $
  --$Date: 2015/10/16 20:55:40 $
  --$ $Log: CR38631_DDL.sql,v $
  --$ Revision 1.1  2015/10/16 20:55:40  jpena
  --$ Add new tables to move propagate flag 0 pcrf
  --$
  --$ Revision 1.2  2015/05/13 19:39:35  aganesan
  --$ CR34909 Changes.
  --$
  --$ Revision 1.9  2015/03/10 22:33:53  jpena
  --$ CR34081 - Super Carrier
  --$
  --------------------------------------------------------------------------------------------

BEGIN
  :NEW.update_timestamp := SYSDATE;
END;
/