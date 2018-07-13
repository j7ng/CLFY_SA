CREATE OR REPLACE TRIGGER sa.trig_x_call_trans
BEFORE INSERT OR UPDATE ON sa.table_x_call_trans
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
--------------------------------------------------------------------------------------------
--$RCSfile: TRIG_X_CALL_TRANS.sql,v $
--$Revision: 1.1 $
--$Author: kacosta $
--$Date: 2012/07/23 21:01:32 $
--$ $Log: TRIG_X_CALL_TRANS.sql,v $
--$ Revision 1.1  2012/07/23 21:01:32  kacosta
--$ CR21262 Update Stamp Field for TABLE_X_CALL_TRANS
--$
--$
--------------------------------------------------------------------------------------------
DECLARE
  --
BEGIN
  --
  :new.update_stamp := SYSDATE;
  --
END trig_x_call_trans;
/