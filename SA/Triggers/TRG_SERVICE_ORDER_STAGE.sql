CREATE OR REPLACE TRIGGER sa."TRG_SERVICE_ORDER_STAGE" BEFORE INSERT OR UPDATE ON sa.X_SERVICE_ORDER_STAGE
 REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
 --------------------------------------------------------------------------------------------
 --$RCSfile: trg_service_order_stage.sql,v $
  --$Revision: 1.2 $
  --$Author: jpena $
  --$Date: 2015/02/13 17:54:59 $
  --$ $Log: trg_service_order_stage.sql,v $
  --$ Revision 1.2  2015/02/13 17:54:59  jpena
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