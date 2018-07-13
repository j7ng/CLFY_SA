CREATE OR REPLACE TRIGGER sa.trig_x_promo_hist
BEFORE INSERT OR UPDATE ON sa.table_x_promo_hist
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
--------------------------------------------------------------------------------------------
--$RCSfile: TRIG_X_PROMO_HIST.sql,v $
--$Revision: 1.1 $
--$Author: kacosta $
--$Date: 2012/06/15 21:45:26 $
--$ $Log: TRIG_X_PROMO_HIST.sql,v $
--$ Revision 1.1  2012/06/15 21:45:26  kacosta
--$ CR20864 Add Column to Promo Hist Table
--$
--$
--------------------------------------------------------------------------------------------
DECLARE
  --
BEGIN
  --
  :new.update_stamp := SYSDATE;
  --
END trig_x_promo_hist;
/