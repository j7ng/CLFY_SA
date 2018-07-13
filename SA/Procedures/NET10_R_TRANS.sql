CREATE OR REPLACE PROCEDURE sa."NET10_R_TRANS" (p_task_objid in number) as
  l_dest_queue varchar2(300);
begin
  igate.sp_Determine_Trans_Method(p_task_objid,'Rate Plan Change',null,l_dest_queue);
  commit;
end;
/