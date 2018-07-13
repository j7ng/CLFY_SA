CREATE OR REPLACE TRIGGER sa."TRIG_X_SL_SUBS"
--------------------------------------------------------------------------------------------
--$RCSfile: TRIG_X_SL_SUBS.sql,v $
/*
CR31300 - Improve Safelink Contact edit job
Replace this trigger code and use this trigger only to restrict DELETE
for Update use new proc in safelink_validations_pkg
*/

--$Revision: 1.11 $
--$Author: arijal $
--$Date: 2015/01/08 22:22:01 $
--$ $Log: TRIG_X_SL_SUBS.sql,v $
--$ Revision 1.11  2015/01/08 22:22:01  arijal
--$ CR31300 JOB TO REPLACE TRIGGER X_SL_SUBS TRIGGER FOR DEL
--$
--$ Revision 1.9  2014/05/17 18:36:53  mvadlapally
--$ CR22302  Adding shipping address fields to Safelink vmbc-request.xml
--$
--$ Revision 1.7  2014/05/16 19:13:40  mvadlapally
--$ CR22302  Adding shipping address fields to Safelink vmbc-request.xml
--$
--$ Revision 1.6  2014/03/13 21:45:28  mvadlapally
--$ CR22302: Adding shipping address fields to Safelink vmbc-request.xml
--$
--$ Revision 1.5  2012/03/28 19:13:38  mmunoz
--$ CR17925 Added code to synchronize name, phone and email
--$
--$ Revision 1.4  2012/03/27 15:55:14  mmunoz
--$ CR17925 Added code to synchronize address information
--$
--$ Revision 1.3  2012/02/20 20:03:44  mmunoz
--$ Added changes to have VMBC origin in the x_sourcesystem instead of x_src_table when insert event code=608.
--$
--$ Revision 1.2  2012/01/31 21:40:51  mmunoz
--$ Added changes to have VMBC origin in the x_src_table when insert event code=608.
--$
--------------------------------------------------------------------------------------------
  before delete on sa.x_sl_subs
  FOR EACH ROW
declare

begin

     raise_application_error (-20140,SUBSTR('DELETE FROM X_SL_SUBS TABLE IS NOT ALLOWED '||SQLERRM,1,255));

end;
/