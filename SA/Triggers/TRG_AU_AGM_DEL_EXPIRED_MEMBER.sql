CREATE OR REPLACE TRIGGER sa."TRG_AU_AGM_DEL_EXPIRED_MEMBER"
--
  ---------------------------------------------------------------------------------------------
  --$RCSfile: TRG_AU_AGM_DEL_EXPIRED_MEMBER.sql,v $
  --$Revision: 1.4 $
  --$Author: vlaad $
  --$Date: 2016/10/14 14:02:45 $
  --$ $Log: TRG_AU_AGM_DEL_EXPIRED_MEMBER.sql,v $
  --$ Revision 1.4  2016/10/14 14:02:45  vlaad
  --$ Added condition for not firing triggers for Go Smart Migration
  --$
  --$ Revision 1.3  2016/05/04 15:00:21  pamistry
  --$ CR37756 - New trigger for SM SDP
  --$
  --$ Revision 1.1  2016/04/15 18:38:37  pamistry
  --$ CR37756 - Added new trigger on Group Member table to move Expired member to history table and remove it from group member table.
  --$
  --$
  --$ Revision 1.1  31/03/2016 11:49:58  PMistry
  --$ CR37756  - Added by PMistry to move the expired member to history table
  --$
  ---------------------------------------------------------------------------------------------
  --
  AFTER UPDATE ON sa.x_account_group_member
DECLARE
--PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
-- Go Smart changes
-- Do not fire trigger if global variable is turned off
 if not sa.globals_pkg.g_run_my_trigger then
   return;
 end if;
-- End Go Smart changes

    DELETE FROM sa.x_account_group_member
    WHERE status = 'EXPIRED'
    and   objid in ( select agm_objid
                     from gtt_account_group_member );

exception
  when others then
    dbms_output.put_line('error in AU trigger: '||sqlcode||' - '||sqlerrm);
END;
/